/* Procedure temporaire pour mise en place du parametrage */
SET SERVEROUTPUT ON
/*
* /!\ Utiliser uniquement sur les cotisations libres.
* @Tables : {RUBRIQ, V_TYPCOT, V_TYPCUM, COTRUB, TAUCOT }
* @p_numrub : rubrique de cotisation d'origine avec la lettre C
* @p_numrubdest : rubrique de destination
* @p_libelle : Libellé repris max 20 caracteres
*/

CREATE OR REPLACE PROCEDURE duplicCotis (p_numrub IN VARCHAR2, p_numrubdest IN VARCHAR2, p_libelle IN VARCHAR2) IS

	v_user_maj varchar2(30) := 'FEL'; 
	TYPE tab_rub IS
    TABLE OF rubriq%rowtype INDEX BY BINARY_INTEGER;
    t_rub  tab_rub;
	
	TYPE tab_typ_cotis IS
    TABLE OF v_typcot%rowtype INDEX BY BINARY_INTEGER;
    t_typ_cotis  tab_typ_cotis;
	
	TYPE tab_typ_cum IS
    TABLE OF v_typcum%rowtype INDEX BY BINARY_INTEGER;
    t_typcum  tab_typ_cum;
	
	
	TYPE tab_cotrub IS
    TABLE OF cotrub%rowtype INDEX BY BINARY_INTEGER;
    t_cotrub  tab_cotrub;                  
	
	TYPE tab_taucot IS
    TABLE OF taucot%rowtype INDEX BY BINARY_INTEGER;
    t_taucot  tab_taucot;   	

BEGIN

    SELECT
        *
    BULK COLLECT
    INTO t_rub
    FROM
        rubriq
    WHERE
        cod_rub_num IN (p_numrub)
	AND cod_rub_let in ('C','A','R','T')
	AND dat_fin = '31/12/2099'
	AND cod_coll = '*****';

    SELECT
        *
    BULK COLLECT
    INTO t_typ_cotis
    FROM
        v_typcot
    WHERE
        typ_cotis = p_numrub;

    SELECT
        *
    BULK COLLECT
    INTO t_typcum
    FROM
        v_typcum
    WHERE
        cod_typcum = p_numrub||'L';
		
    SELECT
        *
    BULK COLLECT
    INTO t_cotrub 
    FROM
        cotrub
    WHERE
        typ_cotis = p_numrub;

    SELECT
        *
    BULK COLLECT
    INTO t_taucot 
    FROM
        taucot
    WHERE
        typ_cotis = p_numrub
	AND dat_fin = '31/12/2099';

	t_typ_cotis(1).lib_cotis := p_libelle;
	t_typ_cotis(1).lic_cotis := substr(p_libelle,0,10);
	t_typ_cotis(1).typ_cotis := p_numrubdest;
	t_typ_cotis(1).dat_maj := sysdate;
	t_typ_cotis(1).user_maj := v_user_maj;
	
	t_typcum(1).lib_typcum := p_libelle;
	t_typcum(1).lic_typcum := substr(p_libelle,0,10);	
	t_typcum(1).cod_typcum := p_numrubdest||'L';
	t_typcum(1).dat_maj := sysdate;
	t_typcum(1).user_maj := v_user_maj;
	
	t_cotrub(1).typ_cotis := p_numrubdest;
	t_cotrub(1).cod_rub := p_numrubdest||'C';
	t_cotrub(1).cod_rubr := p_numrubdest||'A';
	t_cotrub(1).dat_maj := sysdate;
	t_cotrub(1).user_maj := v_user_maj;	
	
	t_taucot(1).dat_debut := '01/01/1940';
	t_taucot(1).typ_cotis := p_numrubdest;
	t_taucot(1).dat_maj := sysdate;
	t_taucot(1).user_maj := v_user_maj;	
	

	insert into v_typcot values t_typ_cotis(1);
	insert into v_typcum values t_typcum(1);
	insert into cotrub values t_cotrub(1);
	insert into taucot values t_taucot(1);
		
	--commit;
	
	for i in 1..t_rub.COUNT loop 	
		t_rub(i).cod_rub := p_numrubdest||t_rub(i).cod_rub_let;
		t_rub(i).dat_debut := '01/01/1940';
		t_rub(i).lib_rub := p_libelle;
		t_rub(i).dat_maj := sysdate;
		t_rub(i).user_maj := v_user_maj;
		dbms_output.put_line('Insertion rubrique ...');
		insert into rubriq values t_rub(i);
	end loop;
	
EXCEPTION
    WHEN OTHERS THEN
	dbms_output.put_line('ERREUR PROCEDURE '|| SQLCODE ||' '||SQLERRM);
     ROLLBACK;
	

	

END duplicCotis;


