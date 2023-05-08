# # Hadoop - Hive Report
## 0. Setup
Running hive, hadoop with `docker-compose` in 2 separated terminals

    sudo docker compose up -d

1st terminal to run hive
> sudo docker exec -it hive-server bash
> hive

2nd terminal to run hadoop
> sudo docker exec -it hive-server bash

3rd terminal to run

## 1. Download and preprocess data
Because the file is too large when extract (about 2 GB for each) so we need to reduce the file size by `head -10000` command after we downloaded and extracted these files. We can do it with the bash command:

      for i in  "title.episode.tsv.gz"  "title.ratings.tsv.gz"
      do
	      sudo  wget https://datasets.imdbws.com/"$i"
	      sudo gzip -d "$i"
	      tsv_file=$(basename "$i" .gz) # get the base name (tsv exten)
	      echo $tsv_file
	      sudo head -50000 "$tsv_file" > small."$tsv_file"
	      sudo rm "$tsv_file"
	     # or do whatever with individual element of the array
      done
run this bash on the normal terminal
## 2. Load data into hdfs 
When we finish down load and extract, we want to load this file to hadoop. Here is the bash command to do this thing:

    tsv_filenames=`ls *.tsv`
	for eachfile in $tsv_filenames
	do
	   hdfs dfs -copyFromLocal $eachfile  /$eachfile
	done
run this bash on the hadoop terminal
## 3. Query with hive
In this part, I will work on 2 file: title_principals and name_basics

### 1. With title_principals
We see that this file contains the following information for titles:

  - tconst (string) - alphanumeric unique identifier of the title.
  - titleType (string) – the type/format of the title (e.g. movie, short,
    tvseries, tvepisode, video, etc).
  - primaryTitle (string) – the more popular title / the title used by the
  filmmakers on promotional materials at the point of release.
  - originalTitle (string) - original title, in the original language.
  - isAdult (boolean) - 0: non-adult title; 1: adult title.
  - startYear (YYYY) – represents the release year of a title. In the case of TV
  Series, it is the series start year.
  - endYear (YYYY) – TV Series end year. "\\N" for all other title types.
  - runtimeMinutes – primary runtime of the title, in minutes.
  - genres (string array) – includes up to three genres associated with the
  title.
**So we can create a table and PARTITIONED with category.**, the principal.hql file will done this work.

>     CREATE DATABASE IF NOT EXISTS imdb;
>     USE imdb;
>     
>     CREATE EXTERNAL TABLE title_principals (
>       tconst STRING,
>       ordering INT,
>       nconst STRING,
>       category STRING,
>       job STRING,
>       characters STRING)
> ...
> 
>     CREATE TABLE title_principals_partitioned (
>     tconst STRING,
>     ordering INT,
>     nconst STRING,
>     job STRING,
>     characters STRING ) 
>     PARTITIONED BY (category STRING)
>     ....

run `hive -f principal.hql`

After that we have `imdb` database and 2 table `title_principals, title_principals_partitioned`, we can demo 2 query to count the number of each category in this tile_pricipals.

    select category, count(*) from title_principals group by category;
    ....
    self	184
	writer	4810
	Time taken: 2.782 seconds, Fetched: 12 row(s)
....

    select category, count(*) from title_principals_partitioned  group by category;
    ...
    self	184
	writer	4810
	Time taken: 1.324 seconds, Fetched: 12 row(s)
The partitioned table query 2 times faster than normal table.
### 2. With names basics file
This file contains the following information:
-   nconst (string) - alphanumeric unique identifier of the name/person.
-   primaryName (string)– name by which the person is most often credited.
-   birthYear – in YYYY format.
-   deathYear – in YYYY format if applicable, else "\N".
-   primaryProfession (strings) – the top-3 professions of the person.
-   knownForTitles (array of tconsts) – titles the person is known for.

So, for better design, we can create a table with we can choose the datatype: for  primaryProfession and knownForTitles as an array string, with the `COLLECTION ITEMS TERMINATED` by `,`. We can also  create 16 buckets from this table.

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
    ....
    CREATE TABLE name_basics_bucketed (
      nconst string,
      primary_name string,
      birth_year int,
      death_year int,
      primary_profession array<string>,
      known_for_titles array<string>
    )
    CLUSTERED BY (nconst) INTO 16 BUCKETS
    ...
run `hive -f name_basics.hql` to execute the table.
Benchmark with `count`

    SELECT COUNT(*) FROM name_basics;
    ...
    50000
    Time taken: 1.312 seconds, Fetched: 1 row(s)
	...
	SELECT COUNT(*) FROM name_basics_bucketed;
	....
	50000
	Time taken: 0.064 seconds, Fetched: 1 row(s)
we can see that it is 20 times faster
