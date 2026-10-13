-- Load the CSVs produced by notebooks/airbnb_etl.ipynb.
-- Adjust the folder to wherever the files sit on the PostgreSQL server.
-- Load order matters: dimensions first, fact table last.
COPY tourism_dimension      FROM '/tmp/etl/TOURISM_Dimension.csv'      WITH (FORMAT csv, HEADER true);
COPY location_dimension     FROM '/tmp/etl/LOCATION_Dimension.csv'     WITH (FORMAT csv, HEADER true);
COPY roomtype_dimension     FROM '/tmp/etl/ROOMTYPE_Dimension.csv'     WITH (FORMAT csv, HEADER true);
COPY minnights_dimension    FROM '/tmp/etl/MINNIGHTS_Dimension.csv'    WITH (FORMAT csv, HEADER true);

-- HOST_Dimension.csv is NOT in this repo (it holds individual host names).
-- Re-run the notebook against the source listings to regenerate it, then:
COPY host_dimension         FROM '/tmp/etl/HOST_Dimension.csv'         WITH (FORMAT csv, HEADER true);

COPY listingsales_facttable FROM '/tmp/etl/LISTINGSALES_FactTable.csv' WITH (FORMAT csv, HEADER true);
