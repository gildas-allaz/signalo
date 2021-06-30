

CREATE TABLE signalo_vl.support_base_type
(
  id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  active boolean default true,
  value_en text,
  value_fr text,
  value_de text
);

INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (1, 'unknown', 'inconnu', 'unknown');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (2, 'other', 'autre', 'other');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (3, 'to be determined', 'à déterminer', 'to be determined');


INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (11, 'tubular metal socket', 'douille métallique tubulaire', 'tubular metal socket');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (12, 'tubular metal socket with blades', 'douille métallique tubulaire à ailettes', 'tubular metal socket with blades');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (13, 'Drilled socket', 'douille forée', 'Drilled socket');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (14, 'mounting flange with socket', 'Flasque de fixation avec douille', 'mounting flange with socket');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (15, 'prefabricated concrete', 'préfabriquée en béton', 'prefabricated concrete');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (16, 'SPCH–Type 3', 'SPCH–Type 3', 'SPCH–Type 3');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (17, 'SPCH–Type 4', 'SPCH–Type 4', 'SPCH–Type 4');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (18, 'SPCH-Type 5', 'SPCH-Type 5', 'SPCH-Type 5');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (19, 'SPCH-Type 6', 'SPCH-Type 6', 'SPCH-Type 6');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (20, 'OFROU-Type A', 'OFROU-Type A', 'OFROU-Type A');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (21, 'OFROU-Type B', 'OFROU-Type B', 'OFROU-Type B');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (22, 'OFROU-Type C', 'OFROU-Type C', 'OFROU-Type C');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (23, 'OFROU-Type D', 'OFROU-Type D', 'OFROU-Type D');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (24, 'OFROU-Type E', 'OFROU-Type E', 'OFROU-Type E');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (25, 'OFROU-Type F', 'OFROU-Type F', 'OFROU-Type F');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (26, 'OFROU-Type 100', 'OFROU-Type 100', 'OFROU-Type 100');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (27, 'OFROU-Type 150', 'OFROU-Type 150', 'OFROU-Type 150');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (28, 'OFROU-Type 200', 'OFROU-Type 200', 'OFROU-Type 200');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (29, 'OFROU-Type 250', 'OFROU-Type 250', 'OFROU-Type 250');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (30, 'OFROU-Type 300', 'OFROU-Type 300', 'OFROU-Type 300');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (31, 'OFROU-Type 300 DS', 'OFROU-Type 300 DS', 'OFROU-Type 300 DS');
INSERT INTO signalo_vl.support_base_type (id, value_en, value_fr, value_de) VALUES (32, 'Slide post', 'Poteau de glissière', 'Slide post');