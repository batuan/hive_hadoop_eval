use imdb;
CREATE TABLE name_basics (
    nconst string,
    primary_name string,
    birth_year int,
    death_year int,
    primary_profession array<string>,
    known_for_titles array<string>
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
COLLECTION ITEMS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA INPATH '/small.name.basics.tsv'
OVERWRITE INTO TABLE name_basics;


CREATE TABLE name_basics_bucketed (
  nconst string,
  primary_name string,
  birth_year int,
  death_year int,
  primary_profession array<string>,
  known_for_titles array<string>
)
CLUSTERED BY (nconst) INTO 16 BUCKETS
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\t'
STORED AS TEXTFILE;
INSERT INTO name_basics_bucketed
SELECT nconst, primary_name, birth_year, death_year, primary_profession, known_for_titles
FROM name_basics;
