BEGIN;

-- 31.09.2014
-- ��������� � ������������� ��������� ��������������.

UPDATE characteristic_type SET class_name = 'AverageRemotenessDispersion' WHERE id = 28;
UPDATE characteristic_type SET class_name = 'AverageRemotenessStandardDeviation' WHERE id = 29;
UPDATE characteristic_type SET class_name = 'AverageRemotenessSkewness' WHERE id = 30;

INSERT INTO characteristic_type (name, description, characteristic_group_id, class_name, linkable, full_chain_applicable, congeneric_chain_applicable, binary_chain_applicable) VALUES ('������������� ���������� ������� ������������', '����������� ���������� (�����������) ������������� ������� ������������ ���������� �����', NULL, 'NormalizedAverageRemotenessSkewness', true, true, false, false);
INSERT INTO characteristic_type (name, description, characteristic_group_id, class_name, linkable, full_chain_applicable, congeneric_chain_applicable, binary_chain_applicable) VALUES ('����������� ������������', '����������� ������������ ���� ���������� ����� ���� �����', NULL, 'ComplianceDegree', false, false, false, true);

-- 06.09.2014
-- ��������� ������� �� ����.

CREATE INDEX ix_piece_id ON piece (id ASC NULLS LAST);
CREATE INDEX ix_piece_gene_id ON piece (gene_id ASC NULLS LAST);

-- 05.10.2014
-- �������� ����� ��� ���.

INSET INTO piece_type (name, description, nature_id) VALUES ('��������� ���', 'misc_RNA - miscellaneous other RNA', 1)

-- 24.12.2014
-- Updating db_integrity_test function.

DROP FUNCTION db_integrity_test();

CREATE OR REPLACE FUNCTION db_integrity_test()
  RETURNS void AS
$BODY$
function CheckChain() {
    plv8.elog(INFO, "��������� ����������� ������� chain � � ��������.");

    var chain = plv8.execute('SELECT id FROM chain');
    var chainDistinct = plv8.execute('SELECT DISTINCT id FROM chain');
    if (chain.length != chainDistinct.length) {
        plv8.elog(ERROR, 'id ������� chain �/��� �������� ������ �� ���������.');
    }else{
		plv8.elog(INFO, "id ���� ������� ���������.");
    }
	
    plv8.elog(INFO, "��������� ������������ ���� ������� ������� chain � � ����������� � �������� � ������� chain_key.");
    
    var chainDisproportion = plv8.execute('SELECT c.id, ck.id FROM (SELECT id FROM chain UNION SELECT id FROM gene) c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL');
    
    if (chainDisproportion.length > 0) {
		var debugQuery = 'SELECT c.id chain_id, ck.id chain_key_id FROM (SELECT id FROM chain UNION SELECT id FROM gene) c FULL OUTER JOIN chain_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL';
        plv8.elog(ERROR, '���������� ������� � ������� chain_key �� ��������� � ����������� ������� � ������� chain � � �����������. ��� ������������ ��������� "', debugQuery, '".');
    }else{
		plv8.elog(INFO, "��� ������ � �������� ������� ���������� ������������� ������� � ������� chain_key.");
    }
	
	plv8.elog(INFO, '������� ������� ������� ���������.');
}

function CheckElement() {
    plv8.elog(INFO, "��������� ����������� ������� element � � ��������.");

    var element = plv8.execute('SELECT id FROM element');
    var elementDistinct = plv8.execute('SELECT DISTINCT id FROM element');
    if (element.length != elementDistinct.length) {
        plv8.elog(ERROR, 'id ������� element �/��� �������� ������ �� ���������.');
    }else{
		plv8.elog(INFO, "id ���� ��������� ���������.");
    }

    plv8.elog(INFO, "��������� ������������ ���� ������� ������� element � � ����������� � �������� � ������� element_key.");
    
    var elementDisproportion = plv8.execute('SELECT c.id, ck.id FROM element c FULL OUTER JOIN element_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL');
    
    if (elementDisproportion.length > 0) {
		var debugQuery = 'SELECT c.id, ck.id FROM element c FULL OUTER JOIN element_key ck ON ck.id = c.id WHERE c.id IS NULL OR ck.id IS NULL';
        plv8.elog(ERROR, '���������� ������� � ������� element_key �� ��������� � ����������� ������� � ������� element � � �����������. ��� ������������ ��������� "', debugQuery,'"');
    }else{
		plv8.elog(INFO, "��� ������ � �������� ��������� ���������� ������������� ������� � ������� element_key.");
    }
	
	plv8.elog(INFO, '������� ��������� ������� ���������.');
}

function CheckAlphabet() {
	plv8.elog(INFO, '��������� �������� ���� �������.');
	
	var orphanedElements = plv8.execute('SELECT c.a FROM (SELECT DISTINCT unnest(alphabet) a FROM chain) c LEFT OUTER JOIN element_key e ON e.id = c.a WHERE e.id IS NULL');
	if (orphanedElements.length > 0) { 
		var debugQuery = 'SELECT c.a FROM (SELECT DISTINCT unnest(alphabet) a FROM chain) c LEFT OUTER JOIN element_key e ON e.id = c.a WHERE e.id IS NULL';
		plv8.elog(ERROR, '� �� ����������� ', orphanedElements,' ��������� ��������. ��� ������������ ��������� "', debugQuery,'".');
	}
	else {
		plv8.elog(INFO, '��� �������� ���� ��������� ������������ � ������� element_key.');
	}
	
	//TODO: ��������� ��� ��� �������� � ����������� �������������� ��������� ��� ��������� �������������� � ��������.
	plv8.elog(INFO, '��� �������� ������� ������� ���������.');
}

function db_integrity_test() {
    plv8.elog(INFO, "��������� �������� ����������� �� ��������.");
    CheckChain();
    CheckElement();
    CheckAlphabet();
    plv8.elog(INFO, "�������� ����������� ������� ���������.");
}

db_integrity_test();
$BODY$
  LANGUAGE plv8 VOLATILE;

COMMENT ON FUNCTION db_integrity_test() IS '������� ��� �������� ����������� ������ � ����.';

-- 26.12.2014
-- Deleted dissimilar column

ALTER TABLE chain DROP COLUMN dissimilar;

-- 05.01.2015
-- Changed none link id to 0.

UPDATE link set id = 0 WHERE id = 5;

-- 10.01.2015
-- Renamed complement into complementary.

ALTER TABLE dna_chain RENAME COLUMN complement TO complementary;
ALTER TABLE gene RENAME COLUMN complement TO complementary;

COMMIT;