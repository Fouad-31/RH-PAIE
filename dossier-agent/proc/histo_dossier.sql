/* Procédure */
SET SERVEROUTPUT ON

/* 
** Procédure création d'une historisation sur les pages carriere et emploi
** @Tables {AGTGRD, OIN_AGTGRD, EMPLOI, OIN_EMPLOI, AGTCHG}
** /!\ COMMIT 
**
*/

CREATE OR REPLACE PROCEDURE create_histo (matricule IN NUMBER) IS

    v_idf_agent      NUMBER(6) := matricule;
    v_coll           VARCHAR2(30) := 'CG60';
	v_evt           VARCHAR2(30) := 'SEE';
	v_evt_lib           VARCHAR2(30) := 'Rifseep 03/2020';
    v_date_histo     DATE := '01/03/2020';
    v_date_histo_j   NUMBER(8) := to_number(TO_CHAR(TO_DATE('01/03/2020','dd/mm/yyyy'),'j') );
    v_user_maj       VARCHAR2(30) := '#RIFSEEP_' || SYSDATE;
    TYPE tab_agtgrd IS
        TABLE OF agtgrd%rowtype INDEX BY BINARY_INTEGER;
    t_agtgrd         tab_agtgrd;
    TYPE tab_oin_agtgrd IS
        TABLE OF oin_agtgrd%rowtype INDEX BY BINARY_INTEGER;
    t_oin_agtgrd     tab_oin_agtgrd;
    TYPE tab_emploi IS
        TABLE OF emploi%rowtype INDEX BY BINARY_INTEGER;
    t_emploi         tab_emploi;
    TYPE tab_oin_emploi IS
        TABLE OF oin_emploi%rowtype INDEX BY BINARY_INTEGER;
    t_oin_emploi     tab_oin_emploi;
    TYPE tab_agtchg IS
        TABLE OF agtchg%rowtype INDEX BY BINARY_INTEGER;
    t_agtchg         tab_agtchg;
	
  /*  TYPE tab_agtpadp IS
        TABLE OF agtpadp%rowtype INDEX BY BINARY_INTEGER;
    t_agtpadp         tab_agtpadp;	*/
	
BEGIN

	/* 
	** Mapping des tables
	*/
    SELECT
        *
    BULK COLLECT INTO
        t_agtgrd
    FROM
        agtgrd
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut AND dat_fin
        AND
            dat_debut != v_date_histo
        AND
            dat_fin != v_date_histo
        AND
            idf_agent = v_idf_agent;

    SELECT
        *
    BULK COLLECT INTO
        t_oin_agtgrd
    FROM
        oin_agtgrd
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut AND dat_fin
        AND
            dat_debut != v_date_histo
        AND
            dat_fin != v_date_histo
        AND
            idf_agent = v_idf_agent;

    SELECT
        *
    BULK COLLECT INTO
        t_emploi
    FROM
        emploi
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut AND dat_fin
        AND
            dat_debut != v_date_histo
        AND
            dat_fin != v_date_histo
        AND
            idf_agent = v_idf_agent;

    SELECT
        *
    BULK COLLECT INTO
        t_oin_emploi
    FROM
        oin_emploi
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut AND dat_fin
        AND
            dat_debut != v_date_histo
        AND
            dat_fin != v_date_histo
        AND
            idf_agent = v_idf_agent;

    SELECT
        *
    BULK COLLECT INTO
        t_agtchg
    FROM
        agtchg
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut AND dat_fin
        AND
            dat_debut != v_date_histo
        AND
            dat_fin != v_date_histo
        AND
            idf_agent = v_idf_agent;
			
			
   /* SELECT
        *
    BULK COLLECT INTO
        t_agtpadp
    FROM
        agtpadp
    WHERE
            cod_coll = v_coll
        AND
            v_date_histo BETWEEN dat_debut_padp AND dat_fin_padp
        AND
            dat_debut_padp != v_date_histo
        AND
            dat_fin_padp != v_date_histo
        AND
            idf_agent = v_idf_agent;	*/		

	
	/* Maj + insertion */
    FOR i IN 1..t_agtgrd.count LOOP
        UPDATE agtgrd
            SET
                user_maj = v_user_maj,
                dat_fin = v_date_histo,
                dat_fin_j = v_date_histo_j
        WHERE
                idf_agent = t_agtgrd(i).idf_agent
            AND
                dat_debut = t_agtgrd(i).dat_debut
            AND
                cod_coll = t_agtgrd(i).cod_coll;			
        t_agtgrd(i).dat_debut_j := v_date_histo_j;
        t_agtgrd(i).dat_debut := v_date_histo;
        dbms_output.put_line('dat_debut '
         || t_agtgrd(i).dat_debut);
        dbms_output.put_line('dat_fin '
         || t_agtgrd(i).dat_fin);
        INSERT INTO agtgrd VALUES t_agtgrd ( i );

        dbms_output.put_line('AGTGRD '
         || t_agtgrd(i).idf_agent);
		 
		 
		 		/* Mise à jour du groupe de fonction */
		update agtgrd grd set grd.grpfct = 
		(select fic.grpfct from grpfct_cd60 fic where fic.idf_agent = grd.idf_agent)
		where dat_debut = v_date_histo
		and cod_coll = v_coll
		and idf_agent = t_agtgrd(i).idf_agent;
		
		
    END LOOP;
	
	/*IF (t_agtpadp.count) > 0 THEN
        FOR i IN 1..t_agtpadp.count LOOP
            UPDATE agtpadp
                SET
                    dat_fin_padp = v_date_histo
            WHERE
                    idf_agent = t_oin_agtgrd(i).idf_agent
                AND
                    dat_debut_padp = t_agtpadp(i).dat_debut_padp
                AND
                    cod_coll = t_oin_agtgrd(i).cod_coll;
    
            t_agtpadp(i).dat_debut_padp := v_date_histo;
            INSERT INTO agtpadp VALUES t_agtpadp( i );
            
    
            dbms_output.put_line('agtpadp');
            
    
        END LOOP;	
    END IF;
*/
    FOR i IN 1..t_oin_agtgrd.count LOOP
        UPDATE oin_agtgrd
            SET
                dat_fin = v_date_histo
        WHERE
                idf_agent = t_oin_agtgrd(i).idf_agent
            AND
                dat_debut = t_oin_agtgrd(i).dat_debut
            AND
                cod_coll = t_oin_agtgrd(i).cod_coll;

        t_oin_agtgrd(i).dat_debut := v_date_histo;
        INSERT INTO oin_agtgrd VALUES t_oin_agtgrd ( i );
		

        dbms_output.put_line('oin agtgrd');
		

    END LOOP;



    FOR i IN 1..t_emploi.count LOOP
        UPDATE emploi
            SET
                dat_fin = v_date_histo,
                user_maj = v_user_maj
        WHERE
                idf_agent = t_emploi(i).idf_agent
            AND
                dat_debut = t_emploi(i).dat_debut
            AND
                cod_coll = t_emploi(i).cod_coll;

        t_emploi(i).dat_debut := v_date_histo;
        INSERT INTO emploi VALUES t_emploi ( i );

        dbms_output.put_line('emploi');
    END LOOP;

    FOR i IN 1..t_oin_emploi.count LOOP
        UPDATE oin_emploi
            SET
                dat_fin = v_date_histo
        WHERE
                idf_agent = t_oin_emploi(i).idf_agent
            AND
                dat_debut = t_oin_emploi(i).dat_debut
            AND
                cod_coll = t_oin_emploi(i).cod_coll;

        t_oin_emploi(i).dat_debut := v_date_histo;
        INSERT INTO oin_emploi VALUES t_oin_emploi ( i );

        dbms_output.put_line('oin emploi');
    END LOOP;
	
	
	/*
	* Evevenements sur Carrière et Emploi
	*
	*/
    FOR i IN 1..t_agtchg.count LOOP
        UPDATE agtchg
            SET
                dat_fin = v_date_histo,
                dat_fin_j = v_date_histo_j,
                dat_maj = SYSDATE,
                dat_maj_j = to_number(TO_CHAR(
                    TO_DATE(SYSDATE,'dd/mm/yyyy'),
                    'j'
                ) ),
                user_maj = v_user_maj
        WHERE
                idf_agent = t_agtchg(i).idf_agent
            AND
                dat_debut = t_agtchg(i).dat_debut
            AND
                cod_coll = t_agtchg(i).cod_coll;

        t_agtchg(i).dat_debut := v_date_histo;
        t_agtchg(i).dat_debut_j := v_date_histo_j;
		t_agtchg(i).num_emploi := 99;		
        t_agtchg(i).cod_chgt := v_evt;
        t_agtchg(i).lib_compl := v_evt_lib;
        dbms_output.put_line('oin agtchg');
		
    END LOOP;
	INSERT INTO agtchg VALUES t_agtchg ( 1 );
	t_agtchg(1).num_emploi := 1;
	INSERT INTO agtchg VALUES t_agtchg ( 1 );
	
	COMMIT;
	
	

    	

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('ERREUR PROCEDURE '
         || sqlcode
         || ' '
         || sqlerrm
         || ' matricule '
         || t_agtgrd(1).idf_agent);
        

        ROLLBACK;
        
        insert into log_histo (idf_agent,commentaire) values (t_agtgrd(1).idf_agent,'AGENT_NON_TRAITE');
        COMMIT;
END;