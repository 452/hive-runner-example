
-- creation of rejected table for profiling entity (flume dir)
CREATE TABLE IF NOT EXISTS profiling_rejected (
  timestamp_server STRING,
  customerid STRING,
  username STRING,
  userid STRING,
  master_user STRING,
  first_name STRING,
  surname STRING,
  gender STRING,
  mobile_phone STRING,
  email_address STRING,
  birth_date STRING,
  parental_control_status STRING,
  vod_parental_control_set STRING,
  epg_parental_control_set STRING,
  payment_method STRING,
  personalized_services_flag STRING,
  marketing_flag STRING,
  third_parties_flag STRING,
  first_line_address STRING,
  regionid INT,
  regionname STRING,
  country STRING,
  state STRING,
  province STRING,
  city STRING,
  zip_code STRING,
  preferred_language STRING,
  rejected_reason STRING
)
PARTITIONED BY (partition_date STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\073' ESCAPED BY '\\'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION '${hiveconf:ROOTPATH}/AVA/PROFILING/rejected';
