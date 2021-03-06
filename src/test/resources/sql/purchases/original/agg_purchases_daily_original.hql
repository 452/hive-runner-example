-- creation of target table for purchase entity
CREATE EXTERNAL TABLE IF NOT EXISTS purchase (
  tenantid STRING,
  customerid STRING,
  userid STRING,
  username STRING,
  purchasetime STRING,
  sessionid STRING,
  devicetype STRING,
  deviceid STRING,
  devicemodel STRING,
  devicemake STRING,
  deviceos_firmwareversion STRING,
  deviceipaddress STRING,
  appversion STRING,
  platform STRING,
  contentid STRING,
  paymenttype STRING,
  transactionid STRING,
  discountedprice DECIMAL(15,2),
  originalprice DECIMAL(15,2),
  currency STRING,
  state STRING,
  contenttype STRING,
  providername STRING,
  servicename STRING,
  solutionofferid STRING,
  commerce_model STRING
)
PARTITIONED BY (partition_date STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ';';
LOAD DATA LOCAL INPATH 'src/test/resources/sql/purchases/PURCHASE_20160302.csv' OVERWRITE INTO TABLE purchase PARTITION (partition_date='20080815');


---
-- purchases 1D KPIs schema
---
CREATE EXTERNAL TABLE IF NOT EXISTS agg_purchases_daily(
platform string,
age tinyint,
gender char(1),
appversion string,
paymenttype string,
currency string,
revenues decimal(15,2),
purchases int,
categoryname string,
contenttype string,
genre string,
channel string,
region string,
state string
) PARTITIONED BY (partition_date STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ';';
LOAD DATA LOCAL INPATH 'src/test/resources/sql/purchases/PURCHASE_20160302.csv' OVERWRITE INTO TABLE agg_purchases_daily PARTITION (partition_date='20080815');

-- creation of target table for vod_catalog entity
CREATE EXTERNAL TABLE IF NOT EXISTS vod_catalog (
  contentid STRING,
  title STRING,
  categoryname STRING,
  genre STRING,
  contentduration DOUBLE
)
PARTITIONED BY (partition_date STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ';';
LOAD DATA LOCAL INPATH 'src/test/resources/sql/purchases/PURCHASE_20160302.csv' OVERWRITE INTO TABLE vod_catalog PARTITION (partition_date='20080815');
---
-- purchases related daily KPIs
--A_10,A_12,A_13,A_153,A_159,A_160,A_161,A_162,A_175,A_176,A_177,A_178
---
INSERT INTO TABLE agg_purchases_daily PARTITION  (partition_date = '${hiveconf:ENDDATE}')
SELECT
	platform,
	floor(datediff(from_unixtime(unix_timestamp('${hiveconf:ENDDATE}', 'yyyyMMdd')),from_unixtime(unix_timestamp(birth_date, 'yyyyMMdd')))/365.25) as age,
 	gender,
	appversion,
	paymenttype,
	currency,
	SUM(revenues) AS revenues, --all revenues for corresponding set of dimensions
	SUM(purchases) AS purchases,
	COALESCE(categoryname, channel_category) AS  categoryname,
	COALESCE(contenttype, channel_type) AS  contenttype,
	COALESCE(genre, channel_genre) AS  genre,
	channel_name as channel,
	regionname as region,
	state
FROM (
	SELECT
		userid,
		platform,
		appversion,
		paymenttype,
		currency,
		contentid,
		contenttype,
		SUM(CASE WHEN discountedprice>0 THEN discountedprice ELSE originalprice END) AS revenues, --if no discount then original price is taken, otherwise discount price used for aggr.
		COUNT(userid) AS purchases
	FROM purchase
	WHERE partition_date = '${hiveconf:ENDDATE}'
	GROUP BY
	userid,contenttype, contentid,
	platform,appversion,paymenttype,currency
    )purch
LEFT OUTER JOIN vod_catalog content ON content.contentid = purch.contentid
LEFT OUTER JOIN tvchannels ON  tvchannels.channel_id =  purch.contentid
LEFT OUTER JOIN profiling ON profiling.userid = purch.userid

GROUP BY --group by all dimensions
platform, gender,
floor(datediff(from_unixtime(unix_timestamp('${hiveconf:ENDDATE}', 'yyyyMMdd')),from_unixtime(unix_timestamp(birth_date, 'yyyyMMdd')))/365.25),
appversion,paymenttype,currency,
COALESCE(contenttype, channel_type),
COALESCE(categoryname, channel_category),
COALESCE(genre, channel_genre),
channel_name,
regionname,state;
