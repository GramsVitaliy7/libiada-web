-- � ������ ����� �������� ������� ���� ������, 
-- ���������� ��������� ���������� ����� 
-- � ���������� ������, �� ��������� �������� �����.

BEGIN;

-- 24.11.2013

-- ������� � ����� ���������� � ������� chain � ��������������� �� ����������.
-- ��� �����, ����������� �� ����� � ������� ���� �������� check constraint'���, ���� ����������.

ALTER TABLE chain  ADD COLUMN alphabet bigint[];
COMMENT ON COLUMN chain.alphabet IS '������� �������.';
COMMENT ON COLUMN dna_chain.alphabet IS '������� �������.';
COMMENT ON COLUMN literature_chain.alphabet IS '������� �������.';
COMMENT ON COLUMN music_chain.alphabet IS '������� �������.';
COMMENT ON COLUMN fmotiv.alphabet IS '������� �������.';
COMMENT ON COLUMN measure.alphabet IS '������� �������.';

UPDATE chain SET alphabet = (
    SELECT array_agg(a.elements) FROM (
        SELECT element_id elements FROM 
            alphabet 
            WHERE chain_id = chain.id 
            GROUP BY element_id, alphabet.number 
            ORDER BY number
        ) a 
    );
    
ALTER TABLE chain ALTER COLUMN alphabet SET NOT NULL;


    
ALTER TABLE chain  ADD COLUMN building integer[];
COMMENT ON COLUMN chain.building IS '����� �������.';
COMMENT ON COLUMN dna_chain.building IS '����� �������.';
COMMENT ON COLUMN literature_chain.building IS '����� �������.';
COMMENT ON COLUMN music_chain.building IS '����� �������.';
COMMENT ON COLUMN fmotiv.building IS '����� �������.';
COMMENT ON COLUMN measure.building IS '����� �������.';

UPDATE chain SET building = (
    SELECT array_agg(b.numbers) FROM (
        SELECT number numbers FROM 
            building 
            WHERE chain_id = chain.id 
            GROUP BY building.number, building.index 
            ORDER BY index
        ) b 
    );

ALTER TABLE chain ALTER COLUMN building SET NOT NULL;

 ALTER TABLE congeneric_characteristic DROP CONSTRAINT fk_congeneric_characteristic_alphabet_element;
 ALTER TABLE binary_characteristic DROP CONSTRAINT fk_binary_characteristic_alphabet_first_element;
 ALTER TABLE binary_characteristic DROP CONSTRAINT fk_binary_characteristic_alphabet_second_element;
 
 CREATE FUNCTION check_element_in_alphabet(IN chain_id bigint, IN element_id bigint) RETURNS boolean AS
$BODY$var plan = plv8.prepare( 'SELECT count(*) = 1 result FROM (SELECT unnest(alphabet) a FROM chain WHERE id = $1) c WHERE c.a = $2;', ['bigint', 'bigint']);
var result = plan.execute([chain_id, element_id])[0].result;
plan.free();
return result; $BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.check_element_in_alphabet(IN bigint, IN bigint) IS '������� ��� �������� ������� �������� � ��������� id � �������� ��������� �������.';

CREATE FUNCTION trigger_check_element_in_alphabet() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
    var check_element_in_alphabet = plv8.find_function("check_element_in_alphabet");
    var elementInAlphabet = check_element_in_alphabet(NEW.chain_id, NEW.element_id);
    if(elementInAlphabet){
        return NEW;
    }
    else{
        plv8.elog(ERROR, '���������� �������������� ��������� � ��������, �������������� � �������� �������. element_id = ', NEW.element_id,' ; chain_id = ', NEW.chain_id);
    }
} else{
    plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ������ chain_id � element_id');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.trigger_check_element_in_alphabet() IS '���������� �������, ����������� ��� ������� ��� �������� ��������� �������������� ���������� ���� ���� � �������� ��������� �������. �� ���� ������ ��� �������� ����� ������������ �� �������.';

CREATE TRIGGER tgiu_congeneric_chracteristic_element_in_alphabet BEFORE INSERT OR UPDATE ON congeneric_characteristic FOR EACH ROW EXECUTE PROCEDURE public.trigger_check_element_in_alphabet();

COMMENT ON TRIGGER tgiu_congeneric_chracteristic_element_in_alphabet ON congeneric_characteristic IS '�������, ����������� ��� ������� ���������� �������, ��� ������� ��������� ��������������, ������������ � �������� ������ �������.';

CREATE FUNCTION trigger_check_elements_in_alphabet() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
    var check_element_in_alphabet = plv8.find_function("check_element_in_alphabet");
    var firstElementInAlphabet = check_element_in_alphabet(NEW.chain_id, NEW.first_element_id);
    var secondElementInAlphabet = check_element_in_alphabet(NEW.chain_id, NEW.second_element_id);
    if(firstElementInAlphabet && secondElementInAlphabet){
        return NEW;
    }
    else if(firstElementInAlphabet){
        plv8.elog(ERROR, '���������� �������������� ��������� � ��������, �������������� � �������� �������. second_element_id = ', NEW.second_element_id,' ; chain_id = ', NEW.chain_id);
    } else{
        plv8.elog(ERROR, '���������� �������������� ��������� � ��������, �������������� � �������� �������. first_element_id = ', NEW.first_element_id,' ; chain_id = ', NEW.chain_id);
    }
} else{
    plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ������ chain_id, first_element_id � second_element_id');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.trigger_check_elements_in_alphabet() IS '���������� �������, ����������� ��� �������� ��� ������� �������� ����������� ����������� ������������ � �������� ��������� �������. �� ���� ������ ��� ������� ������ ����������� �� �������.';

CREATE TRIGGER tgiu_binary_chracteristic_elements_in_alphabet BEFORE INSERT OR UPDATE ON binary_characteristic FOR EACH ROW EXECUTE PROCEDURE public.trigger_check_elements_in_alphabet();

COMMENT ON TRIGGER tgiu_binary_chracteristic_elements_in_alphabet ON binary_characteristic IS '�������, ����������� ��� ��� �������� ����������� ������������� ����������� ������������ � �������� ������ �������.';


ALTER TABLE chain ADD CONSTRAINT chk_chain_building_starts_from_1 CHECK (building[0] = 1);

CREATE OR REPLACE FUNCTION check_building(arr integer[])
  RETURNS integer AS
$BODY$DECLARE
    element integer;
    max integer := 0;
BEGIN
    FOREACH element IN ARRAY arr
    LOOP
    IF element > max + 1 THEN
        RETURN -1;
    END IF;
    IF element = max + 1 THEN
        max := element;
    END IF;
    END LOOP;
    RETURN max;
END;$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION check_building(integer[])
  OWNER TO postgres;
  
COMMENT ON FUNCTION check_building(integer[]) IS '�������, ����������� ��� ��� �������� ����� ������������� �� ����� ��� �� 1 �� ����������� ������������� ��������. ���������� -1 � ������ ������������� �����. ���� ������ ���, �� ���������� ������������ �������� � �����.';

ALTER TABLE chain ADD CONSTRAINT chk_chain_building_alphabet_length CHECK (check_building(building) = array_length(alphabet, 1));

CREATE OR REPLACE FUNCTION check_alphabet(arr bigint[]) RETURNS boolean AS
$BODY$DECLARE
    elementsExist boolean;
BEGIN
    SELECT count(*) = 0 INTO elementsExist
        FROM element_key e 
        FULL OUTER JOIN unnest($1) c 
        ON c = e.id 
        WHERE e.id IS NULL;
    RETURN elementsExist;
END;$BODY$
LANGUAGE plpgsql VOLATILE NOT LEAKPROOF
COST 100;

COMMENT ON FUNCTION check_alphabet(bigint[]) IS '�������, ����������� ��� ��� �������� �������� ���� � ������� ���������.';

ALTER TABLE chain ADD CONSTRAINT chk_chain_alphabet_in_element CHECK (check_alphabet(alphabet));

CREATE FUNCTION trigger_element_alphabet_delete_bound() RETURNS trigger AS
$BODY$//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);
if (TG_OP == "DELETE"){
    var elementUsedInAlphabet = plv8.execute('SELECT count(*) > 0 result FROM (SELECT DISTINCT unnest(alphabet) a FROM chain) c WHERE c.a = $1)', [OLD.id])[0].result;
    if (elementUsedInAlphabet){
        plv8.elog(ERROR, '���������� ������� �������, �� �� ��� ������������ � �������� ����� ��� ���������� �������. id = ', OLD.id);
    }
    plv8.execute( 'DELETE FROM element_key WHERE id = $1', [OLD.id] );
    return OLD;
} else{
    plv8.elog(ERROR, '����������� ��������. ������ ������� ��������� ������ � ���������� �������� �� ������, ������� ���� id. TG_OP = ', TG_OP);
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.trigger_element_alphabet_delete_bound() IS '���������� �������, ����������� ��� ��������� ������� �� ����������� � ��������� �������.';

CREATE FUNCTION trigger_delete_chain_characteristics() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "DELETE" || TG_OP == "UPDATE"){
    plv8.execute('DELETE FROM characteristic WHERE chain_id = $1', [OLD.id]);
    plv8.execute('DELETE FROM binary_characteristic WHERE chain_id = $1', [OLD.id]);
    plv8.execute('DELETE FROM congeneric_characteristic WHERE chain_id = $1', [OLD.id]);
} else{
    plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� �������� � ��������� ������� � ������� � ����� id.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.trigger_delete_chain_characteristics() IS '���������� �������, ��������� ��� �������������� ��� �������� ��� ��������� �������.';

CREATE TRIGGER tgud_chain_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON chain FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_chain_characteristic_delete ON chain IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';

CREATE TRIGGER tgud_dna_chain_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON dna_chain FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_dna_chain_characteristic_delete ON dna_chain IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';


CREATE TRIGGER tgud_literature_chain_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON literature_chain FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_literature_chain_characteristic_delete ON literature_chain IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';

CREATE TRIGGER tgud_music_chain_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON music_chain FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_music_chain_characteristic_delete ON music_chain IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';

CREATE TRIGGER tgud_fmotiv_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON fmotiv FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_fmotiv_characteristic_delete ON fmotiv IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';

CREATE TRIGGER tgud_measure_characteristic_delete BEFORE UPDATE OF alphabet, building OR DELETE ON measure FOR EACH ROW EXECUTE PROCEDURE public.trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgud_measure_characteristic_delete ON measure IS '�������, ��������� ��� ������������� ������ ������� ��� � ���������� ��� ��������.';

DROP TABLE building;

DROP TABLE alphabet;



-- 25.11.2013

-- ��������� ������� ��� ���������� ������� � ������� �������.

CREATE FUNCTION create_chain(IN id bigint, IN notation_id integer, IN matter_id bigint, IN piece_type_id integer, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_chain(IN bigint, IN integer, IN bigint, IN integer, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� chain.';

CREATE FUNCTION create_dna_chain(IN id bigint, IN notation_id integer, IN matter_id bigint, IN piece_type_id integer, IN fasta_header character varying, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO dna_chain (id, notation_id, creation_date, matter_id, dissimilar,	piece_type_id,	piece_position, fasta_header, alphabet, building) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, fasta_header, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_dna_chain(IN bigint, IN integer, IN bigint, IN integer, IN character varying, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� dna_chain.';

CREATE FUNCTION create_literature_chain(IN id bigint, IN notation_id integer, IN matter_id bigint, IN piece_type_id integer, IN original boolean, IN language_id integer, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO literature_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, original, language_id, alphabet, building) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)',[id, notation_id, creation_date, matter_id, dissimilar,	piece_type_id,	piece_position, original, language_id, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_literature_chain(IN bigint, IN integer, IN bigint, IN integer, IN boolean, IN integer, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� literature_chain.';

CREATE FUNCTION create_music_chain(IN id bigint, IN notation_id integer, IN matter_id bigint, IN piece_type_id integer, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO music_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)',[id, notation_id, creation_date, matter_id, dissimilar,	piece_type_id,	piece_position, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_music_chain(IN bigint, IN integer, IN bigint, IN integer, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� music_chain.';

CREATE FUNCTION create_fmotiv(IN id bigint, IN piece_type_id integer, IN value character varying, IN description character varying, IN name character varying, IN fmotiv_type_id integer, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO fmotiv (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, value, description, name, fmotiv_type_id, alphabet, building) VALUES ($1,6,$2,508,$3,$4,$5,$6,$7,$8,$9,$10,$11)',[id, creation_date, dissimilar, piece_type_id, piece_position, value, description, name, fmotiv_type_id, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_fmotiv(IN bigint, IN integer, IN character varying, IN character varying, IN character varying, IN integer, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� fmotiv.';

CREATE FUNCTION create_measure(IN id bigint, IN piece_type_id integer, IN value character varying, IN description character varying, IN name character varying, IN beats integer,IN beatbase integer,IN ticks_per_beat integer,IN fifths integer, IN major boolean, IN alphabet bigint[], IN building integer[], IN creation_date timestamp with time zone DEFAULT now(), IN piece_position integer DEFAULT 0, IN dissimilar boolean DEFAULT false) RETURNS void AS
$BODY$plv8.execute('INSERT INTO measure (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, value, description, name, beats, beatbase, ticks_per_beat, fifths, major, alphabet, building) VALUES ($1,7,$2,509,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15)',[id, creation_date, dissimilar, piece_type_id, piece_position, value, description, name, beats, beatbase, ticks_per_beat, fifths, major, alphabet, building]);$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION public.create_measure(IN bigint, IN integer, IN character varying, IN character varying, IN character varying, IN integer, IN integer, IN integer, IN integer, IN boolean, IN bigint[], IN integer[], IN timestamp with time zone, IN integer, IN boolean) IS '������� ��� �������� ������� � ������� measure.';

ALTER TABLE fmotiv ALTER COLUMN notation_id SET DEFAULT 6;

ALTER TABLE measure ALTER COLUMN notation_id SET DEFAULT 7;



-- 26.11.2013

-- ������� �������� �������.

DROP FUNCTION create_alphabet_from_string(bigint, text);

DROP FUNCTION create_alphabet(bigint, bigint[]);

DROP FUNCTION create_building_from_string(bigint, text);

DROP FUNCTION create_building(bigint, integer[]);

DROP FUNCTION alphabet_count(bigint);

DROP FUNCTION building_count(bigint);



-- 27.11.2013

-- ���������� ������� �������� ����������� ��.

DROP FUNCTION db_integrity_test();

CREATE OR REPLACE FUNCTION db_integrity_test()
  RETURNS void AS
$BODY$
function CheckChain() {
    plv8.elog(INFO, "��������� ����������� ������� chain (������������ id, ������� �������� � ����� � ���� �������)");

    var chain = plv8.execute('SELECT id FROM chain');
    var chainDistinct = plv8.execute('SELECT DISTINCT id FROM chain');
    if (chain.length != chainDistinct.length) {
        plv8.elog(ERROR, 'id ������� chain �/��� �������� ������ �� ���������.');
    }else{
    plv8.elog(INFO, "id ���� ������� ���������.");
    }

    plv8.elog(INFO, "��������� ������������ ���� ������� ������� chain � � ����������� � �������� � ������� chain_key");
    
    var chainDisproportion = plv8.execute('SELECT c.id, ck.id FROM chain c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL');
    
    if (chainDisproportion.length > 0) {
        plv8.elog(ERROR, '���������� ������� � ������� chain_key �� ��������� � ����������� ������� � ������� chain � � �����������. ��� ������������ ��������� "SELECT c.id, ck.id FROM chain c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL"');
    }else{
    plv8.elog(INFO, "��� ������ � �������� ������� ���������� ������������� ������� � ������� chain_key.");
    }
}

function CheckAlphabet() {
   //TODO: �������� �������� ���� ��� ��� �������� �������� ���� � ������� element ��� � �����������. 
   //TODO: ��������� ��� ��� �������� � ����������� �������������� ��������� ��� ��������� �������������� � ��������.
}

function db_integrity_test() {
    plv8.elog(INFO, "��������� �������� ����������� �� ��������");
    CheckChain();
    CheckAlphabet();
}

db_integrity_test();$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;

COMMENT ON FUNCTION db_integrity_test() IS '������� ��� �������� ����������� ������ � ����.';



-- 28.11.2013

-- �������� �������� � ���� check constraint �� ��������� ��������� ����� 
-- (������ �������� ����������� ������ ��� ����������� ������� alphabet).
-- ������� �������� �������� �� �������.

ALTER TABLE chain DROP CONSTRAINT chk_chain_alphabet_in_element;

DROP FUNCTION check_alphabet(bigint[]);

CREATE FUNCTION trigger_check_alphabet() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
    var plan = plv8.prepare('SELECT count(*) result FROM element_key e INNER JOIN unnest($1) c ON c = e.id;', ['bigint[]']);
    var existingElementsCount = plan.execute([NEW.alphabet])[0].result;
    if(existingElementsCount == NEW.alphabet.length){
        return NEW;
    } else{
        plv8.elog(ERROR, '� �� ����������� ', NEW.alphabet.length - existingElementsCount, '��������� �������� ����������� �������.');
    }
} else{
    plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ����� alphabet.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

COMMENT ON FUNCTION public.trigger_check_alphabet() IS '���������� �������, ����������� ��� ��� �������� �������� ����������� ������� ���� � ����.';



-- 08.12.2013

-- id ��������� �� ���������� �� �������� ������������ � �������.
-- ���������� ���� ����������� id � ��������� �� ��� ������������ �������.
-- �������� ������� �������� ����� �������.

ALTER TABLE chain ADD COLUMN remote_id character varying(255);
ALTER TABLE chain ADD COLUMN remote_db_id integer;
COMMENT ON COLUMN chain.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN chain.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';
ALTER TABLE dna_chain ALTER COLUMN remote_db_id SET DEFAULT 1;
ALTER TABLE dna_chain ADD COLUMN web_api_id integer;
COMMENT ON COLUMN dna_chain.web_api_id IS 'id ������� � �������� ��.';

ALTER TABLE chain ADD CONSTRAINT fk_chain_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE dna_chain ADD CONSTRAINT fk_dna_chain_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE literature_chain ADD CONSTRAINT fk_literature_chain_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE music_chain ADD CONSTRAINT fk_music_chain_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE fmotiv ADD CONSTRAINT fk_fmotiv_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE measure ADD CONSTRAINT fk_measure_remote_db FOREIGN KEY (remote_db_id) REFERENCES remote_db (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE NO ACTION;

UPDATE chain SET chain.remote_id = matter.id_in_remote_db, chain.remote_db_id = matter.remote_db_id FROM matter WHERE chain.matter_id = matter.id;

ALTER TABLE matter DROP CONSTRAINT fk_matter_remote_db;

ALTER TABLE matter DROP COLUMN remote_db_id;
ALTER TABLE matter DROP COLUMN id_in_remote_db;


DROP FUNCTION create_chain(bigint, integer, bigint, integer, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_chain(id bigint, notation_id integer, matter_id bigint, piece_type_id integer, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building, remote_id, remote_db_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_chain(bigint, integer, bigint, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� chain.';


DROP FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_dna_chain(id bigint, notation_id integer, matter_id bigint, piece_type_id integer, fasta_header character varying, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO dna_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, fasta_header, alphabet, building, remote_id, remote_db_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, fasta_header, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� dna_chain.';


DROP FUNCTION create_fmotiv(bigint, integer, character varying, character varying, character varying, integer, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_fmotiv(id bigint, piece_type_id integer, value character varying, description character varying, name character varying, fmotiv_type_id integer, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO fmotiv (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, value, description, name, fmotiv_type_id, alphabet, building, remote_id, remote_db_id) VALUES ($1,6,$2,508,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)',[id, creation_date, dissimilar, piece_type_id, piece_position, value, description, name, fmotiv_type_id, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_fmotiv(bigint, integer, character varying, character varying, character varying, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� fmotiv.';


DROP FUNCTION create_literature_chain(bigint, integer, bigint, integer, boolean, integer, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_literature_chain(id bigint, notation_id integer, matter_id bigint, piece_type_id integer, original boolean, language_id integer, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO literature_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, original, language_id, alphabet, building, remote_id, remote_db_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, original, language_id, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_literature_chain(bigint, integer, bigint, integer, boolean, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� literature_chain.';


DROP FUNCTION create_measure(bigint, integer, character varying, character varying, character varying, integer, integer, integer, integer, boolean, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_measure(id bigint, piece_type_id integer, value character varying, description character varying, name character varying, beats integer, beatbase integer, ticks_per_beat integer, fifths integer, major boolean, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO measure (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, value, description, name, beats, beatbase, ticks_per_beat, fifths, major, alphabet, building, remote_id, remote_db_id) VALUES ($1,7,$2,509,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17)',[id, creation_date, dissimilar, piece_type_id, piece_position, value, description, name, beats, beatbase, ticks_per_beat, fifths, major, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_measure(bigint, integer, character varying, character varying, character varying, integer, integer, integer, integer, boolean, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� measure.';


DROP FUNCTION create_music_chain(bigint, integer, bigint, integer, bigint[], integer[], timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_music_chain(id bigint, notation_id integer, matter_id bigint, piece_type_id integer, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO music_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building, remote_id, remote_db_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, alphabet, building, remote_id, remote_db_id]);$BODY$
  LANGUAGE plv8 VOLATILE COST 100;
COMMENT ON FUNCTION create_music_chain(bigint, integer, bigint, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� music_chain.';

COMMENT ON COLUMN chain.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN chain.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';

COMMENT ON COLUMN dna_chain.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN dna_chain.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';

COMMENT ON COLUMN literature_chain.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN literature_chain.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';

COMMENT ON COLUMN music_chain.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN music_chain.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';

COMMENT ON COLUMN fmotiv.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN fmotiv.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';

COMMENT ON COLUMN measure.remote_id IS 'id ������� � �������� ��.';
COMMENT ON COLUMN measure.remote_db_id IS 'id �������� ���� ������, �� ������� ����� ������ �������.';



-- 12.12.2013

-- ����� �������� �������� web_api_id � ������� ������� �������.

DROP FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);

CREATE OR REPLACE FUNCTION create_dna_chain(id bigint, notation_id integer, matter_id bigint, piece_type_id integer, fasta_header character varying, alphabet bigint[], building integer[], remote_id character varying, remote_db_id integer, web_api_id integer, creation_date timestamp with time zone DEFAULT now(), piece_position integer DEFAULT 0, dissimilar boolean DEFAULT false)
  RETURNS void AS
$BODY$plv8.execute('INSERT INTO dna_chain (id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, fasta_header, alphabet, building, remote_id, remote_db_id, web_api_id) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12, $13)',[id, notation_id, creation_date, matter_id, dissimilar, piece_type_id, piece_position, fasta_header, alphabet, building, remote_id, remote_db_id, web_api_id]);$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;
ALTER FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], character varying, integer, integer, timestamp with time zone, integer, boolean)
  OWNER TO postgres;
COMMENT ON FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], character varying, integer, integer, timestamp with time zone, integer, boolean) IS '������� ��� �������� ������� � ������� dna_chain.';



-- 05.01.2014

-- ��������� ������� �������� � ��������� ��.
-- link_up ������������ � link. �������� �������� � �������� ��������������� �������������.

ALTER TABLE remote_db ADD COLUMN nature_id integer;
ALTER TABLE remote_db ADD CONSTRAINT fk_remote_db_nature FOREIGN KEY (nature_id) REFERENCES nature (id) ON UPDATE NO ACTION ON DELETE NO ACTION;
COMMENT ON COLUMN remote_db.nature_id IS '������� �������� �������� � �������� ��.';
UPDATE remote_db SET nature_id = 1;
ALTER TABLE remote_db ALTER COLUMN nature_id SET NOT NULL;
ALTER TABLE link_up RENAME TO link;
ALTER TABLE binary_characteristic DROP CONSTRAINT fk_binary_characteristic_link_up;
ALTER TABLE characteristic DROP CONSTRAINT fk_characteristic_link_up;
ALTER TABLE congeneric_characteristic DROP CONSTRAINT fk_congeneric_characteristic_link_up;
ALTER TABLE link DROP CONSTRAINT pk_link_ups;
ALTER TABLE link DROP CONSTRAINT uk_link_up_name;
ALTER TABLE link ADD CONSTRAINT pk_link PRIMARY KEY (id);
ALTER TABLE link ADD CONSTRAINT uk_link_name UNIQUE (name);
ALTER TABLE binary_characteristic RENAME link_up_id  TO link_id;
ALTER TABLE binary_characteristic ALTER COLUMN link_id DROP NOT NULL;
COMMENT ON COLUMN binary_characteristic.link_id IS '�������� (���� ��� ������������).';
ALTER TABLE binary_characteristic ADD CONSTRAINT fk_binary_characteristic_link FOREIGN KEY (link_id) REFERENCES link(id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE characteristic RENAME link_up_id  TO link_id;
ALTER TABLE characteristic ALTER COLUMN link_id DROP NOT NULL;
COMMENT ON COLUMN characteristic.link_id IS '�������� (���� ��� ������������).';
ALTER TABLE characteristic ADD CONSTRAINT fk_characteristic_link FOREIGN KEY (link_id) REFERENCES link (id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE congeneric_characteristic RENAME link_up_id  TO link_id;
ALTER TABLE congeneric_characteristic ALTER COLUMN link_id DROP NOT NULL;
COMMENT ON COLUMN congeneric_characteristic.link_id IS '�������� (���� ��� ������������).';
ALTER TABLE congeneric_characteristic ADD CONSTRAINT fk_congeneric_characteristic_link FOREIGN KEY (link_id) REFERENCES link (id) ON UPDATE CASCADE ON DELETE NO ACTION;
ALTER TABLE characteristic_type ADD COLUMN linkable boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN characteristic_type.linkable IS '����, ������������, ����������� �� �������� ��� ���������� ������ ���������������.';

CREATE FUNCTION check_characteristic_linkability(IN characteristic_type_id integer, IN link_id integer) RETURNS boolean AS
$BODY$DECLARE
    result boolean;
BEGIN
    SELECT linkability=(link_id IS NOT NULL) AS result FROM characteristic_type WHERE id = characteristic_type_id;
    RETURN result;
END;$BODY$
LANGUAGE plpgsql VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION check_characteristic_linkability(IN integer, IN integer) IS '�������, �����������, ��� �������� �������������� ����� ��������, ���� ��� �������������� ��������� ��������, ��� �� ����� �������� ���� ��� ���������� �������������� ��� �� ���������.';
ALTER TABLE characteristic ADD CONSTRAINT chk_characteristic_linkability CHECK (check_characteristic_linkability(characteristic_type_id, link_id));
ALTER TABLE binary_characteristic ADD CONSTRAINT chk_binary_characteristic_linkability CHECK (check_characteristic_linkability(characteristic_type_id, link_id));
ALTER TABLE congeneric_characteristic ADD CONSTRAINT chk_congeneric_characteristic_linkability CHECK (check_characteristic_linkability(characteristic_type_id, link_id));
DROP INDEX ix_binary_characteristic_chain_link_up_characteristic_type;
CREATE INDEX ix_binary_characteristic_chain_link_characteristic_type ON binary_characteristic USING btree(chain_id, characteristic_type_id, link_id);
COMMENT ON INDEX ix_binary_characteristic_chain_link_characteristic_type IS '������ ��� ������ �������������� ����������� ������� � ����������� ���������.';
DROP INDEX ix_characteristic_chain_link_up_characteristic_type;
CREATE INDEX ix_characteristic_chain_link_characteristic_type ON characteristic USING btree (chain_id, link_id, characteristic_type_id);
COMMENT ON INDEX ix_characteristic_chain_link_characteristic_type IS '������ �� ��������� �������������.';
DROP INDEX ix_congeneric_characteristic_chain_link_up_congeneric_type;
CREATE INDEX ix_congeneric_characteristic_chain_link_characteristic_type ON congeneric_characteristic USING btree (chain_id, link_id, characteristic_type_id);
COMMENT ON INDEX ix_congeneric_characteristic_chain_link_characteristic_type IS '������ �� ��������� ������������� ���������� �������.';
DROP INDEX ix_congeneric_characteristic_chain_characterisric_linkup_elemen;
CREATE INDEX ix_congeneric_characteristic_chain_characterisric_link_element ON congeneric_characteristic USING btree (chain_id, characteristic_type_id, link_id, element_id);
COMMENT ON INDEX ix_congeneric_characteristic_chain_characterisric_link_element IS '������ ��� ������ ����������� �������������� ����������� �������.';
DROP INDEX ix_link_up_id;
CREATE INDEX ix_link_id ON link USING btree(id);
COMMENT ON INDEX ix_link_id IS '������ ���������� ����� ������� link.';
DROP INDEX ix_link_up_name;
CREATE INDEX ix_link_name ON link USING btree (name);
COMMENT ON INDEX ix_link_name IS '������ �� ������ ��������.';
CREATE SEQUENCE link_id_seq INCREMENT 1 MINVALUE 1 MAXVALUE 9223372036854775807 START 5 CACHE 1;
ALTER SEQUENCE link_id_seq OWNED BY link.id;
ALTER TABLE ONLY link ALTER COLUMN id SET DEFAULT nextval('link_id_seq'::regclass);
DROP SEQUENCE link_up_id_seq;



-- 06.01.2014

-- ���������� ����� � �������, ����������� ������� ������� � ��������� ����� ����� � � ������� ���������.
-- ����� ������� ���������� ������� �������� ���������� ��.


CREATE OR REPLACE FUNCTION db_integrity_test() RETURNS void AS
$BODY$
function CheckChain() {
    plv8.elog(INFO, "��������� ����������� ������� chain (������������ id, ������� �������� � ����� � ���� �������)");

    var chain = plv8.execute('SELECT id FROM chain');
    var chainDistinct = plv8.execute('SELECT DISTINCT id FROM chain');
    if (chain.length != chainDistinct.length) {
        plv8.elog(ERROR, 'id ������� chain �/��� �������� ������ �� ���������.');
    }else{
	plv8.elog(INFO, "id ���� ������� ���������.");
    }

    plv8.elog(INFO, "��������� ������������ ���� ������� ������� chain � � ����������� � �������� � ������� chain_key");
    
    var chainDisproportion = plv8.execute('SELECT c.id, ck.id FROM chain c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL');
    
    if (chainDisproportion.length > 0) {
        plv8.elog(ERROR, '���������� ������� � ������� chain_key �� ��������� � ����������� ������� � ������� chain � � �����������. ��� ������������ ��������� "SELECT c.id, ck.id FROM chain c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL"');
    }else{
	plv8.elog(INFO, "��� ������ � �������� ������� ���������� ������������� ������� � ������� chain_key.");
    }
}

function CheckElement() {
    plv8.elog(INFO, "��������� ����������� ������� element � � �������");

    var element = plv8.execute('SELECT id FROM element');
    var elementDistinct = plv8.execute('SELECT DISTINCT id FROM element');
    if (element.length != elementDistinct.length) {
        plv8.elog(ERROR, 'id ������� element �/��� �������� ������ �� ���������.');
    }else{
	plv8.elog(INFO, "id ���� ��������� ���������.");
    }

    plv8.elog(INFO, "��������� ������������ ���� ������� ������� element � � ����������� � �������� � ������� element_key");
    
    var elementDisproportion = plv8.execute('SELECT c.id, ck.id FROM element c FULL OUTER JOIN element_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL');
    
    if (elementDisproportion.length > 0) {
        plv8.elog(ERROR, '���������� ������� � ������� element_key �� ��������� � ����������� ������� � ������� element � � �����������. ��� ������������ ��������� "SELECT c.id, ck.id FROM element c FULL OUTER JOIN element_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL"');
    }else{
	plv8.elog(INFO, "��� ������ � �������� ��������� ���������� ������������� ������� � ������� element_key.");
    }
}

function CheckAlphabet() {
   //TODO: �������� �������� ���� ��� ��� �������� �������� ���� � ������� element ��� � �����������. 
   //TODO: ��������� ��� ��� �������� � ����������� �������������� ��������� ��� ��������� �������������� � ��������.
}

function db_integrity_test() {
    plv8.elog(INFO, "��������� �������� ����������� �� ��������.");
    CheckChain();
    CheckElement();
    CheckAlphabet();
    plv8.elog(INFO, "�������� ����������� ������� ���������.");
}

db_integrity_test();$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF
COST 100;

CREATE OR REPLACE FUNCTION trigger_element_key_bound()
  RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT"){
	plv8.execute( 'INSERT INTO element_key VALUES ($1)', [NEW.id] );
	return NEW;
}
else if (TG_OP == "UPDATE" && NEW.id != OLD.id){
	plv8.execute( 'UPDATE element_key SET id = $1 WHERE id = $2', [NEW.id, OLD.id] );
	return NEW;
} else if (TG_OP == "DELETE"){
	plv8.execute( 'DELETE FROM element_key WHERE id = $1', [OLD.id] );
	return OLD;
}$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;

COMMENT ON FUNCTION trigger_element_key_bound() IS '���������� ������� ����������� �������� � ��������� �������� (����������, ����������) � �������� element_key.';


ALTER TABLE element DROP CONSTRAINT fk_element_element_key;
ALTER TABLE element ADD CONSTRAINT fk_element_element_key FOREIGN KEY (id) REFERENCES element_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE fmotiv DROP CONSTRAINT fk_fmotiv_element_key;
ALTER TABLE fmotiv ADD CONSTRAINT fk_fmotiv_element_key FOREIGN KEY (id) REFERENCES element_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE measure DROP CONSTRAINT fk_measure_element_key;
ALTER TABLE measure ADD CONSTRAINT fk_measure_element_key FOREIGN KEY (id) REFERENCES element_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE note DROP CONSTRAINT fk_note_element_key;
ALTER TABLE note ADD CONSTRAINT fk_note_element_key FOREIGN KEY (id) REFERENCES element_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

DROP TRIGGER tgd_element_element_key_bound ON element;
DROP TRIGGER tgiu_element_element_key_bound ON element;
CREATE TRIGGER tgiud_element_element_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON element FOR EACH ROW EXECUTE PROCEDURE trigger_element_key_bound();
COMMENT ON TRIGGER tgiud_element_element_key_bound ON element IS '��������� ����������, ��������� � �������� ������� � ������� element � ������� element_key.';

DROP TRIGGER tgd_fmotiv_element_key_bound ON fmotiv;
DROP TRIGGER tgiu_fmotiv_element_key_bound ON fmotiv;
CREATE TRIGGER tgiud_fmotiv_element_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON fmotiv FOR EACH ROW EXECUTE PROCEDURE trigger_element_key_bound();
COMMENT ON TRIGGER tgiud_fmotiv_element_key_bound ON fmotiv IS '��������� ����������, ��������� � �������� ������� � ������� fmotiv � ������� element_key.';

DROP TRIGGER tgd_measure_element_key_bound ON measure;
DROP TRIGGER tgiu_measure_element_key_bound ON measure;
CREATE TRIGGER tgiud_measure_element_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON measure FOR EACH ROW EXECUTE PROCEDURE trigger_element_key_bound();
COMMENT ON TRIGGER tgiud_measure_element_key_bound ON measure IS '��������� ����������, ��������� � �������� ������� � ������� measure � ������� element_key.';

DROP TRIGGER tgd_note_element_key_bound ON note;
DROP TRIGGER tgiu_note_element_key_bound ON note;
CREATE TRIGGER tgiud_note_element_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON note FOR EACH ROW EXECUTE PROCEDURE trigger_element_key_bound();
COMMENT ON TRIGGER tgiud_note_element_key_bound ON note IS '��������� ����������, ��������� � �������� ������� � ������� note � ������� element_key.';

DROP FUNCTION trigger_element_key_delete_bound();

CREATE FUNCTION trigger_element_key_insert() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);
if (TG_OP == "INSERT"){
 var result = plv8.execute('SELECT count(*) = 1 result FROM element WHERE id = $1', [NEW.id])[0].result;
 if (result){
  return NEW;
 }else{
  plv8.elog(ERROR, '������ ��������� ������ � element_key ��� ���������������� ���������� ������ � ������� element ��� � �������. id = ', NEW.id);
 }
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� ������� � ������� � ����� id.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

CREATE TRIGGER tgi_element_key BEFORE INSERT ON element_key FOR EACH ROW EXECUTE PROCEDURE trigger_element_key_insert();

ALTER TABLE chain DROP CONSTRAINT fk_chain_chain_key;
ALTER TABLE chain ADD CONSTRAINT fk_chain_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE dna_chain DROP CONSTRAINT fk_dna_chain_chain_key;
ALTER TABLE dna_chain ADD CONSTRAINT fk_dna_chain_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE fmotiv DROP CONSTRAINT fk_fmotiv_chain_key;
ALTER TABLE fmotiv ADD CONSTRAINT fk_fmotiv_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE literature_chain DROP CONSTRAINT fk_literature_chain_chain_key;
ALTER TABLE literature_chain ADD CONSTRAINT fk_literature_chain_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE measure DROP CONSTRAINT fk_measure_chain_key;
ALTER TABLE measure ADD CONSTRAINT fk_measure_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE music_chain DROP CONSTRAINT fk_music_chain_chain_key;
ALTER TABLE music_chain ADD CONSTRAINT fk_music_chain_chain_key FOREIGN KEY (id) REFERENCES chain_key (id) ON UPDATE NO ACTION ON DELETE NO ACTION DEFERRABLE INITIALLY DEFERRED;

DROP TRIGGER tgd_chain_chain_key_bound ON chain;
DROP TRIGGER tgd_dna_chain_chain_key_bound ON dna_chain;
DROP TRIGGER tgd_fmotiv_chain_key_bound ON fmotiv;
DROP TRIGGER tgd_literature_chain_chain_key_bound ON literature_chain;
DROP TRIGGER tgd_measure_chain_key_bound ON measure;
DROP TRIGGER tgd_music_chain_chain_key_bound ON music_chain;

DROP FUNCTION trigger_chain_key_delete_bound();

DROP TRIGGER tgiu_chain_chain_key_bound ON chain;
DROP TRIGGER tgiu_dna_chain_chain_key_bound ON dna_chain;
DROP TRIGGER tgiu_fmotiv_chain_key_bound ON fmotiv;
DROP TRIGGER tgiu_literature_chain_chain_key_bound ON literature_chain;
DROP TRIGGER tgiu_measure_chain_key_bound ON measure;
DROP TRIGGER tgiu_music_chain_chain_key_bound ON music_chain;

DROP FUNCTION trigger_chain_key_bound();

CREATE OR REPLACE FUNCTION trigger_chain_key_bound()
  RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT"){
	plv8.execute( 'INSERT INTO chain_key VALUES ($1)', [NEW.id] );
	return NEW;
}
else if (TG_OP == "UPDATE" && NEW.id != OLD.id){
	plv8.execute( 'UPDATE chain_key SET id = $1 WHERE id = $2', [NEW.id, OLD.id] );
	return NEW;
} if (TG_OP == "DELETE"){
	plv8.execute( 'DELETE FROM chain_key WHERE id = $1', [OLD.id] );
	return OLD;
}$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;

COMMENT ON FUNCTION trigger_chain_key_bound() IS '���������� ������� ����������� �������� � ��������� �������� (����������, ����������, ��������) � �������� chain_key.';

CREATE TRIGGER tgiud_chain_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON chain FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_chain_chain_key_bound ON chain IS '��������� ����������, ��������� � �������� ������� � ������� chain � ������� chain_key.';

CREATE TRIGGER tgiud_dna_chain_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON dna_chain FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_dna_chain_chain_key_bound ON dna_chain IS '��������� ����������, ��������� � �������� ������� � ������� dna_chain � ������� chain_key.';

CREATE TRIGGER tgiud_fmotiv_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON fmotiv FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_fmotiv_chain_key_bound ON fmotiv IS '��������� ����������, ��������� � �������� ������� � ������� fmotiv � ������� chain_key.';

CREATE TRIGGER tgiud_literature_chain_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON literature_chain FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_literature_chain_chain_key_bound ON literature_chain IS '��������� ����������, ��������� � �������� ������� � ������� literature_chain � ������� chain_key.';

CREATE TRIGGER tgiud_measure_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON measure FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_measure_chain_key_bound ON measure IS '��������� ����������, ��������� � �������� ������� � ������� measure � ������� chain_key.';

CREATE TRIGGER tgiud_music_chain_chain_key_bound AFTER UPDATE OF id OR INSERT OR DELETE ON music_chain FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_bound();
COMMENT ON TRIGGER tgiud_music_chain_chain_key_bound ON music_chain IS '��������� ����������, ��������� � �������� ������� � ������� music_chain � ������� chain_key.';

CREATE FUNCTION trigger_chain_key_insert() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);
if (TG_OP == "INSERT"){
 var result = plv8.execute('SELECT count(*) = 1 result FROM chain WHERE id = $1', [NEW.id])[0].result;
 if (result){
  return NEW;
 }else{
  plv8.elog(ERROR, '������ ��������� ������ � ', TG_TABLE_NAME, ' ��� ���������������� ���������� ������ � ������� chain ��� � �������. id = ', NEW.id);
 }
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� ������� � ������� � ����� id.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;

CREATE TRIGGER tgi_chain_key BEFORE INSERT ON chain_key FOR EACH ROW EXECUTE PROCEDURE trigger_chain_key_insert();
DROP FUNCTION trigger_element_alphabet_delete_bound();
CREATE OR REPLACE FUNCTION trigger_element_delete_alphabet_bound() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);
if (TG_OP == "DELETE"){
	var elementUsedCount = plv8.execute('SELECT count(*) result FROM (SELECT DISTINCT unnest(alphabet) a FROM chain) c WHERE c.a = $1)', [OLD.id])[0].result;
	if (elementUsedCount == 0){
		return OLD;
	} else{
		plv8.elog(ERROR, '���������� ������� �������, �� �� ��� ������������ � �������� ����� ��� ���������� �������. id = ', OLD.id);
	}
	
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������� ��������� ������ � ���������� �������� �� ������, ������� ���� id. TG_OP = ', TG_OP);
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF
COST 100;

CREATE TRIGGER tgd_element_key BEFORE DELETE ON element_key FOR EACH ROW EXECUTE PROCEDURE trigger_element_delete_alphabet_bound();
COMMENT ON TRIGGER tgd_element_key ON element_key IS '���������, �� ������������ �� ��������� ������� � �����-���� ��������.';

CREATE TRIGGER tgiu_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON chain FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_chain_alphabet ON chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE TRIGGER tgiu_dna_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON dna_chain FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_dna_chain_alphabet ON dna_chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE TRIGGER tgiu_fmotiv_alphabet AFTER INSERT OR UPDATE OF alphabet ON fmotiv FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_fmotiv_alphabet ON fmotiv IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE TRIGGER tgiu_literature_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON literature_chain FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_literature_chain_alphabet ON literature_chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE TRIGGER tgiu_measure_alphabet AFTER INSERT OR UPDATE OF alphabet ON measure FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_measure_alphabet ON measure IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE TRIGGER tgiu_music_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON music_chain FOR EACH ROW EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_music_chain_alphabet ON music_chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';
 
CREATE OR REPLACE FUNCTION trigger_element_update_alphabet() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "UPDATE"){
	var oldVal = OLD.id;
	var newVal = NEW.id;
	var chains = plv8.execute('UPDATE chain SET alphabet = c1.alphabet FROM (SELECT c1.id, array_replace(c1.alphabet, $1, $2) alphabet FROM chain c1 WHERE alphabet @> ARRAY[$1]) c1 WHERE chain.id = c1.id;', [OLD.id, NEW.id]);
	return NEW;
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ����� id.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION trigger_element_update_alphabet() IS '������������� ��������� ������� ��� ���������� ���������.';
  
CREATE TRIGGER tgu_element_key AFTER UPDATE ON element_key FOR EACH ROW EXECUTE PROCEDURE trigger_element_update_alphabet();
COMMENT ON TRIGGER tgu_element_key ON element_key IS '������� ����������� ��� ������ � ��������� ������� ��� ������������� ���������. ������������ �������� ����� ��������, �������� ��� �������� ���������������.';



-- 07.01.2014

-- ���� creation_date �� ���� �������� ������������� � created.
-- � �������� ������� ��������� ���� ���� ��������.
-- �� ��� ������������� ������� �������� ���� modified ,� ��������������� ��������, ������������� ��� ������ ��������� ������.

ALTER TABLE note ALTER COLUMN notation_id SET DEFAULT 8;
COMMENT ON COLUMN note.notation_id IS '����� ������. ����������� ����, ������� ������ ��������� �������� 8.';
COMMENT ON COLUMN fmotiv.notation_id IS '����� ������. ����������� ����, ������� ������ ��������� �������� 6.';
COMMENT ON COLUMN measure.notation_id IS '����� ������. ����������� ����, ������� ������ ��������� �������� 7.';


ALTER TABLE matter ADD COLUMN created timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN matter.created IS '���� � ����� �������� ������� ������������.';
ALTER TABLE matter ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN matter.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE pitch ADD COLUMN created timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN pitch.created IS '���� � ����� �������� ������ ����.';
ALTER TABLE pitch ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN pitch.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE chain ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN chain.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE element ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN element.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE binary_characteristic ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN binary_characteristic.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE characteristic ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN characteristic.modified IS '���� � ����� ���������� ��������� ������ � �������.';

ALTER TABLE congeneric_characteristic ADD COLUMN modified timestamp with time zone NOT NULL DEFAULT now();
COMMENT ON COLUMN congeneric_characteristic.modified IS '���� � ����� ���������� ��������� ������ � �������.';

-- ������� � ��������� �������� ������������ ��� ������ ������������� ����� �� ���� ���������
-- �.�. ����� ���������� �������� (� �� �������� ����) ������������� � ��� �������
ALTER TABLE measure NO INHERIT element;
ALTER TABLE fmotiv NO INHERIT element;
ALTER TABLE chain RENAME COLUMN creation_date TO created;
ALTER TABLE element RENAME COLUMN creation_date TO created;
ALTER TABLE measure INHERIT element;
ALTER TABLE fmotiv INHERIT element;

ALTER TABLE congeneric_characteristic RENAME COLUMN creation_date TO created;
ALTER TABLE characteristic RENAME COLUMN creation_date TO created;
ALTER TABLE binary_characteristic RENAME COLUMN creation_date TO created;

COMMENT ON COLUMN note.modified IS '���� � ����� ���������� ��������� ������ � �������.';


CREATE OR REPLACE FUNCTION trigger_set_modified() RETURNS TRIGGER AS $BODY$
    BEGIN
        IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
            NEW.modified := now();
            RETURN NEW;
        END IF;
        RAISE EXCEPTION '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � �������� � ����� modified.';
    END;
$BODY$ LANGUAGE plpgsql;
COMMENT ON FUNCTION trigger_set_modified() IS '���������� �������, ����������� ������� ����� � ���� � ���� modified.';


CREATE TRIGGER tgiu_chain_modified BEFORE INSERT OR UPDATE ON chain FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_chain_modified ON chain IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_binary_characteristic_modified BEFORE INSERT OR UPDATE ON binary_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_binary_characteristic_modified ON binary_characteristic IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_characteristic_modified BEFORE INSERT OR UPDATE ON characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_characteristic_modified ON characteristic IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_congeneric_characteristic_modified BEFORE INSERT OR UPDATE ON congeneric_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_congeneric_characteristic_modified ON congeneric_characteristic IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_dna_chain_modified BEFORE INSERT OR UPDATE ON dna_chain FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_dna_chain_modified ON dna_chain IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_element_modified BEFORE INSERT OR UPDATE ON element FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_element_modified ON element IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_fmotiv_modified BEFORE INSERT OR UPDATE ON fmotiv FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_fmotiv_modified ON fmotiv IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_literature_chain_modified BEFORE INSERT OR UPDATE ON literature_chain FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_literature_chain_modified ON literature_chain IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_matter_modified BEFORE INSERT OR UPDATE ON matter FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_matter_modified ON matter IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_measure_modified BEFORE INSERT OR UPDATE ON measure FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_measure_modified ON measure IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_music_chain_modified BEFORE INSERT OR UPDATE ON music_chain FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_music_chain_modified ON music_chain IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_note_modified BEFORE INSERT OR UPDATE ON note FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_note_modified ON note IS '������ ��� ������� ���� ���������� ��������� ������.';

CREATE TRIGGER tgiu_pitch_modified BEFORE INSERT OR UPDATE ON pitch FOR EACH ROW EXECUTE PROCEDURE trigger_set_modified();
COMMENT ON TRIGGER tgiu_pitch_modified ON pitch IS '������ ��� ������� ���� ���������� ��������� ������.';

-- 09.01.2014

-- id ���� ������� ��������� �� 1 000 000 ����� �������� ����������� � id ���������.
-- ������� ����� ������������������ ��� ������� � ��������� - elements_id_seq.
-- ����� ��������� ������� �� ������� chain_key � element_key.
-- ����� ���� �������� ������������ ��������� ����������� ������� ��������� � �������� ��� ��������� �������������.

CREATE INDEX ix_chain_key ON chain_key (id);
CREATE INDEX ix_element_key ON element_key (id);

CREATE INDEX ix_chain_alphabet ON chain USING gin(alphabet);
CREATE INDEX ix_dna_chain_alphabet ON dna_chain USING gin(alphabet);
CREATE INDEX ix_literature_chain_alphabet ON literature_chain USING gin(alphabet);
CREATE INDEX ix_music_chain_alphabet ON music_chain USING gin(alphabet);
CREATE INDEX ix_fmotiv_alphabet ON fmotiv USING gin(alphabet);
CREATE INDEX ix_measure_alphabet ON measure USING gin(alphabet);

UPDATE chain SET id = id + 1000000;

SELECT setval('elements_id_seq', (SELECT max(id)+1 FROM chain), false);

COMMIT;

-- ��������! ����� ����������� ������ ���������� ,�.�. ��� ���������� ���������� �� ������������ ����������� ��������.

BEGIN;

ALTER TABLE chain ALTER COLUMN id SET DEFAULT nextval('elements_id_seq'::regclass);

DROP SEQUENCE chain_id_seq;

DROP TRIGGER tgiu_binary_chracteristic_elements_in_alphabet ON binary_characteristic;

CREATE TRIGGER tgiu_binary_chracteristic_elements_in_alphabet BEFORE UPDATE OF first_element_id, second_element_id, chain_id OR INSERT ON binary_characteristic FOR EACH ROW  EXECUTE PROCEDURE trigger_check_elements_in_alphabet();
COMMENT ON TRIGGER tgiu_binary_chracteristic_elements_in_alphabet ON binary_characteristic IS '�������, ����������� ��� ��� �������� ����������� ������������� ����������� ������������ � �������� ������ �������.';

DROP TRIGGER tgiu_congeneric_chracteristic_element_in_alphabet ON congeneric_characteristic;

CREATE TRIGGER tgiu_congeneric_chracteristic_element_in_alphabet BEFORE UPDATE OF element_id, chain_id OR INSERT ON congeneric_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_check_element_in_alphabet();
COMMENT ON TRIGGER tgiu_congeneric_chracteristic_element_in_alphabet ON congeneric_characteristic IS '�������, ����������� ��� ������� ���������� �������, ��� ������� ��������� ��������������, ������������ � �������� ������ �������.';

-- 10.01.2014

-- ���������� ��� ������� �������� ��� ������� ��������� �������.

ALTER TABLE chain DROP CONSTRAINT chk_chain_building_starts_from_1;

CREATE OR REPLACE FUNCTION trigger_check_alphabet()
  RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
	var orphanedElements = plv8.execute('SELECT 1 result FROM (SELECT DISTINCT unnest(alphabet) a FROM chain) c LEFT OUTER JOIN element_key e ON e.id = c.a WHERE e.id IS NULL;').length;
	if(orphanedElements == 0){
		return true;
	} else{
		return plv8.elog(ERROR, '� �� ����������� ', orphanedElements, ' ��������� ��������.');
	}
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ����� alphabet.');
}$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;

COMMENT ON FUNCTION trigger_check_alphabet() IS '���������� �������, ����������� ��� ��� �������� �������� ����������� ������� ���� � ����.';

DROP TRIGGER tgiu_chain_alphabet ON chain;
CREATE TRIGGER tgiu_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON chain FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_chain_alphabet ON chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

DROP TRIGGER tgiu_dna_chain_alphabet ON dna_chain;
CREATE TRIGGER tgiu_dna_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON dna_chain FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_dna_chain_alphabet ON dna_chain IS '��������� ������� ���� ��������� �������� � ��.';

DROP TRIGGER tgiu_literature_chain_alphabet ON literature_chain;
CREATE TRIGGER tgiu_literature_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON literature_chain FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_literature_chain_alphabet ON literature_chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

DROP TRIGGER tgiu_music_chain_alphabet ON music_chain;
CREATE TRIGGER tgiu_music_chain_alphabet AFTER INSERT OR UPDATE OF alphabet ON music_chain FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_music_chain_alphabet ON music_chain IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

DROP TRIGGER tgiu_fmotiv_alphabet ON fmotiv;
CREATE TRIGGER tgiu_fmotiv_alphabet AFTER INSERT OR UPDATE OF alphabet ON fmotiv FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_fmotiv_alphabet ON fmotiv IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

DROP TRIGGER tgiu_measure_alphabet ON measure;
CREATE TRIGGER tgiu_measure_alphabet AFTER INSERT OR UPDATE OF alphabet ON measure FOR EACH STATEMENT EXECUTE PROCEDURE trigger_check_alphabet();
COMMENT ON TRIGGER tgiu_measure_alphabet ON measure IS '��������� ������� ���� ��������� ������������ ��� ����������� �������� � ��.';

CREATE INDEX ix_characteristic_created ON characteristic (created);
COMMENT ON INDEX ix_characteristic_created IS '������ �������������� �� ����� �� ����������.';

CREATE INDEX ix_binary_characteristic_created ON binary_characteristic (created);
COMMENT ON INDEX ix_binary_characteristic_created IS '������ �������������� �� ����� �� ����������.';

CREATE INDEX ix_congeneric_characteristic_created ON congeneric_characteristic (created);
COMMENT ON INDEX ix_congeneric_characteristic_created IS '������ �������������� �� ����� �� ����������.';

CREATE OR REPLACE FUNCTION trigger_delete_chain_characteristics() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
	plv8.execute('DELETE FROM characteristic USING chain c WHERE characteristic.chain_id = c.id AND characteristic.created < c.modified;');
	plv8.execute('DELETE FROM binary_characteristic USING chain c WHERE binary_characteristic.chain_id = c.id AND binary_characteristic.created < c.modified;');
	plv8.execute('DELETE FROM congeneric_characteristic USING chain c WHERE congeneric_characteristic.chain_id = c.id AND congeneric_characteristic.created < c.modified;');
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� �������.');
}

$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF
COST 100;

CREATE TRIGGER tgu_chain_characteristics AFTER UPDATE ON chain FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_chain_characteristics ON chain IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE TRIGGER tgu_dna_chain_characteristics AFTER UPDATE ON dna_chain FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_dna_chain_characteristics ON dna_chain IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE TRIGGER tgu_literature_chain_characteristics AFTER UPDATE ON literature_chain FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_literature_chain_characteristics ON literature_chain IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE TRIGGER tgu_music_chain_characteristics AFTER UPDATE ON music_chain FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_music_chain_characteristics ON music_chain IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE TRIGGER tgu_fmotiv_characteristics AFTER UPDATE ON fmotiv FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_fmotiv_characteristics ON fmotiv IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE TRIGGER tgu_measure_characteristics AFTER UPDATE ON measure FOR EACH STATEMENT  EXECUTE PROCEDURE trigger_delete_chain_characteristics();
COMMENT ON TRIGGER tgu_measure_characteristics ON measure IS '������� ��������� ��� ������������� ��� ���������� �������.';

CREATE FUNCTION trigger_characteristics_link() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
	var linkOk = plv8.execute('SELECT linkability=($1 IS NOT NULL) AS result FROM characteristic_type WHERE id = $2;', [NEW.link_id, NEW.characteristic_type_id])[0].result;
	if(linkOk){
		return NEW;
	}
	else{
		plv8.elog(ERROR, '���������� �������������� ����� �������� ��������.');
	}
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ������ characteristic_type_id � link_id');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION trigger_characteristics_link() IS '���������� �������, ����������� ��� � �������������� �� ������ �������� ���� ��� ��������������, � ������ ����� �������� ���� ��� ����������.';

ALTER TABLE binary_characteristic DROP CONSTRAINT chk_binary_characteristic_linkability;
ALTER TABLE characteristic DROP CONSTRAINT chk_characteristic_linkability;
ALTER TABLE congeneric_characteristic DROP CONSTRAINT chk_congeneric_characteristic_linkability;
DROP FUNCTION check_characteristic_linkability(integer, integer);

CREATE TRIGGER tgiu_charaacteristic_link BEFORE INSERT OR UPDATE OF characteristic_type_id, link_id ON characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_characteristics_link();
COMMENT ON TRIGGER tgiu_charaacteristic_link ON characteristic IS '�������, ����������� ������������ ��������.';

CREATE TRIGGER tgiu_binary_charaacteristic_link BEFORE INSERT OR UPDATE OF characteristic_type_id, link_id ON binary_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_characteristics_link();
COMMENT ON TRIGGER tgiu_binary_charaacteristic_link ON binary_characteristic IS '�������, ����������� ������������ ��������.';

CREATE TRIGGER tgiu_congeneric_charaacteristic_link BEFORE INSERT OR UPDATE OF characteristic_type_id, link_id ON congeneric_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_characteristics_link();
COMMENT ON TRIGGER tgiu_congeneric_charaacteristic_link ON congeneric_characteristic IS '�������, ����������� ������������ ��������.';

CREATE FUNCTION trigger_building_check() RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT"){
	var building = NEW.building;
	var max = 0;
	building.forEach(function(element, index){
		if(element > max + 1){
			plv8.elog(ERROR, '�������� ����� �� ��������, ��������� � ', index, '��������.');
		}
		else if(element == max + 1){
			max = element;
		}
	});
	if(max == NEW.alphabet.length){
		return NEW;
	} else{
		plv8.elog(ERROR, '������������ �������� � ����� �� ��������� � ������� ��������.');
	}
	
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� ������� � ������� � ����� building.');
}$BODY$
LANGUAGE plv8 VOLATILE NOT LEAKPROOF;
COMMENT ON FUNCTION trigger_building_check() IS '���������� �������, ����������� ��� ����� ������������� ������������ ������������� �� �����.';

CREATE TRIGGER tgi_chain_building_check BEFORE INSERT  ON chain FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_chain_building_check ON chain IS '�������, ����������� ����� �������.';

CREATE TRIGGER tgi_dna_chain_building_check BEFORE INSERT  ON dna_chain FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_dna_chain_building_check ON dna_chain IS '�������, ����������� ����� �������.';

CREATE TRIGGER tgi_literature_chain_building_check BEFORE INSERT  ON literature_chain FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_literature_chain_building_check ON literature_chain IS '�������, ����������� ����� �������.';

CREATE TRIGGER tgi_music_chain_building_check BEFORE INSERT  ON music_chain FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_music_chain_building_check ON music_chain IS '�������, ����������� ����� �������.';

CREATE TRIGGER tgi_fmotiv_building_check BEFORE INSERT  ON fmotiv FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_fmotiv_building_check ON fmotiv IS '�������, ����������� ����� �������.';

CREATE TRIGGER tgi_measure_building_check BEFORE INSERT  ON measure FOR EACH ROW EXECUTE PROCEDURE trigger_building_check();
COMMENT ON TRIGGER tgi_measure_building_check ON measure IS '�������, ����������� ����� �������.';


-- 12.01.2014

-- ������� ������ � ����������� ������������ �������������.
-- ������ � ������� characteristic_type ���� 3 ������� �����, ������������ ������������ �������������� � ���� ��� ����� ���� �������.

ALTER TABLE characteristic_type ADD COLUMN full_chain_applicable boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN characteristic_type.full_chain_applicable IS '���� ,�����������, ��� ������ �������������� ��������� � ������ ��������.';

ALTER TABLE characteristic_type ADD COLUMN congeneric_chain_applicable boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN characteristic_type.congeneric_chain_applicable IS '���� ,�����������, ��� ������ �������������� ��������� � ���������� ��������.';

ALTER TABLE characteristic_type ADD COLUMN binary_chain_applicable boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN characteristic_type.binary_chain_applicable IS '���� ,�����������, ��� ������ �������������� ��������� � �������� ��������.';

UPDATE characteristic_type SET full_chain_applicable = true WHERE characteristic_applicability_id IN (1,4,5,7);

UPDATE characteristic_type SET congeneric_chain_applicable = true WHERE characteristic_applicability_id IN (2,4,6,7);

UPDATE characteristic_type SET binary_chain_applicable = true WHERE characteristic_applicability_id IN (3,5,6,7);

ALTER TABLE characteristic_type DROP CONSTRAINT fk_characteristic_type_characteristic_applicability;

ALTER TABLE characteristic_type DROP COLUMN characteristic_applicability_id;

DROP TABLE characteristic_applicability;

CREATE OR REPLACE FUNCTION trigger_check_applicability()
  RETURNS trigger AS
$BODY$
//plv8.elog(NOTICE, "TG_TABLE_NAME = ", TG_TABLE_NAME);
//plv8.elog(NOTICE, "TG_OP = ", TG_OP);
//plv8.elog(NOTICE, "NEW = ", JSON.stringify(NEW));
//plv8.elog(NOTICE, "OLD = ", JSON.stringify(OLD));
//plv8.elog(NOTICE, "TG_ARGV = ", TG_ARGV);

if (TG_OP == "INSERT" || TG_OP == "UPDATE"){
	var applicabilityOk = plv8.execute('SELECT ', ARGV[0], ' AS result FROM characteristic_type WHERE id = $1;', [NEW.characteristic_type_id])[0].result;
	if(applicabilityOk){
		return NEW;
	}
	else{
		plv8.elog(ERROR, '���������� �������������� ����������� � ������� ���� �������.');
	}
} else{
	plv8.elog(ERROR, '����������� ��������. ������ ������ ������������ ������ ��� �������� ���������� � ��������� ������� � ������� � ������ characteristic_type_id.');
}$BODY$
  LANGUAGE plv8 VOLATILE
  COST 100;

COMMENT ON FUNCTION trigger_check_applicability() IS '���������� �������, �����������, ��� �������������� ����� ���� ��������� ��� ������ ���� �������';


CREATE TRIGGER tgiu_characteristic_applicability BEFORE INSERT OR UPDATE OF characteristic_type_id ON characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_check_applicability('full_chain_applicable');
COMMENT ON TRIGGER tgiu_characteristic_applicability ON characteristic IS '�������, ����������� ��������� �� ��������� �������������� � ������ ��������.';

CREATE TRIGGER tgiu_binary_characteristic_applicability BEFORE INSERT OR UPDATE OF characteristic_type_id ON binary_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_check_applicability('binary_chain_applicable');
COMMENT ON TRIGGER tgiu_binary_characteristic_applicability ON binary_characteristic IS '�������, ����������� ��������� �� ��������� �������������� � �������� ��������.';

CREATE TRIGGER tgiu_congeneric_characteristic_applicability BEFORE INSERT OR UPDATE OF characteristic_type_id ON congeneric_characteristic FOR EACH ROW EXECUTE PROCEDURE trigger_check_applicability('congeneric_chain_applicable');
COMMENT ON TRIGGER tgiu_congeneric_characteristic_applicability ON congeneric_characteristic IS '�������, ����������� ��������� �� ��������� �������������� � ���������� ��������.';

ALTER TABLE characteristic_type ADD CONSTRAINT chk_characteristic_applicable CHECK (full_chain_applicable OR binary_chain_applicable OR congeneric_chain_applicable);
COMMENT ON CONSTRAINT chk_characteristic_applicable ON characteristic_type IS '��������� ��� �������������� ��������� ���� �� � ������ ���� �������.';


-- 19.01.2014

-- ������ ��������������� ������������� � characteristic_type

UPDATE characteristic_type SET linkable = false WHERE id IN (1,4,5,6,12,15,16);


-- 22.01.2014

-- ��������� ���� �������� ��� ��������� � ������� � �� ����.
-- ������� �������� �������� �������.

UPDATE element SET created = modified WHERE created IS NULL;
ALTER TABLE element ALTER COLUMN created SET NOT NULL;
COMMENT ON COLUMN element.created IS '���� �������� ������.';

DROP FUNCTION create_chain(bigint, integer, bigint, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);
DROP FUNCTION create_dna_chain(bigint, integer, bigint, integer, character varying, bigint[], integer[], character varying, integer, integer, timestamp with time zone, integer, boolean);
DROP FUNCTION create_fmotiv(bigint, integer, character varying, character varying, character varying, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);
DROP FUNCTION create_literature_chain(bigint, integer, bigint, integer, boolean, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);
DROP FUNCTION create_measure(bigint, integer, character varying, character varying, character varying, integer, integer, integer, integer, boolean, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);
DROP FUNCTION create_music_chain(bigint, integer, bigint, integer, bigint[], integer[], character varying, integer, timestamp with time zone, integer, boolean);


-- 23.01.2014

-- ������� ������ ��������, ������� � �����.

ALTER TABLE chain DROP CONSTRAINT chk_chain_building_alphabet_length;
DROP FUNCTION check_building(integer[]);
DROP TRIGGER tgud_chain_characteristic_delete ON chain;
DROP TRIGGER tgud_dna_chain_characteristic_delete ON dna_chain;
DROP TRIGGER tgud_fmotiv_characteristic_delete ON fmotiv;
DROP TRIGGER tgud_literature_chain_characteristic_delete ON literature_chain;
DROP TRIGGER tgud_measure_characteristic_delete ON measure;
DROP TRIGGER tgud_music_chain_characteristic_delete ON music_chain;


-- 25.01.2014

-- ��������� �������� �������: ���� ������� �������� ��, �� ������ ���� ������ id � ���� ��,
-- ���� �� �� �� ������� �� � ���������� id ���� �� ������.
-- ����� ������� �� ������ ������ ������� seq_next_value.

ALTER TABLE chain ADD CONSTRAINT chk_remote_id CHECK ((remote_db_id IS NULL AND remote_id IS NULL) OR (remote_db_id IS NOT NULL AND remote_id IS NOT NULL));
DROP FUNCTION seq_next_value(text);

COMMIT;