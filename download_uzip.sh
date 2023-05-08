for i in  "name.basics.tsv.gz" "title.akas.tsv.gz" "title.basics.tsv.gz" "title.crew.tsv.gz" "title.episode.tsv.gz" "title.principals.tsv.gz" "title.ratings.tsv.gz"
do
  sudo  wget https://datasets.imdbws.com/"$i"
  sudo gzip -d "$i"
  tsv_file=$(basename "$i" .gz)
  echo $tsv_file
  sudo head -50000 "$tsv_file" > small."$tsv_file"
  sudo rm "$tsv_file"
 # or do whatever with individual element of the array
done
