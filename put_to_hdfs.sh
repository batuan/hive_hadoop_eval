tsv_filenames=`ls *.tsv`
for eachfile in $tsv_filenames
do
   hdfs dfs -copyFromLocal $eachfile  /$eachfile
done
