CREATE TABLE guilds (
    guild_id INTEGER PRIMARY KEY,   -- standard ID
    guild_name TEXT,                -- name of the guild (i.e., Akaviri Union)
    guild_shortname TEXT,           -- shortname of the guild (i.e., Union)
    guild_roster TEXT               -- CSV of guild roster for autocomplete
);

CREATE TABLE raffles (
    raffle_id INTEGER PRIMARY KEY,  -- each raffle has its own ID
    raffle_guild INTEGER,           -- reference guilds.guild_id
    raffle_guild_num INTEGER,       -- increment +1 per guild for external uses
    raffle_time TEXT,               -- time information for raffle
    raffle_ticket_cost TEXT,        -- cost information per raffle ticket
    raffle_closed INTEGER,          -- boolean value, closed raffles are considered archived
    raffle_notes TEXT,              -- public note box 1
    raffle_title TEXT,              -- public raffle title / status headline
    raffle_status TEXT,             -- LIVE / ROLLING / COMPLETE
    raffle_notes_admin TEXT,        -- admin-only notes
    raffle_notes_public_2 TEXT      -- public note box 2
);

CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    user_name TEXT
);

CREATE TABLE tickets (
    ticket_id INTEGER PRIMARY KEY,  -- unique id
    ticket_raffle INTEGER not null, -- references raffles.raffle_id
    ticket_user INTEGER not null,   -- references users.user_id
    ticket_count INTEGER,           -- number of tickets TOTAL; set to 0 for deletions
    ticket_timestamp INTEGER,       -- last touched
    ticket_free INTEGER not null,   -- number of free tickets
    ticket_barter INTEGER not null, -- number of barter tickets
    CONSTRAINT uniq_raf_user UNIQUE (ticket_user, ticket_raffle)
);

CREATE TABLE prizes (
    prize_id INTEGER PRIMARY KEY,   -- unique id
    prize_raffle INTEGER,           -- references the raffle it's associated with
    prize_text TEXT,                -- text related to the prize
    prize_text2 TEXT,               -- prize number (this is sorted)
    prize_winner INTEGER,           -- references the "winning" ticket, not won unless finalised
    prize_finalised INTEGER,        -- boolean value, true if prize is officially won
    prize_value INTEGER,            -- optional numeric value for the prize
    prize_style TEXT DEFAULT 'standard', -- visual emphasis tier
    prize_sort INTEGER DEFAULT 0   -- explicit display order for prize cards
);

CREATE TABLE auth_users (
    auth_id INTEGER PRIMARY KEY,
    auth_name TEXT,
    auth_password TEXT
);

CREATE TABLE imports (
    import_id INTEGER PRIMARY KEY,
    import_uid TEXT,
    import_timestamp TEXT,
    import_skipped INTEGER,
    import_guild INTEGER
);
