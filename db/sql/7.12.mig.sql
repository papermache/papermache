DROP FUNCTION IF EXISTS public.get_paper_sma(integer);
DROP FUNCTION IF EXISTS public.get_paper_user_gainlosses(integer, integer);
DROP FUNCTION IF EXISTS public.get_paper_user_score(integer, integer);
DROP FUNCTION IF EXISTS public.get_user_allpaper_votescore(integer);
DROP FUNCTION IF EXISTS public.get_user_gainlosses(integer);
DROP FUNCTION IF EXISTS public.get_user_reputation(integer);

-- DROP FUNCTION public.get_vote_cast(integer, integer);

CREATE OR REPLACE FUNCTION public.get_vote_cast(
	paper_id integer,
	account_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE    
RET integer;
v_student_id integer;
vflag boolean;
BEGIN
select student_id into v_student_id from accounts where id = account_id;

select vote_weight, vote_flag into ret, vflag from votes 
where
votable_type = 'Papermache::Paper'
and voter_type = 'Student'
and votable_id = paper_id
and voter_id = v_student_id;

if vflag = false then
ret := ret * (-1);
end if;

return coalesce(ret,0);
END

$function$;

ALTER FUNCTION public.get_vote_cast(integer, integer)
    OWNER TO postgres;




-- FUNCTION: public.get_sma(integer)

-- DROP FUNCTION public.get_sma(integer);

CREATE OR REPLACE FUNCTION public.get_sma(
	paper_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE
RET Double precision;
BEGIN
select coalesce(cached_weighted_average,0) into ret from papers where id = $1;
return ret;
END

$function$;

ALTER FUNCTION public.get_sma(integer)
    OWNER TO postgres;



-- FUNCTION: public.get_gain_losses_paper(integer, integer)

-- DROP FUNCTION public.get_gain_losses_paper(integer, integer);

CREATE OR REPLACE FUNCTION public.get_gain_losses_paper(
	paper_id integer,
	account_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE    
RET double precision;
SMA double precision;
votes_cast integer;
volume integer;
BEGIN
	sma := get_sma(paper_id);
 	votes_cast := get_vote_cast(paper_id, account_id);
	select cached_votes_total into volume from papers where id = paper_id;
    if volume = 1 then 
    	ret := - votes_cast;
    else
 		ret := (sma + abs(votes_cast)) / 2;
	end if;        
    
    if votes_cast < 0 then
         ret := 1 - ret;
    end if;
    
	return ret;
END

$function$;

ALTER FUNCTION public.get_gain_losses_paper(integer, integer)
    OWNER TO postgres;


-- FUNCTION: public.get_gain_losses(integer)

-- DROP FUNCTION public.get_gain_losses(integer);

CREATE OR REPLACE FUNCTION public.get_gain_losses(
	account_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE
            RET DOUBLE PRECISION := 0.0;
            ALL_GAINLOSSES DOUBLE PRECISION := 0.0;
           	V_STUDENT_ID INTEGER := 0;
            BEGIN
			SELECT AC.STUDENT_ID INTO V_STUDENT_ID FROM ACCOUNTS AC WHERE AC.ID = account_id;
			
            SELECT 
                coalesce(SUM(get_gain_losses_paper(votable_id, account_id)),0) INTO ALL_GAINLOSSES
            FROM VOTES
            WHERE	VOTABLE_TYPE = 'Papermache::Paper'
                    AND voter_type = 'Student'
                    AND VOTER_ID = V_STUDENT_ID;

            RET := ALL_GAINLOSSES;
            RETURN RET;
            END

$function$;

ALTER FUNCTION public.get_gain_losses(integer)
    OWNER TO postgres;


-- FUNCTION: public.get_votes_score(integer)

-- DROP FUNCTION public.get_votes_score(integer);

CREATE OR REPLACE FUNCTION public.get_votes_score(
	account_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

DECLARE    
RET double precision;
t_ws integer;
t_wt integer;
t_vu integer;
t_vd integer;
BEGIN
	
    select coalesce(sum(cached_weighted_score),0),
    		coalesce(sum(cached_weighted_total),0), 
            coalesce(sum(cached_votes_up), 1),
            coalesce(sum(cached_votes_down), 1)
    into t_ws, t_wt, t_vu, t_vd
    from papers where papers.account_id = $1;
    
    -- process to avoid to divide by zero 
    t_vu := case when (t_vu = 0) 
    		then 1 
            else t_vu 
            end;
            
    t_vd := case when (t_vd = 0) 
    		then 1 
            else t_vd 
            end;
	            
    ret := (t_ws + t_wt) / 2 / t_vu - (t_wt - t_ws) / 2 / t_vd; 
/*    
	-- using single sql
    select 
    coalesce(
	( sum(cached_weighted_score) + sum(cached_weighted_total) ) / 2 / (CASE WHEN (sum(cached_votes_up) > 0) THEN sum(cached_votes_up) ELSE 1 END) -
	( sum(cached_weighted_total) - sum(cached_weighted_score) ) / 2 / (CASE WHEN (sum(cached_votes_down) > 0) THEN sum(cached_votes_down) ELSE 1 END),0)
    into
    ret
    from papers
    where account_id = $1
*/    
	return ret;
END

$function$;

ALTER FUNCTION public.get_votes_score(integer)
    OWNER TO postgres;


-- FUNCTION: public.get_reputation(integer)

-- DROP FUNCTION public.get_reputation(integer);

CREATE OR REPLACE FUNCTION public.get_reputation(
	account_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

            DECLARE
            RET DOUBLE PRECISION := 0.0;
            ALL_VOTES_SCORE DOUBLE PRECISION := 0.0;	 -- votes score received for all papers in user portfolio 
            ALL_GAINLOSSES DOUBLE PRECISION := 0.0;
            BEGIN
            ALL_VOTES_SCORE := GET_VOTES_SCORE(account_id);			
            ALL_GAINLOSSES := GET_GAIN_LOSSES(account_id);
            RET := ALL_VOTES_SCORE + ALL_GAINLOSSES;
            RETURN RET;
            END

            

$function$;

ALTER FUNCTION public.get_reputation(integer)
    OWNER TO postgres;


-- FUNCTION: public.get_voted_paper_cnt(integer)

-- DROP FUNCTION public.get_voted_paper_cnt(integer);

CREATE OR REPLACE FUNCTION public.get_voted_paper_cnt(
	account_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

	DECLARE
    	RET integer := 0;
        V_STUDENT_ID INTEGER := 0;
    BEGIN
    	SELECT AC.STUDENT_ID INTO V_STUDENT_ID FROM ACCOUNTS AC WHERE AC.ID = account_id;

		SELECT COUNT(1) INTO RET
        FROM VOTES
        WHERE	VOTABLE_TYPE = 'Papermache::Paper'
             	AND voter_type = 'Student'
                AND VOTER_ID = V_STUDENT_ID;
                
        RETURN RET;
    END         

$function$;

ALTER FUNCTION public.get_voted_paper_cnt(integer)
    OWNER TO postgres;

-- FUNCTION: public.get_sma_view(integer)

-- DROP FUNCTION public.get_sma_view(integer);

CREATE OR REPLACE FUNCTION public.get_sma_view(
	paper_id integer)
    RETURNS TABLE(voter_name text, yea integer, nay integer)
    LANGUAGE 'sql'
    COST 100.0
    VOLATILE     ROWS 1000.0
AS $function$

select (select first_name || ' ' || last_name from accounts where student_id =  voter_id) voter_name, 
case when(vote_flag) then vote_weight else 0 end Yea, 
case when(vote_flag) then 0 else vote_weight end Nay
 from votes
where
votable_type = 'Papermache::Paper'
and voter_type = 'Student'
and votable_id = $1

$function$;

ALTER FUNCTION public.get_sma_view(integer)
    OWNER TO postgres;

-- FUNCTION: public.get_voted_papers(integer)

-- DROP FUNCTION public.get_voted_papers(integer);

CREATE OR REPLACE FUNCTION public.get_voted_papers(
	account_id integer)
    RETURNS SETOF papers 
    LANGUAGE 'sql'
    COST 100.0
    VOLATILE     ROWS 1000.0
AS $function$

         SELECT 
				pp.*
         FROM VOTES left join papers pp on (votable_id = pp.id)
         WHERE	VOTABLE_TYPE = 'Papermache::Paper'
                 AND voter_type = 'Student'
                 AND VOTER_ID = (SELECT AC.STUDENT_ID  FROM ACCOUNTS AC WHERE AC.ID = $1)
      	order by votable_id				

$function$;

ALTER FUNCTION public.get_voted_papers(integer)
    OWNER TO postgres;


