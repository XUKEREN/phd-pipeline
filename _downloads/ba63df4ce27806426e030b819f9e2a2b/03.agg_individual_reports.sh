for i in {1..25}; do
   echo "Welcome $i times"
   input_file=($(ls *_summary.tsv | sed -n ${i}p))
   tail -2 $input_file >>ALL.25cohort.telomerehunter.txt

done

for i in {1..50}; do
   echo "Welcome $i times"
   input_file=($(ls *.telseq.out | sed -n ${i}p))
   sed '1d;2d;3d' $input_file >>ALL.25cohort.telseq.txt
done
