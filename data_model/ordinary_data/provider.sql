


CREATE TABLE signalo_od.provider
(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v1(),
    active boolean default true,
    name text,
    _inserted_date timestamp default now(),
    _inserted_user text,
    _last_modified_date timestamp default now(),
    _last_modified_user text
);

INSERT INTO signalo_od.provider (name) VALUES ('L. Ellgass SA');
INSERT INTO signalo_od.provider (name) VALUES ('Signal SA');
INSERT INTO signalo_od.provider (name) VALUES ('BO-Plastiline SA');