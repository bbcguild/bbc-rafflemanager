CREATE TABLE guilds (
    guild_id INTEGER PRIMARY KEY,   -- standard ID
    guild_name TEXT,                -- name of the guild (i.e., Akaviri Union)
    guild_shortname TEXT,           -- shortname of the guild (i.e., Union)
    guild_roster TEXT,              -- CSV of guild roster for autocomplete
    guild_eso_id TEXT,              -- ESO guild id for bank-export matching
    guild_expected_mail_accounts TEXT, -- comma-separated ESO accounts expected for mail imports
    guild_import_blacklist TEXT,     -- comma-separated ESO account names to ignore for mail/bank imports
    guild_timezone TEXT,            -- official guild timezone, e.g. America/New_York
    guild_game_server TEXT,         -- official game server, e.g. PC-NA
    guild_logo_url TEXT,            -- guild logo / emblem image URL
    guild_favicon_url TEXT,         -- browser favicon / tab icon URL
    guild_primary_color TEXT,       -- primary guild brand color
    guild_accent_color TEXT,        -- accent guild brand color
    guild_sister_guilds TEXT        -- comma-separated related guild shortnames
  );

CREATE TABLE raffles (
    raffle_id INTEGER PRIMARY KEY,  -- each raffle has its own ID
    raffle_guild INTEGER,           -- reference guilds.guild_id
    raffle_guild_num INTEGER,       -- increment +1 per guild for external uses
    raffle_opened_at INTEGER,       -- when this raffle week was opened
    raffle_time TEXT,               -- time information for raffle
    raffle_ticket_cost TEXT,        -- cost information per raffle ticket
    raffle_closed INTEGER,          -- boolean value, closed raffles are considered archived
    raffle_notes TEXT,              -- public note box 1
    raffle_title TEXT,              -- public raffle title / status headline
    raffle_status TEXT,             -- LIVE / ROLLING / COMPLETE
    raffle_barter_enabled INTEGER DEFAULT 0, -- whether barter is active for this raffle
    raffle_gold_mail_enabled INTEGER DEFAULT 1, -- whether mailed gold counts for this raffle
    raffle_gold_bank_enabled INTEGER DEFAULT 1, -- whether banked gold counts for this raffle
    raffle_barter_mail_enabled INTEGER DEFAULT 0, -- whether mailed barter items count for this raffle
    raffle_barter_bank_enabled INTEGER DEFAULT 0, -- whether banked barter items count for this raffle
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
    ticket_updated_by_auth INTEGER, -- auth user who last changed this ticket row
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
    auth_password TEXT,
    auth_must_change_password INTEGER DEFAULT 0,
    auth_timezone TEXT,
    auth_datetime_format TEXT DEFAULT 'us_12'
);

CREATE TABLE auth_user_roles (
    auth_user_role_id INTEGER PRIMARY KEY,
    auth_user INTEGER NOT NULL,
    auth_role TEXT NOT NULL,
    auth_guild INTEGER,
    CONSTRAINT uniq_auth_role UNIQUE (auth_user, auth_role, auth_guild)
);

CREATE TABLE imports (
    import_id INTEGER PRIMARY KEY,
    import_uid TEXT,
    import_timestamp TEXT,
    import_skipped INTEGER,
    import_guild INTEGER
);

CREATE TABLE barter_bounty_items (
    barter_bounty_item_id INTEGER PRIMARY KEY,
    barter_bounty_guild INTEGER NOT NULL,
    barter_bounty_item_name TEXT NOT NULL,
    barter_bounty_item_code TEXT NOT NULL,
    barter_bounty_quantity INTEGER NOT NULL DEFAULT 1,
    barter_bounty_value INTEGER NOT NULL DEFAULT 0,
    barter_bounty_rate INTEGER NOT NULL DEFAULT 0,
    barter_bounty_sort INTEGER NOT NULL DEFAULT 0,
    barter_bounty_active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE raffle_bounty_items (
    raffle_bounty_item_id INTEGER PRIMARY KEY,
    raffle_bounty_raffle INTEGER NOT NULL,
    raffle_bounty_source_item INTEGER,
    raffle_bounty_item_name TEXT NOT NULL,
    raffle_bounty_item_code TEXT NOT NULL,
    raffle_bounty_quantity INTEGER NOT NULL DEFAULT 1,
    raffle_bounty_value INTEGER NOT NULL DEFAULT 0,
    raffle_bounty_rate INTEGER NOT NULL DEFAULT 0,
    raffle_bounty_sort INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE barter_entries (
    barter_entry_id INTEGER PRIMARY KEY,
    barter_entry_raffle INTEGER NOT NULL,
    barter_entry_guild INTEGER NOT NULL,
    barter_entry_user INTEGER NOT NULL,
    barter_entry_source_type TEXT NOT NULL,      -- MAIL / BANK
    barter_entry_source_uid TEXT NOT NULL,       -- unique source event id from addon/import
    barter_entry_source_timestamp INTEGER NOT NULL,
    barter_entry_item_name TEXT NOT NULL,
    barter_entry_item_code TEXT NOT NULL,
    barter_entry_quantity INTEGER NOT NULL DEFAULT 0,
    barter_entry_item_value INTEGER NOT NULL DEFAULT 0,
    barter_entry_rate INTEGER NOT NULL DEFAULT 0,
    barter_entry_ticket_count INTEGER NOT NULL DEFAULT 0,
    barter_entry_import_uid TEXT,
    CONSTRAINT uniq_barter_entry UNIQUE (barter_entry_raffle, barter_entry_source_type, barter_entry_source_uid, barter_entry_item_code)
);
