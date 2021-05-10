


CREATE TABLE siro_od.provider
(
    id uuid PRIMARY KEY DEFAULT uuid_generate_v1(),
    name text,
    _inserted_date timestamp default now(),
    _inserted_user text,
    _last_modified_date timestamp default now(),
    _last_modified_user text
);

INSERT INTO siro_od.owner (name) VALUES ('signal');