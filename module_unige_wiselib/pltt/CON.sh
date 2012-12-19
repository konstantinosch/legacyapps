d=$(date +"%m-%d-%y")
t=$(date +"%T")
nf=${1%.*}"["$d"-"$t"]"
mkdir $nf
cp $1 $nf
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } {  for (i=0; i<$8; i++) { if ( ( $1 == "CON" ) && ( $2 == $i ) ) { zeroes = length($8) - length($2); str = ""; if ( zeroes!=0 ) { for (j=0; j<zeroes; j++) { str=str"0" } 	} else { str=""; } print $0 > "tmp_CON_"str""$i".txt"; print$0 > "tmp_out_all.txt" } } }'
cb_ceiling=`sort -t: -k 4nr tmp_out_all.txt | head -n 1 | awk 'BEGIN{FS=":"} ; {print $4}'`
cb_floor=0
rm tmp_out_all.txt
j=0
z=0
x=0
for i in tmp_CON_*; do
	echo $i":"$j":"$z":"$x
	echo "set cbrange["$cb_floor":"$cb_ceiling"]" > CON.p
	echo "set zrange["$cb_floor":"$cb_ceiling"]" >> CON.p
	echo "set datafile separator \":\"" >> CON.p
	echo "set palette rgb 7,5,15" >> CON.p
	echo "set view map" >> CON.p
	echo "set size ratio 1" >> CON.p
	echo "set xlabel \"x\"" >> CON.p
	echo "set ylabel \"y\" rotate by 360" >> CON.p
	echo "set title \"\"" >> CON.p
	echo "unset key" >> CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> CON.p
		echo "set output "\"""$nf"/CON_c"$((j++))".eps\"" >> CON.p
		echo "splot '"$i"' using 9:10:4 with points palette pointsize 2 pointtype 7" >> CON.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> CON.p
		echo "set output "\"""$nf"/CON_c"$((j++))".png\"" >> CON.p
		echo "splot '"$i"' using 9:10:4 with points palette pointsize 4 pointtype 7" >> CON.p
	fi
	gnuplot CON.p
	rm CON.p
	echo "set cbrange[0:-30]" > CON.p
	echo "set zrange[0:-30]" >> CON.p
	echo "set datafile separator \":\"" >> CON.p
	echo "set palette rgb 34,35,36" >> CON.p
	echo "set view map" >> CON.p
	echo "set size ratio 1" >> CON.p
	echo "set xlabel \"x\"" >> CON.p
	echo "set ylabel \"y\" rotate by 360" >> CON.p
	echo "set title \"\"" >> CON.p
	echo "unset key" >> CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> CON.p
		echo "set output "\"""$nf"/CON_db"$((z++))".eps\"" >> CON.p
		echo "splot '"$i"' using 9:10:6 with points palette pointsize 2 pointtype 7" >> CON.p	
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> CON.p
		echo "set output "\"""$nf"/CON_db"$((z++))".png\"" >> CON.p
		echo "splot '"$i"' using 9:10:6 with points palette pointsize 4 pointtype 7" >> CON.p	
	fi
	gnuplot CON.p
	rm CON.p
	echo "set yrange["$cb_floor":"$cb_ceiling"]" > CON.p
	echo "set datafile separator \":\"" >> CON.p
	echo "set xlabel \"node IDs\"" >> CON.p
	echo "set ylabel \"connectivity\"" >> CON.p
	echo "unset key" >> CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> CON.p
		echo "set output "\"""$nf"/CON_cs"$((x++))".eps\"" >> CON.p
		echo "plot '"$i"' using 3:4 with lines lw 4" >> CON.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> CON.p
		echo "set output "\"""$nf"/CON_cs"$((x++))".png\"" >> CON.p
		echo "plot '"$i"' using 3:4 with lines lw 4" >> CON.p
	fi
	gnuplot CON.p
done
rm tmp_CON*
rm CON.p

