/* Procédure */
SET SERVEROUTPUT ON

/* 
** Procédure de duplication de rubrique
** @Tables {RUBRIQ & RUBAUT}
** Lettre des rubriques A,N,R
** @param1 : numrub = rubrique d'origine
** @param2 : numrubdest = rubrique de destination
** /!\ COMMIT manuel
**
*/


CREATE OR REPLACE PROCEDURE dRub (numrub IN NUMBER, numrubdest IN NUMBER) IS

	v_user_maj varchar2(30) := 'FELBAHJI';
	TYPE tab_rub IS
     TABLE OF rubriq%rowtype INDEX BY BINARY_INTEGER;
     t_rub  tab_rub;
	
	TYPE tab_rubaut IS
     TABLE OF rubaut%rowtype INDEX BY BINARY_INTEGER;
     t_rubaut  tab_rubaut;                      
	
	

BEGIN

    SELECT
        *
    BULK COLLECT
    INTO t_rub
    FROM
        rubriq
    WHERE
        cod_rub_num IN (numrub)
	AND cod_rub_let not in ('V')
	AND dat_fin = '31/12/2099';

    SELECT
        *
    BULK COLLECT
    INTO t_rubaut
    FROM
        rubaut
    WHERE
        cod_rub IN (numrub)||'N'
	AND num_lig < 9999
	AND dat_fin = '31/12/2099';
		


FOR j IN 1..t_rub.COUNT
		
			LOOP
			
				t_rub(j).cod_rub := numrubdest || t_rub(j).cod_rub_let;
				t_rub(j).cod_rub_num := numrubdest;
				t_rub(j).dat_maj := SYSDATE;
				t_rub(j).user_maj := v_user_maj;
				t_rub(j).dat_debut := '01/01/1940';
				
				IF (t_rub(j).typ_rub = 'A') THEN
					
					FOR k IN 1..t_rubaut.COUNT LOOP
						t_rubaut(k).cod_rub := numrubdest || t_rub(j).cod_rub_let;
						t_rubaut(k).dat_maj := SYSDATE;
						t_rubaut(k).user_maj := v_user_maj;
						t_rubaut(k).dat_debut := '01/01/1940';
							IF t_rubaut(k).num_complement1 = 40 AND t_rubaut(k).cod_complement1 = 'MTRN' THEN
								t_rubaut(k).param_n1 := numrubdest;
							END IF;
							IF t_rubaut(k).num_complement2 = 40 AND t_rubaut(k).cod_complement2 = 'MTRN' THEN
								t_rubaut(k).param_n2 := numrubdest;
							END IF;
							
							IF t_rubaut(k).num_complement1 = 50 AND t_rubaut(k).cod_complement1 = 'TXRN' THEN
								t_rubaut(k).param_n1 := numrubdest;
							END IF;
							IF t_rubaut(k).num_complement2 = 50 AND t_rubaut(k).cod_complement2 = 'TXRN' THEN
								t_rubaut(k).param_n2 := numrubdest;
							END IF;
							
							IF t_rubaut(k).num_complement1 = 45 AND t_rubaut(k).cod_complement1 = 'NBRN' THEN
								t_rubaut(k).param_n1 := numrubdest;
							END IF;
							IF t_rubaut(k).num_complement2 = 45 AND t_rubaut(k).cod_complement2 = 'NBRN' THEN
								t_rubaut(k).param_n2 := numrubdest;
							END IF;
						INSERT INTO RUBAUT VALUES t_rubaut(k);
					END LOOP;	
				END IF;
					INSERT INTO rubriq VALUES t_rub (j);
					
				EXIT WHEN j IS NULL;	
		
			END LOOP;  

END dRub;


