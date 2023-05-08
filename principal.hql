CREATE DATABASE IF NOT EXISTS imdb;
USE imdb;

CREATE EXTERNAL TABLE title_principals (
  tconst STRING,
  ordering INT,
  nconst STRING,
  category STRING,
  job STRING,
  characters STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;

-- Load data into intermediate table
LOAD DATA INPATH '/small.title.principals.tsv' 
  OVERWRITE INTO TABLE title_principals;



SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode=nonstrict;

CREATE TABLE title_principals_partitioned (
    tconst STRING,
    ordering INT,
    nconst STRING,
    job STRING,
    characters STRING
)
PARTITIONED BY (category STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;


INSERT OVERWRITE TABLE title_principals_partitioned
PARTITION (category)
SELECT tconst, ordering, nconst, job, characters, category
FROM title_principals;
