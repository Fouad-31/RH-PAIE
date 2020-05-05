/* procedure à supprimer apres démarrage */
/*
* Permet de dupliquer les formules indépendamment de la rubrique
* avec une date de début au 01/01/1940
* @Tables : {RUBAUT} 
* @p_numrub : rubrique d'origine avec la lettre N
* @p_numrubdest : rubrique de destination  avec la lettre N
* @p_deblign : Début de ligne à copier
* @p_finlign : Fin de ligne à copier
*/


CREATE OR REPLACE PROCEDURE daut
										(
											p_numrub IN NUMBER,
											p_numrubdest IN NUMBER,	
											p_deblign IN NUMBER, 
											p_finlign IN NUMBER

										) 
										IS

	v_user_maj varchar2(30) := '#FEL#'||sysdate;
	
	
	
	
	TYPE tab_rubaut IS
        TABLE OF rubaut%rowtype INDEX BY BINARY_INTEGER;
    t_rubaut  tab_rubaut;
	
	BEGIN
	
	SELECT
        *
    BULK COLLECT
    INTO t_rubaut
    FROM
        rubaut
    WHERE
        cod_rub = (p_numrub)||'N'
	AND num_lig between p_deblign and p_finlign
	AND cod_coll = '*****'
	AND dat_fin = '31/12/2099';
	
	
	FOR i IN 1..t_rubaut.COUNT	
		LOOP
			--t_rubaut(i).dat_debut := '01/04/2019';
			t_rubaut(i).cod_rub := p_numrubdest||'N';
			t_rubaut(i).dat_maj := sysdate;
			t_rubaut(i).user_maj := v_user_maj;
			dbms_output.put_line('Insertion '	);	
				IF t_rubaut(i).num_complement1 = 40 AND t_rubaut(i).cod_complement1 = 'MTRN' THEN
					t_rubaut(i).param_n1 := p_numrubdest;
				END IF;
				IF t_rubaut(i).num_complement2 = 40 AND t_rubaut(i).cod_complement2 = 'MTRN' THEN
					t_rubaut(i).param_n2 := p_numrubdest;
				END IF;
				
				IF t_rubaut(i).num_complement1 = 50 AND t_rubaut(i).cod_complement1 = 'TXRN' THEN
					t_rubaut(i).param_n1 := p_numrubdest;
				END IF;
				IF t_rubaut(i).num_complement2 = 50 AND t_rubaut(i).cod_complement2 = 'TXRN' THEN
					t_rubaut(i).param_n2 := p_numrubdest;
				END IF;
				
				IF t_rubaut(i).num_complement1 = 45 AND t_rubaut(i).cod_complement1 = 'NBRN' THEN
					t_rubaut(i).param_n1 := p_numrubdest;
				END IF;
				IF t_rubaut(i).num_complement2 = 45 AND t_rubaut(i).cod_complement2 = 'NBRN' THEN
					t_rubaut(i).param_n2 := p_numrubdest;
				END IF;
			INSERT INTO RUBAUT VALUES t_rubaut(i);
		END LOOP;
				commit;
		EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;

	
	END daut;
	

			
		
