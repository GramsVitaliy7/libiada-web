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

COMMIT;