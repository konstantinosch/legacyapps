d=$(date +"%m-%d-%y")
t=$(date +"%T")
nf=${1%.*}"["$d"-"$t"]"
mkdir $nf
mkdir tmp
cp $1 $nf
#NEIGHBOR DISCOVERY CONVERGENCE
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } {  for (i=0; i<$8; i++) { if ( ( $1 == "CON" ) && ( $2 == $i ) ) { zeroes = length($8) - length($2); str = ""; if ( zeroes!=0 ) { for (j=0; j<zeroes; j++) { str=str"0" } } else { str=""; } print $0 > "tmp/tmp_CON_"str""$i".txt"; print$0 > "tmp/tmp_out_all.txt" } } }'
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
###############################

#TRACKING INFORMATION
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } { if ( $1 == "TAR" ) { print $0 > "tmp/tmp_TAR"$2".txt" } }'
for ii in tmp/tmp_TAR*; do
	str=$ii
	s1="${str#"${str%%[[:digit:]]*}"}"
	target_id="${s1%%[^[:digit:]]*}" 
	echo $ii":"$target_id 
	echo "set datafile separator \":\"" > tmp/TAR.p
	echo "set xlabel \"x\"" >> tmp/TAR.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/TAR.p
	echo "set title \"target id["$target_id"] movement\"" >> tmp/TAR.p
	echo "set size ratio 1" >> tmp/TAR.p
	echo "unset key" >> tmp/TAR.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >> tmp/TAR.p
		echo "set output "\"""$nf"/TAR_mov"$target_id".eps\"" >> tmp/TAR.p
		echo "plot '"$ii"' using 5:6 with linespoints pointsize 3 pointtype 7, \\" >> tmp/TAR.p
		echo " '"$ii"' using 5:6:4 with labels font 'Helvetica,10'" >> tmp/TAR.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TAR.p
		echo "set output "\"""$nf"/TAR_mov"$target_id".png\"" >> tmp/TAR.p
		echo "plot '"$ii"' using 5:6 with linespoints pointsize 6 pointtype 7, \\" >> tmp/TAR.p
		echo " '"$ii"' using 5:6:4 with labels" >> tmp/TAR.p
	fi
	gnuplot tmp/TAR.p
done
sort -t: -k 3n -k 4n -k 6n $1 | awk 'BEGIN { FS=":"; } { if ( $1 == "TRA" ) { print $0 > "tmp/tmp_TRA"$3"-"$4".txt" } }'
for jj in tmp/tmp_TRA*; do
	str1=${jj:11}	
	tar_tra_id_pos=`expr index $str1 ".txt"`
	tar_tra_id=${str1::(($tar_tra_id_pos)-1)}
	dash_pos=`expr index $tar_tra_id "-"`
	target_id=${tar_tra_id::(($dash_pos)-1)}
	tracker_id=${tar_tra_id:($dash_pos)}
	echo $jj:":"$target_id":"$tracker_id
	echo "set datafile separator \":\"" > tmp/TRA.p
	echo "set xlabel \"x\"" >> tmp/TRA.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/TRA.p
	echo "set title \"target id["$target_id"] movement based on reports from tracker id["$tracker_id"] \"" >> tmp/TRA.p
	echo "set size ratio 1" >> tmp/TRA.p
	echo "unset key" >> tmp/TRA.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,16'" >>tmp/TRA.p
		echo "set output "\"""$nf"/TRA_mov"$tar_tra_id".eps\"" >> tmp/TRA.p
		echo "plot '"$jj"' using 13:14 with linespoints pointsize 3 pointtype 7, \\" >> tmp/TRA.p
		echo " '"$jj"' using 13:14:5 with labels font 'Helvetica,10'" >> tmp/TRA.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA.p
		echo "set output "\"""$nf"/TRA_mov"$tar_tra_id".png\"" >> tmp/TRA.p
		echo "plot '"$jj"' using 13:14 with linespoints pointsize 6 pointtype 7, \\" >> tmp/TRA.p
		echo " '"$jj"' using 13:14:5 with labels" >> tmp/TRA.p
	fi
	gnuplot tmp/TRA.p
done

for yy in tmp/tmp_TRA*; do
	str1=${yy:11}	
	tar_tra_id_pos=`expr index $str1 ".txt"`
	tar_tra_id=${str1::(($tar_tra_id_pos)-1)}
	dash_pos=`expr index $tar_tra_id "-"`
	target_id1=${tar_tra_id::(($dash_pos)-1)}
	tracker_id1=${tar_tra_id:($dash_pos)}
	echo "1->"$yy;
	for xx in tmp/tmp_TAR*; do
		str2=$xx
		s2="${str2#"${str2%%[[:digit:]]*}"}"
		target_id2="${s2%%[^[:digit:]]*}" 
		if [ $target_id2 == $target_id1 ]; then
			echo "["$target_id1":"$tracker_id1"]";
			cat $yy $xx | awk 'BEGIN { FS=":";	tar_index=0; tra_index=0; } 
{ 
	if ( $1 == "TAR" )
	{	
		target_target_id[tar_index]=$2
		target_trace_start_time[tar_index]=$3
		target_trace_id[tar_index]=$4
		target_pos_x[tar_index]=$5
		target_pos_y[tar_index]=$6
		#target_transm_dB[tar_index]=$7
		tar_index = tar_index + 1;
	}
	else if ( $1 == "TRA" )
	{
		tracker_target_id[tra_index]=$3
		tracker_tracker_id[tra_index]=$4
		tracker_agent_counter[tra_index]=$5
		tracker_agent_start_time[tra_index]=$6
		tracker_agent_end_time[tra_index]=$7
		tracker_agent_duration[tra_index]=$8
		tracker_agent_id[tra_index]=$9
		tracker_target_max_inten[tra_index]=$10
		tracker_agent_hop_count[tra_index]=$11
		tracker_trace_id[tra_index]=$12
		tracker_detect_pos_x[tra_index]=$13
		tracker_detect_pos_y[tra_index]=$14
		#tracker_detect_rssi[tra_index]=$15
		#tracker_detect_lqi[tra_index]=$16
		tra_index = tra_index + 1;
	}
}
END {
	for ( i = 0; i < tra_index; i++ )
	{
		tar_tar_index = 0;
		for ( j = 0; j < tar_index; j++ )
		{
			if (tracker_tracker_id[i] == target_target_id[j] )
			{
				tracker_pos_x[i] = target_pos_x[j];
				tracker_pos_y[i] = target_pos_y[j];
			}
			else 
			{
				tar_tar_index = tar_tar_index + 1;
				if ( tracker_trace_id[i] == target_trace_id[j] )
				{
					tracker_target_pos_x[i]=target_pos_x[j];
					tracker_target_pos_y[i]=target_pos_y[j];
					tracker_target_detect_distance[i] = sqrt( ( tracker_detect_pos_x[i] - target_pos_x[j] ) ^ 2 + ( tracker_detect_pos_y[i] - target_pos_y[j] )^2 );
					tracker_target_distance[i] = sqrt( ( tracker_pos_x[i] - target_pos_x[j] ) ^ 2 + ( tracker_pos_y[i] - target_pos_y[j] )^2 );
					#tracker_target_transm_dB[i] = target_transm_dB[j];
				}
			}
			#print i":"target_target_id[i]":"target_trace_start_time[i]":"target_trace_id[i]":"target_pos_x[i]":"target_pos_y[i];
		}
	}
	for ( i = 0; i < tra_index; i++ )
	{
		print i":"tracker_target_id[i]":"tracker_tracker_id[i]":"tracker_agent_counter[i]":"tracker_agent_start_time[i]":"tracker_agent_end_time[i]":"tracker_agent_duration[i]":"tracker_agent_id[i]":"tracker_target_max_inten[i]":"tracker_agent_hop_count[i]":"tracker_trace_id[i]":"tracker_detect_pos_x[i]":"tracker_detect_pos_y[i]":"tracker_target_pos_x[i]":"tracker_target_pos_y[i]":"tracker_pos_x[i]":"tracker_pos_y[i]":"tracker_target_detect_distance[i]":"tracker_target_distance[i];#":"tracker_detect_rssi[i]":"tracker_detect_lqi[i]":"tracker_target_transm_dB[i]
	}
	print tra_index":"tar_tar_index":"tar_index
	success_rate = ( tra_index * 100 ) / tar_tar_index;
	print "success rate="success_rate"%";
}'
		fi
		echo "2->"$xx;
	done
done
###############################

#rm -rf $1
rm -rf tmp
