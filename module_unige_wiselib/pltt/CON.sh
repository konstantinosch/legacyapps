d=$(date +"%m-%d-%y")
t=$(date +"%T")
nf=${1%.*}"["$d"-"$t"]"
mkdir $nf
mkdir tmp
cp $1 $nf
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } {  for (i=0; i<$8; i++) { if ( ( $1 == "CON" ) && ( $2 == $i ) ) { zeroes = length($8) - length($2); str = ""; if ( zeroes!=0 ) { for (j=0; j<zeroes; j++) { str=str"0" } 	} else { str=""; } print $0 > "tmp/tmp_CON_"str""$i".txt"; print$0 > "tmp/tmp_out_all.txt" } } }'
cb_ceiling=`sort -t: -k 4nr tmp/tmp_out_all.txt | head -n 1 | awk 'BEGIN{FS=":"} ; {print $4}'`
cb_floor=0
j=0
z=0
x=0
y=0
q=0
for i in tmp/tmp_CON_*; do
	avg_c=`awk 'BEGIN { FS=":"; sum=0; } {sum+=$4} END { print sum/NR}' $i`
	avg_dB=`awk 'BEGIN { FS=":"; sum=0; } {sum+=$6} END { print sum/NR}' $i`
	stdev_c=`awk 'BEGIN { FS=":";} {sum+=$4; array[NR]=$4} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`
	stdev_dB=`awk 'BEGIN { FS=":";} {sum+=$6; array[NR]=$6} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`
	echo $x:$avg_dB":"$stdev_dB":"$avg_c":"$stdev_c >> tmp/tmp_avg_stdev_all.txt
	echo $i":"$j":"$z":"$x:$y
	echo "set cbrange["$cb_floor":"$cb_ceiling"]" > tmp/CON.p
	echo "set zrange["$cb_floor":"$cb_ceiling"]" >> tmp/CON.p
	echo "set datafile separator \":\"" >> tmp/CON.p
	echo "set palette rgb 7,5,15" >> tmp/CON.p
	echo "set view map" >> tmp/CON.p
	echo "set size ratio 1" >> tmp/CON.p
	echo "set xlabel \"x\"" >> tmp/CON.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/CON.p
	echo "set cblabel \"node connectivity\"" >> tmp/CON.p
	echo "set title \"topology connectivity status\"" >> tmp/CON.p
	echo "unset key" >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_c"$((j++))".eps\"" >> tmp/CON.p
		echo "splot '"$i"' using 9:10:4 with points palette pointsize 2 pointtype 7" >> tmp/CON.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_c"$((j++))".png\"" >> tmp/CON.p
		echo "splot '"$i"' using 9:10:4 with points palette pointsize 4 pointtype 7" >> tmp/CON.p
	fi
	gnuplot tmp/CON.p
	rm tmp/CON.p
	echo "set cbrange[0:-30]" > tmp/CON.p
	echo "set zrange[0:-30]" >> tmp/CON.p
	echo "set datafile separator \":\"" >> tmp/CON.p
	echo "set palette model XYZ rgbformulae 7,5,15" >> tmp/CON.p
	echo "set view map" >> tmp/CON.p
	echo "set size ratio 1" >> tmp/CON.p
	echo "set xlabel \"x\"" >> tmp/CON.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/CON.p
	echo "set cblabel \"node transmission dB\"" >> tmp/CON.p
	echo "set title \"transmission power dB status\"" >> tmp/CON.p
	echo "unset key" >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_db"$((z++))".eps\"" >> tmp/CON.p
		echo "splot '"$i"' using 9:10:6 with points palette pointsize 2 pointtype 7" >> tmp/CON.p	
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_db"$((z++))".png\"" >> tmp/CON.p
		echo "splot '"$i"' using 9:10:6 with points palette pointsize 4 pointtype 7" >> tmp/CON.p	
	fi
	gnuplot tmp/CON.p
	rm tmp/CON.p
	echo "set yrange["$cb_floor-10":"$cb_ceiling+10"]" > tmp/CON.p
	echo "set datafile separator \":\"" >> tmp/CON.p
	echo "set xlabel \"node IDs\"" >> tmp/CON.p
	echo "set ylabel \"connectivity\"" >> tmp/CON.p
	echo "set title \"connectivity status\"" >> tmp/CON.p
	echo "set label 1 \"avg connectivity : "$avg_c"\" at 10,"$cb_ceiling+10-2.5 >> tmp/CON.p
	echo "set label 2 \"stdev connectivity : "$stdev_c"\" at 10,"$cb_ceiling+10-5 >> tmp/CON.p
	echo "avg_c="$avg_c >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_cs"$((x++))".eps\"" >> tmp/CON.p
		echo "plot '"$i"' using 3:4 with lines lw 2 lc rgb \"red\" title \"connectivity\", \\" >> tmp/CON.p
		echo " '"$i"' using 3:(avg_c) with lines lw 4 lc rgb \"blue\" title \"average connectivity\"" >> tmp/CON.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_cs"$((x++))".png\"" >> tmp/CON.p
		echo "plot '"$i"' using 3:4 with lines lw 2 lc rgb \"red\" title \"connectivity\", \\" >> tmp/CON.p
		echo " '"$i"' using 3:(avg_c) with lines lw 4 lc rgb \"blue\" title \"avg connectivity\"" >> tmp/CON.p
	fi
	gnuplot tmp/CON.p
	rm tmp/CON.p
	echo "set yrange[-40:10]" > tmp/CON.p
	echo "set datafile separator \":\"" >> tmp/CON.p
	echo "set xlabel \"node IDs\"" >> tmp/CON.p
	echo "set ylabel \"transmission dB\"" >> tmp/CON.p
	echo "set title \"transmission power dB status\"" >> tmp/CON.p
	echo "set label 1 \"avg dB : "$avg_dB"\" at 10, 7.5" >> tmp/CON.p
	echo "set label 2 \"stdev dB : "$stdev_dB"\" at 10, 5" >> tmp/CON.p
	echo "avg_dB="$avg_dB >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_dbs"$((y++))".eps\"" >> tmp/CON.p
		echo "plot '"$i"' using 3:6 with lines lw 2 lc rgb \"red\" title \"dB\", \\" >> tmp/CON.p
		echo " '"$i"' using 3:(avg_dB) with lines lw 4 lc rgb \"blue\" title \"avg dB\"" >> tmp/CON.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
		echo "set output "\"""$nf"/CON_dbs"$((y++))".png\"" >> tmp/CON.p
		echo "plot '"$i"' using 3:6 with lines lw 2 lc rgb \"red\" title \"dB\", \\" >> tmp/CON.p
		echo " '"$i"' using 3:(avg_dB) with lines lw 4 lc rgb \"blue\" title \"average dB\"" >> tmp/CON.p
	fi
	gnuplot tmp/CON.p
done
rm tmp/CON.p
echo "set datafile separator \":\"" > tmp/CON.p
echo "set xlabel \"time\"" >> tmp/CON.p
echo "set ylabel \"connectivity\"" >> tmp/CON.p
if [ $2 == "eps" ]; then
	echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
	echo "set output "\"""$nf"/avg_stdev_c.eps\"" >> tmp/CON.p
	echo "plot 'tmp/tmp_avg_stdev_all.txt' using 1:4 with lines lw 2 lc rgb \"red\" title \"avg connectivity\", \\" >> tmp/CON.p
	echo " 'tmp/tmp_avg_stdev_all.txt' using 1:5 with lines lw 4 lc rgb \"blue\" title \"stdev connectivity\"" >> tmp/CON.p
elif [ $2 == "png" ]; then
	echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
	echo "set output "\"""$nf"/avg_stdev_c.png\"" >> tmp/CON.p
	echo "plot 'tmp/tmp_avg_stdev_all.txt' using 1:4 with lines lw 2 lc rgb \"red\" title \"avg connectivity\", \\" >> tmp/CON.p
	echo " 'tmp/tmp_avg_stdev_all.txt' using 1:5 with lines lw 4 lc rgb \"blue\" title \"stdev connectivity\"" >> tmp/CON.p
fi
gnuplot tmp/CON.p
rm tmp/CON.p
echo "set datafile separator \":\"" > tmp/CON.p
echo "set xlabel \"time\"" >> tmp/CON.p
echo "set ylabel \"dB\"" >> tmp/CON.p
if [ $2 == "eps" ]; then
	echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/CON.p
	echo "set output "\"""$nf"/avg_stdev_dB.eps\"" >> tmp/CON.p
	echo "plot 'tmp/tmp_avg_stdev_all.txt' using 1:2 with lines lw 2 lc rgb \"red\" title \"avg dB\", \\" >> tmp/CON.p
	echo " 'tmp/tmp_avg_stdev_all.txt' using 1:3 with lines lw 4 lc rgb \"blue\" title \"stdev dB\"" >> tmp/CON.p
elif [ $2 == "png" ]; then
	echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/CON.p
	echo "set output "\"""$nf"/avg_stdev_dB.png\"" >> tmp/CON.p
	echo "plot 'tmp/tmp_avg_stdev_all.txt' using 1:2 with lines lw 2 lc rgb \"red\" title \"avg dB\", \\" >> tmp/CON.p
	echo " 'tmp/tmp_avg_stdev_all.txt' using 1:3 with lines lw 4 lc rgb \"blue\" title \"stdev dB\"" >> tmp/CON.p
fi
gnuplot tmp/CON.p
rm -rf tmp

