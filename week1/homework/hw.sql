-- Q3. 2019년 10월 1일(포함)부터 2019년 11월 1일(제외)까지 기간 동안, 각각 다음과 같은 운행이 몇 번 있었나요
-- green_tripdata
-- zones
-- yellow_taxi_trips

-- columns:
-- Trip_distance
-- tpep_pickup_datetime

-- 1. 1마일 이하
-- 2. 1마일 초과 3마일 이하
-- 3. 3마일 초과 7마일 이하
-- 4. 7마일 초과 10마일 이하
-- 5. 10마일 초과


SELECT 
    SUM(CASE WHEN Trip_distance <= 1 THEN 1 END) AS "1. 1마일 이하",
    SUM(CASE WHEN Trip_distance > 1 AND Trip_distance <= 3 THEN 1 END) AS "2. 1마일 초과 3마일 이하",
    SUM(CASE WHEN Trip_distance > 3 AND Trip_distance <= 7 THEN 1 END) AS "3. 3마일 초과 7마일 이하",
    SUM(CASE WHEN Trip_distance > 7 AND Trip_distance <= 10 THEN 1 END) AS "4. 7마일 초과 10마일 이하",
    SUM(CASE WHEN Trip_distance > 10 THEN 1 END) AS "5. 10마일 초과"
FROM green_tripdata
-- WHERE lpep_pickup_datetime >= '2019-10-01' AND lpep_pickup_datetime < '2019-11-01';
-- 104830	198995	109642	27686	35201

SELECT 
    COUNT(*) AS cnt
FROM green_tripdata
GROUP BY 
    "VendorID", "lpep_pickup_datetime",
    "lpep_dropoff_datetime", "store_and_fwd_flag",
    "RatecodeID", "PULocationID",
    "DOLocationID", "passenger_count",
    "trip_distance", "fare_amount",
    "extra", "mta_tax",
    "tip_amount", "tolls_amount",
    "ehail_fee", "improvement_surcharge", "total_amount",
    "payment_type", "trip_type", "congestion_surcharge"
HAVING
    COUNT(*) > 1;

-- Q4
SELECT DATE(lpep_pickup_datetime)
FROM green_tripdata
WHERE Trip_distance = (
	SELECT MAX(Trip_distance) FROM green_tripdata
)


-- Q5
-- 2019-10-18일에 `total_amount`가 13,000을 초과한 상위 승차 위치는 어디인가요?
-- 날짜 필터링 시 `lpep_pickup_datetime`만 고려하세요.

WITH trip AS (
	SELECT "PULocationID",
			SUM(total_amount) AS "total_amount"
	FROM green_tripdata
	WHERE DATE(lpep_pickup_datetime) = '2019-10-18'
	GROUP BY "PULocationID"
	ORDER BY "total_amount" DESC
)
SELECT zones."Zone" AS "Zone",
       trip."PULocationID" AS "PULocationID",
	   trip."total_amount" AS "total_amount"
FROM zones 
INNER JOIN trip ON trip."PULocationID" = zones."LocationID"
ORDER BY "total_amount" DESC
LIMIT 3;


-- "Zone"	"PULocationID"	"total_amount"
-- "East Harlem North"	74	18686.680000000084
-- "East Harlem South"	75	16797.260000000064
-- "Morningside Heights"	166	13029.790000000032

-- Q6
-- 2019년 10월에 "East Harlem North" 구역에서 승차한 승객들 중에서 어느 하차 구역에서 가장 큰 팁이 있었나요?

WITH trip AS (
    SELECT "PULocationID",
           "DOLocationID",
           "tip_amount"
    FROM green_tripdata
    WHERE DATE(lpep_pickup_datetime) >= '2019-10-01' AND DATE(lpep_pickup_datetime) < '2019-11-01'
    ORDER BY "tip_amount" DESC
)
SELECT PUZone."Zone" AS "PULocation",
       DOZone."Zone" AS "DOLocation",
       trip."tip_amount" AS "tip_amount"
FROM trip
INNER JOIN zones AS PUZone ON trip."PULocationID" = PUZone."LocationID"
INNER JOIN zones AS DOZone ON trip."DOLocationID" = DOZone."LocationID"
WHERE PUZone."Zone" = 'East Harlem North'
ORDER BY "tip_amount" DESC
LIMIT 1;

-- "JFK Airport"