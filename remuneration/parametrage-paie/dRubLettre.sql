/* Procédure */
SET SERVEROUTPUT ON

/* 
** Procédure de duplication de rubrique
** @Tables {RUBRIQ}
** Lettre des rubriques A,N,R
** @param1 : numrub = rubrique d'origine
** @param2 : numrubdest = rubrique de destination
** /!\ COMMIT manuel
**
*/


CREATE OR REPLACE PROCEDURE dRubLettre (numrub IN NUMBER, lettre_rub IN VARCHAR2, lettre_rub_dest IN VARCHAR2) IS

	v_user_maj varchar2(30) := 'FELBAHJI';                                                                                                  TYPE tab_rub IS
     TABLE OF rubriq%rowtype INDEX BY BINARY_INTEGER;
     t_rub  tab_rub;

	

BEGIN

    SELECT
        *
    BULK COLLECT
    INTO t_rub
    FROM
        rubriq
    WHERE
        cod_rub_num IN (numrub)
	AND cod_rub_let = lettre_rub
	AND dat_fin = '31/12/2099';


		


FOR j IN 1..t_rub.COUNT
		
			LOOP
			
				t_rub(j).cod_rub := numrub || lettre_rub_dest;
				t_rub(j).cod_rub_num := numrub;
				t_rub(j).cod_rub_let := lettre_rub_dest;
				t_rub(j).dat_maj := SYSDATE;
				t_rub(j).user_maj := v_user_maj;
				t_rub(j).dat_debut := '01/01/1940';
				

					INSERT INTO rubriq VALUES t_rub (j);
					
				EXIT WHEN j IS NULL;	
		
			END LOOP;  

END dRubLettre;


