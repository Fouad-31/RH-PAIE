/* procedure à supprimer apres démarrage */
CREATE OR REPLACE PROCEDURE copaut 
										(
											p_numrub IN NUMBER,
											p_deblign IN NUMBER, 
											p_finlign IN NUMBER,
											p_espace IN NUMBER

										) 
										IS

	v_user_maj varchar2(30) := 'FELBAHJI';--||sysdate;
	
	
	
	
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
	AND dat_fin = '31/12/2099';

	FOR i IN 1..t_rubaut.COUNT	
		LOOP

			t_rubaut(i).dat_maj := sysdate;
			t_rubaut(i).user_maj := v_user_maj;	
			t_rubaut(i).num_lig := t_rubaut(i).num_lig + p_espace;
			IF t_rubaut(i).typ_oper1  = 'E' THEN
				t_rubaut(i).param_n1 := t_rubaut(i).param_n1 + p_espace;
			END IF;
			IF t_rubaut(i).typ_oper2  = 'E' THEN
				t_rubaut(i).param_n2 := t_rubaut(i).param_n2 + p_espace;
			END IF;
				

			INSERT INTO RUBAUT VALUES t_rubaut(i);
		END LOOP;
	
	END copaut;
			
		
update rubaut set param_n1 = param_n1 * 10 where cod_rub = '391N' and dat_debut = '01/01/2019' and typ_oper1 = 'E';
update rubaut set param_n2 = param_n2 * 10 where cod_rub = '391N' and dat_debut = '01/01/2019' and typ_oper2 = 'E';