create table "user" (
    user_id uuid primary key
    ,access_token_hash bytea
    ,line_id text
    ,user_name_in_line text
)
