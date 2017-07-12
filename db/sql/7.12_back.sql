-- FUNCTION: public.get_paper_sma(integer)

-- DROP FUNCTION public.get_paper_sma(integer);

CREATE OR REPLACE FUNCTION public.get_paper_sma(
	paper_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

            declare
            voted_user_cnt integer;
            vote_sum integer;
            row RECORD;
            ACCOUNT_ID INTEGER;
            Begin
            select count(1) into voted_user_cnt from
            (
            select voter_id, count(*) from votes
            where votable_type = 'Papermache::Paper'
            and votable_id = paper_id
            group by voter_id
                ) as tbl;
            if voted_user_cnt = 0 then
              return 0;
            end if;
            vote_sum := 0;
            for row in (select voter_id from
                            votes
                            where votable_type = 'Papermache::Paper'
                            and votable_id = paper_id
                            group by voter_id) 
            loop
              SELECT AC.ID INTO ACCOUNT_ID FROM ACCOUNTS AC WHERE AC.STUDENT_ID = row.voter_id;
              vote_sum := vote_sum + abs(get_paper_user_score(paper_id, ACCOUNT_ID));
            end loop;

            return vote_sum / voted_user_cnt;
                        
            End

            

$function$;

ALTER FUNCTION public.get_paper_sma(integer)
    OWNER TO postgres;


-- FUNCTION: public.get_paper_user_gainlosses(integer, integer)

-- DROP FUNCTION public.get_paper_user_gainlosses(integer, integer);

CREATE OR REPLACE FUNCTION public.get_paper_user_gainlosses(
	paper_id integer,
	user_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

            DECLARE
            RET DOUBLE PRECISION;
            SCORE INTEGER;
            PAPER_SMA DOUBLE PRECISION;
            BEGIN
            SCORE := GET_PAPER_USER_SCORE(PAPER_ID, USER_ID);
            PAPER_SMA := GET_PAPER_SMA(PAPER_ID);

            IF SCORE > 0 THEN
              RET := (PAPER_SMA + SCORE) / 2;
            ELSEIF SCORE = 0 THEN
              RET := 0.0;
            ELSE
              RET := 1 - (PAPER_SMA + SCORE) / 2;
            END IF;
            RETURN RET; 
            END

            

$function$;

ALTER FUNCTION public.get_paper_user_gainlosses(integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.get_paper_user_score(integer, integer)

-- DROP FUNCTION public.get_paper_user_score(integer, integer);

CREATE OR REPLACE FUNCTION public.get_paper_user_score(
	paper_id integer,
	user_id integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

            declare
            vote_up integer := 0;
            vote_down integer :=0;
            up_cnt integer := 0;
            down_cnt integer := 0;
            score integer;
            STUDENT_ID INTEGER;
            begin
            SELECT AC.STUDENT_ID INTO STUDENT_ID FROM ACCOUNTS AC WHERE AC.ID = USER_ID;
            
            select COALESCE(sum(vote_weight),0) into vote_up from votes
            where votable_type = 'Papermache::Paper'
            and votable_id = paper_id
            and voter_id = STUDENT_ID
            and vote_flag = true;

            select COALESCE(sum(vote_weight),0) into vote_down from votes
            where votable_type = 'Papermache::Paper'
            and votable_id = paper_id
            and voter_id = STUDENT_ID
            and vote_flag = false;
            
            score := vote_up - vote_down;
            return score;
            end

            

$function$;

ALTER FUNCTION public.get_paper_user_score(integer, integer)
    OWNER TO postgres;

-- FUNCTION: public.get_user_allpaper_votescore(integer)

-- DROP FUNCTION public.get_user_allpaper_votescore(integer);

CREATE OR REPLACE FUNCTION public.get_user_allpaper_votescore(
	user_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$

            DECLARE
            RET double precision := 0;
            peer_vote_up integer := 0;
            peer_vote_down integer := 0;
            votes_up_received_for_allpapers integer := 0;
            votes_down_received_for_allpapers integer := 0;
            score_up double precision :=0;	-- votes_up_received_for_allpapers / peer_vote_up
            score_down double precision :=0; -- votes_down_received_for_allpapers / peer_vote_down
            BEGIN

            SELECT COALESCE(SUM(get_paper_user_score(id, user_id)), 0) INTO RET FROM PAPERS
            WHERE
            ACCOUNT_ID = USER_ID;

            -- get Peer Vote volume by USER_ID
            select COALESCE(sum(cached_votes_up),0), COALESCE(sum(cached_votes_down),0) into peer_vote_up, peer_vote_down from papers where account_id = USER_ID;
            
            -- calcuate How many votes received for all portifolio papers
            select coalesce(sum(vote_weight),0) into votes_up_received_for_allpapers from votes 
            where votable_type = 'Papermache::Paper'
            and votable_id in (select id from papers where account_id = user_id)
            and vote_flag = true;
            
            select coalesce(sum(vote_weight),0) into votes_down_received_for_allpapers from votes 
            where votable_type = 'Papermache::Paper'
            and votable_id in (select id from papers where account_id = user_id)
            and vote_flag = false;
            
            if peer_vote_up <> 0 then
            	score_up := votes_up_received_for_allpapers / peer_vote_up;
            end if;
            
            if peer_VOTE_DOWN <> 0 THEN
            	SCORE_DOWN := votes_down_received_for_allpapers / peer_vote_down;
            END IF;
            
            RET := SCORE_UP - SCORE_DOWN;
            
            RETURN RET;
            END

            

$function$;

ALTER FUNCTION public.get_user_allpaper_votescore(integer)
    OWNER TO postgres;

-- FUNCTION: public.get_user_gainlosses(integer)

-- DROP FUNCTION public.get_user_gainlosses(integer);

CREATE OR REPLACE FUNCTION public.get_user_gainlosses(
	p_account_id integer)
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
			SELECT AC.STUDENT_ID INTO V_STUDENT_ID FROM ACCOUNTS AC WHERE AC.ID = p_account_id;
            		
            select COALESCE(sum(GAIN_LOSSES), 0.0) INTO ALL_GAINLOSSES from 
            (
            SELECT DISTINCT(VOTABLE_ID) ,  get_paper_user_gainlosses(votable_id, p_account_id) GAIN_LOSSES FROM VOTES
            WHERE 
            VOTABLE_TYPE = 'Papermache::Paper'
            AND VOTER_ID = V_STUDENT_ID
            ) as tbl;
            
            RET := ALL_GAINLOSSES;
            RETURN RET;
            END

$function$;

ALTER FUNCTION public.get_user_gainlosses(integer)
    OWNER TO postgres;

-- FUNCTION: public.get_user_reputation(integer)

-- DROP FUNCTION public.get_user_reputation(integer);

CREATE OR REPLACE FUNCTION public.get_user_reputation(
	user_id integer)
    RETURNS double precision
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE 
AS $function$
            DECLARE
            RET DOUBLE PRECISION := 0.0;
            ALL_VOTES_SCORE INTEGER := 0;
            ALL_GAINLOSSES DOUBLE PRECISION := 0.0;
           	STUDENT_ID INTEGER := 0;
            BEGIN
            ALL_VOTES_SCORE := GET_USER_ALLPAPER_VOTESCORE(USER_ID);
			
            ALL_GAINLOSSES := GET_USER_GAINLOSSES(USER_ID);
            RET := ALL_VOTES_SCORE + ALL_GAINLOSSES;
            RETURN RET;
            END

            

$function$;

ALTER FUNCTION public.get_user_reputation(integer)
    OWNER TO postgres;

