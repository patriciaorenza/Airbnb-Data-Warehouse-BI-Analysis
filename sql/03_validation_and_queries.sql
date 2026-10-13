-- 1. Fact totals
SELECT COUNT(*)                          AS fact_rows,
       SUM(price)                        AS total_price,
       SUM(estimated_sales)              AS total_estimated_sales,
       COUNT(DISTINCT source_listing_id) AS distinct_source_ids
FROM listingsales_facttable;

-- 2. Row counts (expected: fact 81850, location 432, roomtype 4, host 41264, minnights 6, tourism 6)
SELECT 'listingsales_facttable' AS table_name, COUNT(*) AS row_count FROM listingsales_facttable
UNION ALL SELECT 'location_dimension',  COUNT(*) FROM location_dimension
UNION ALL SELECT 'roomtype_dimension',  COUNT(*) FROM roomtype_dimension
UNION ALL SELECT 'host_dimension',      COUNT(*) FROM host_dimension
UNION ALL SELECT 'minnights_dimension', COUNT(*) FROM minnights_dimension
UNION ALL SELECT 'tourism_dimension',   COUNT(*) FROM tourism_dimension;

-- 3. Star join: total estimated sales by state and room type
SELECT l.state, r.room_type, SUM(f.estimated_sales) AS total_estimated_sales
FROM listingsales_facttable f
JOIN location_dimension l ON l.LocationKey = f.LocationKey
JOIN roomtype_dimension r ON r.RoomTypeKey = f.RoomTypeKey
GROUP BY l.state, r.room_type
ORDER BY l.state, r.room_type;

-- 4. Extended schema: sales vs tourism consumption, with listing count and average per listing
SELECT l.state_abrv,
       t.tourism_consumption_billion,
       COUNT(*)                 AS listings,
       SUM(f.estimated_sales)   AS total_estimated_sales,
       AVG(f.estimated_sales)   AS avg_estimated_sales_per_listing
FROM listingsales_facttable f
JOIN location_dimension l ON l.LocationKey = f.LocationKey
JOIN tourism_dimension  t ON t.TouristKey  = f.TouristKey
GROUP BY l.state_abrv, t.tourism_consumption_billion
ORDER BY total_estimated_sales DESC;
