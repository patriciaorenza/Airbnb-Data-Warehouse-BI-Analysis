-- Airbnb star schema (PostgreSQL)
-- Drop in reverse dependency order so the script can be re-run
DROP TABLE IF EXISTS listingsales_facttable;
DROP TABLE IF EXISTS location_dimension;
DROP TABLE IF EXISTS roomtype_dimension;
DROP TABLE IF EXISTS host_dimension;
DROP TABLE IF EXISTS minnights_dimension;
DROP TABLE IF EXISTS tourism_dimension;

-- External dimension: state tourism consumption (one row per state)
CREATE TABLE tourism_dimension (
    TouristKey                   INTEGER      PRIMARY KEY,
    state_abrv                   VARCHAR(3)   NOT NULL UNIQUE,
    tourism_consumption_billion  NUMERIC(8,2) NOT NULL,
    year                         VARCHAR(10)  NOT NULL   -- e.g. '2024-25'
);

CREATE TABLE location_dimension (
    LocationKey    INTEGER       PRIMARY KEY,
    state          VARCHAR(50)   NOT NULL,
    state_abrv     VARCHAR(3)    NOT NULL,
    region         VARCHAR(60)   NOT NULL,
    neighbourhood  VARCHAR(100)  NOT NULL
);

CREATE TABLE roomtype_dimension (
    RoomTypeKey  INTEGER      PRIMARY KEY,
    room_type    VARCHAR(30)  NOT NULL UNIQUE
);

CREATE TABLE host_dimension (
    HostKey    INTEGER       PRIMARY KEY,
    host_id    VARCHAR(20)   NOT NULL UNIQUE,   -- source host id kept as text
    host_name  VARCHAR(100)                     -- a few blanks in the source
);

CREATE TABLE minnights_dimension (
    MinNightsBandKey  INTEGER      PRIMARY KEY,
    band_label        VARCHAR(10)  NOT NULL UNIQUE   -- 1, 2-3, 4-7, 8-14, 15-30, 31+
);

CREATE TABLE listingsales_facttable (
    ListingKey             INTEGER        PRIMARY KEY,   -- surrogate key
    LocationKey            INTEGER        NOT NULL,
    RoomTypeKey            INTEGER        NOT NULL,
    HostKey                INTEGER        NOT NULL,
    MinNightsBandKey       INTEGER        NOT NULL,
    TouristKey             INTEGER        NOT NULL,
    source_listing_id      VARCHAR(25)    NOT NULL,      -- source id as text; not unique across regional files
    price                  NUMERIC(10,2)  NOT NULL,      -- missing-price rows excluded in the ETL
    estimated_booked_days  INTEGER        NOT NULL,      -- 365 - availability_365
    estimated_sales        NUMERIC(14,2)  NOT NULL,      -- price * estimated_booked_days
    CONSTRAINT fk_fact_location  FOREIGN KEY (LocationKey)      REFERENCES location_dimension (LocationKey),
    CONSTRAINT fk_fact_roomtype  FOREIGN KEY (RoomTypeKey)      REFERENCES roomtype_dimension (RoomTypeKey),
    CONSTRAINT fk_fact_host      FOREIGN KEY (HostKey)          REFERENCES host_dimension (HostKey),
    CONSTRAINT fk_fact_minnights FOREIGN KEY (MinNightsBandKey) REFERENCES minnights_dimension (MinNightsBandKey),
    CONSTRAINT fk_fact_tourist   FOREIGN KEY (TouristKey)       REFERENCES tourism_dimension (TouristKey)
);

-- Indexes on the foreign keys and the main filter columns
CREATE INDEX idx_fact_location  ON listingsales_facttable (LocationKey);
CREATE INDEX idx_fact_roomtype  ON listingsales_facttable (RoomTypeKey);
CREATE INDEX idx_fact_host      ON listingsales_facttable (HostKey);
CREATE INDEX idx_fact_minnights ON listingsales_facttable (MinNightsBandKey);
CREATE INDEX idx_fact_tourist   ON listingsales_facttable (TouristKey);
CREATE INDEX idx_fact_source_id ON listingsales_facttable (source_listing_id);
CREATE INDEX idx_loc_state      ON location_dimension (state_abrv);
