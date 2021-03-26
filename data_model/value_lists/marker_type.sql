


CREATE TABLE siro_vl.marker_type
(
  id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  active boolean default true,
  value_de text,
  value_fr text,
  value_it text,
  value_ro text
);

INSERT INTO siro_vl.marker_type (id, value_de, value_fr, value_it, value_ro) VALUES (1, 'TBD', 'inconnu', 'TBD', 'TBD');
INSERT INTO siro_vl.marker_type (id, value_de, value_fr, value_it, value_ro) VALUES (2, 'TBD', 'autre', 'TBD', 'TBD');
INSERT INTO siro_vl.marker_type (id, value_de, value_fr, value_it, value_ro) VALUES (3, 'to be determined', 'à déterminer', 'to be determined', 'TBD');

INSERT INTO siro_vl.marker_type (id, value_de, value_fr, value_it, value_ro) VALUES (11, 'TBD', 'balise 1', 'TBD', 'TBD');
INSERT INTO siro_vl.marker_type (id, value_de, value_fr, value_it, value_ro) VALUES (12, 'TBD', 'balise 2', 'TBD', 'TBD');