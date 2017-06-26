class AddVotingLibFunctionToDb < ActiveRecord::Migration
  def self.up
    execute "
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
            vote_sum := vote_sum + abs(get_paper_user_score(paper_id, row.voter_id));
            end loop;

            return vote_sum / voted_user_cnt;
                        
            End

            $function$;

            ALTER FUNCTION public.get_paper_sma(integer)
                OWNER TO postgres;"
    execute "
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
                OWNER TO postgres;"
    execute "
            CREATE OR REPLACE FUNCTION public.get_paper_user_score(
              paper_id integer,
              user_id integer)
                RETURNS integer
                LANGUAGE 'plpgsql'
                COST 100.0
                VOLATILE 
            AS $function$

            declare
            upvote integer;
            downvote integer;
            score integer;
            begin
            select count(1) into upvote from votes
            where votable_type = 'Papermache::Paper'
            and votable_id = paper_id
            and voter_id = user_id
            and vote_flag = true;

            select count(1) into downvote from votes
            where votable_type = 'Papermache::Paper'
            and votable_id = paper_id
            and voter_id = user_id
            and vote_flag = false;

            score := upvote - downvote;
            return score;
            end

            $function$;

            ALTER FUNCTION public.get_paper_user_score(integer, integer)
                OWNER TO postgres;"
    execute "
            CREATE OR REPLACE FUNCTION public.get_user_allpaper_votescore(
              user_id integer)
                RETURNS integer
                LANGUAGE 'plpgsql'
                COST 100.0
                VOLATILE 
            AS $function$

            DECLARE
            RET INTEGER := 0;
            BEGIN

            SELECT COALESCE(SUM(CACHED_VOTES_SCORE), 0) INTO RET FROM PAPERS
            WHERE
            ACCOUNT_ID = USER_ID;

            RETURN RET;
            END

            $function$;

            ALTER FUNCTION public.get_user_allpaper_votescore(integer)
                OWNER TO postgres;"
    execute "
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
            BEGIN

            ALL_VOTES_SCORE := GET_USER_ALLPAPER_VOTESCORE(USER_ID);

            select COALESCE(sum(GAIN_LOSSES), 0.0) INTO ALL_GAINLOSSES from 
            (
            SELECT DISTINCT(VOTABLE_ID) ,  get_paper_user_gainlosses(votable_id, USER_ID) GAIN_LOSSES FROM VOTES
            WHERE 
            VOTABLE_TYPE = 'Papermache::Paper'
            AND VOTER_ID = USER_ID
            ) as tbl;
            RET := ALL_VOTES_SCORE + ALL_GAINLOSSES;
            RETURN RET;
            END

            $function$;

            ALTER FUNCTION public.get_user_reputation(integer)
                OWNER TO postgres;"
  end

  def self.down
    execute "DROP FUNCTION public.get_paper_sma(integer);"
    execute "DROP FUNCTION public.get_paper_user_gainlosses(integer, integer);"
    execute "DROP FUNCTION public.get_paper_user_score(integer, integer);"
    execute "DROP FUNCTION public.get_user_allpaper_votescore(integer);"
    execute "DROP FUNCTION public.get_user_reputation(integer);"
  end
end
