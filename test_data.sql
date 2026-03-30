PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE guilds (
    guild_id INTEGER PRIMARY KEY,   -- standard ID
    guild_name TEXT,                -- name of the guild (i.e., Akaviri Union)
    guild_shortname TEXT,           -- shortname of the guild (i.e., Union)
    guild_roster TEXT               -- CSV of guild roster for autocomplete
);
INSERT INTO "guilds" VALUES(1,'Akaviri Exchange','Exchange','nooblybear,nogoattaco');
INSERT INTO "guilds" VALUES(2,'Akaviri Union','Union','nooblybear,xLUCIANx');
INSERT INTO "guilds" VALUES(3,'Akaviri Imports','Imports','nooblybear,Cyanfire700');
CREATE TABLE raffles (
    raffle_id INTEGER PRIMARY KEY,  -- each raffle has its own ID
    raffle_guild INTEGER,           -- reference guilds.guild_id
    raffle_guild_num INTEGER,       -- increment +1 per guild for external uses
    raffle_time TEXT,               -- time information for raffle
    raffle_ticket_cost TEXT,        -- cost information per raffle ticket
    raffle_closed INTEGER           -- boolean value, closed raffles are considered archived
);
INSERT INTO "raffles" VALUES(1,1,1,'11pm EDT, Sunday 29th September','1000g',0);
INSERT INTO "raffles" VALUES(2,2,1,'10pm EDT, Sunday 29th September','1000g',0);
INSERT INTO "raffles" VALUES(3,3,1,'1am EDT, Sunday 29th September','1000g',0);
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    user_name TEXT
);
INSERT INTO "users" VALUES(1,'nooblybear');
INSERT INTO "users" VALUES(2,'nogoattaco');
INSERT INTO "users" VALUES(3,'xLUCIANx');
INSERT INTO "users" VALUES(4,'Cyanfire700');
CREATE TABLE auth_users (
    auth_id INTEGER PRIMARY KEY,
    auth_name TEXT,
    auth_password TEXT
);
INSERT INTO "auth_users" VALUES(1,'nooblybear','$2a$12$nHXzht3Il7E5EYKHUdZNyeHafeZeuEaaqevqaxDagtfwV5/VaHDTy');
CREATE TABLE prizes (
    prize_id INTEGER PRIMARY KEY,   -- unique id
    prize_raffle INTEGER,           -- references the raffle it's associated with
    prize_text TEXT,                -- text related to the prize
    prize_text2 TEXT,               -- any secondary text
    prize_winner INTEGER,           -- references the "winning" ticket, not won unless finalised
    prize_finalised INTEGER         -- boolean value, true if prize is officially won
);
INSERT INTO "prizes" VALUES(1,1,'1000 Tempering Alloy','1',0,0);
INSERT INTO "prizes" VALUES(2,1,'500 Tempering Alloy','2',0,0);
INSERT INTO "prizes" VALUES(3,1,'150 Tempering Alloy','3',0,0);
INSERT INTO "prizes" VALUES(4,2,'100 dreugh wax','1',0,0);
INSERT INTO "prizes" VALUES(5,2,'50 kuta','2',0,0);
INSERT INTO "prizes" VALUES(6,2,'10 rekuta','3',0,0);
INSERT INTO "prizes" VALUES(7,3,'100 Each Gold Temper','1',0,0);
INSERT INTO "prizes" VALUES(8,3,'10 Fort and Potent Nirn','2',0,0);
INSERT INTO "prizes" VALUES(9,3,'50k gold','3',0,0);
INSERT INTO "prizes" VALUES(10,3,'20k shopping spree','4',0,0);
CREATE TABLE tickets (
    ticket_id INTEGER PRIMARY KEY,  -- unique id
    ticket_raffle INTEGER not null, -- references raffles.raffle_id
    ticket_user INTEGER not null,   -- references users.user_id
    ticket_count INTEGER,           -- number of tickets TOTAL; set to 0 for deletions
    ticket_timestamp INTEGER,       -- last touched
    CONSTRAINT uniq_raf_user UNIQUE (ticket_user, ticket_raffle)
);
INSERT INTO "tickets" VALUES(1,1,1,10,0);
INSERT INTO "tickets" VALUES(2,2,1,10,0);
INSERT INTO "tickets" VALUES(3,3,1,10,0);
INSERT INTO "tickets" VALUES(4,1,2,10,0);
INSERT INTO "tickets" VALUES(5,2,2,10,0);
INSERT INTO "tickets" VALUES(6,3,2,10,0);
INSERT INTO "tickets" VALUES(7,1,3,10,0);
INSERT INTO "tickets" VALUES(8,2,3,10,0);
INSERT INTO "tickets" VALUES(9,3,3,10,0);
INSERT INTO "tickets" VALUES(10,1,4,10,0);
INSERT INTO "tickets" VALUES(11,2,4,10,0);
INSERT INTO "tickets" VALUES(12,3,4,10,0);
COMMIT;
