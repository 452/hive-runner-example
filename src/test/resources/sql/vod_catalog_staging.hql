-- creation of target table for vod_catalog entity (flume dir)
CREATE EXTERNAL TABLE IF NOT EXISTS vod_catalog_staging (
  contentid STRING,
  title STRING,
  categoryname STRING,
  genre STRING,
  contentduration DOUBLE
)
PARTITIONED BY (partition_date STRING)
ROW FORMAT
DELIMITED FIELDS TERMINATED BY '\073' ESCAPED BY '\\'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
