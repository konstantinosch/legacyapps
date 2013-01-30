rm -rf tmp
d=$(date +"%m-%d-%y")
t=$(date +"%T")
nf=${1%.*}"["$d"-"$t"]"
mkdir $nf
mkdir $nf/anim
mkdir tmp
cp $1 $nf
#NEIGHBOR DISCOVERY CONVERGENCE
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } 
{  
	if ( ( $1 == "CON" ) )
	{ 
		for (i=0; i<$8; i++) 
		{ 
			if  ( $2 == $i )
			{
				zeroes = length($8) - length($2); str = ""; 
				if ( zeroes!=0 ) 
				{ 
					for (j=0; j<zeroes; j++) 
					{ 
						str=str"0" 
					} 
				} 
				else 
				{ 
					str=""; 
				} 
				print $0 > "tmp/tmp_CON_"str""$i".txt"; 
				print $0 > "tmp/tmp_out_all.txt" 
			}
		} 
	} 
}'
cb_ceiling=`sort -t: -k 4nr tmp/tmp_out_all.txt | head -n 1 | awk 'BEGIN{FS=":"} ; {print $4}'`
cb_floor=0
j=0
z=0
x=0
y=0
q=0
echo "##############################################################"
for i in tmp/tmp_CON_*; do
	avg_c=`awk 'BEGIN { FS=":"; sum=0; } {sum+=$4} END { print sum/NR}' $i`
	avg_dB=`awk 'BEGIN { FS=":"; sum=0; } {sum+=$6} END { print sum/NR}' $i`
	stdev_c=`awk 'BEGIN { FS=":";} {sum+=$4; array[NR]=$4} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`
	stdev_dB=`awk 'BEGIN { FS=":";} {sum+=$6; array[NR]=$6} END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`
	TOPO_x_ceiling=`awk 'BEGIN{FS=":"} ; {if ($1=="TOPO") {print $2}}' $1`
	TOPO_y_ceiling=`awk 'BEGIN{FS=":"} ; {if ($1=="TOPO") {print $3}}' $1`
	echo $x:$avg_dB":"$stdev_dB":"$avg_c":"$stdev_c >> tmp/tmp_avg_stdev_all.txt
	echo $i":"$j":"$z":"$x:$y
	echo "set cbrange["$cb_floor":"$cb_ceiling"]" > tmp/CON.p
	echo "set zrange["$cb_floor":"$cb_ceiling"]" >> tmp/CON.p
	echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/CON.p
	echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/CON.p
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
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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
	echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/CON.p
	echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/CON.p
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
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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
	echo "set label 1 \"avg connectivity : "$avg_c"\" at graph  0.02, graph  0.95" >> tmp/CON.p
	echo "set label 2 \"stdev connectivity : "$stdev_c"\" at graph  0.02, graph  0.90" >> tmp/CON.p
	echo "avg_c="$avg_c >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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
	echo "set ylabel \"transmission dB\" " >> tmp/CON.p
	echo "set title \"transmission power dB status\"" >> tmp/CON.p
	echo "set label 1 \"avg dB : "$avg_dB"\" at graph  0.02, graph  0.95" >> tmp/CON.p
	echo "set label 2 \"stdev dB : "$stdev_dB"\" at graph  0.02, graph  0.90" >> tmp/CON.p
	echo "avg_dB="$avg_dB >> tmp/CON.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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


avg_c_ceiling=`awk 'BEGIN{FS=":"; max=0;}{ if ($4 > max){ max=$4; } }END{print max}' tmp/tmp_avg_stdev_all.txt`

rm tmp/CON.p
echo "set datafile separator \":\"" > tmp/CON.p
echo "set xlabel \"time\"" >> tmp/CON.p
echo "set ylabel \"connectivity\"" >> tmp/CON.p
echo "set title \"average topology connectivity convergence\"" >> tmp/CON.p
echo "avg_c="$avg_c >> tmp/CON.p
echo "stdev_c="$stdev_c >> tmp/CON.p
echo "set label 3 \"avg connectivity : "$avg_c"\" at graph  0.02, graph  0.95" >> tmp/CON.p
echo "set label 4 \"stdev connectivity : "$stdev_c"\" at graph  0.02, graph  0.90" >> tmp/CON.p
echo "set yrange[0:"`expr $avg_c_ceiling*0.4+$avg_c_ceiling`"]" >> tmp/CON.p
if [ $2 == "eps" ]; then
	echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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
echo "set ylabel \"transmission dB\" " >> tmp/CON.p
echo "set title \"average transmission dB convergence\"" >> tmp/CON.p
echo "avg_dB="$avg_dB >> tmp/CON.p
echo "stdev_dB="$stdev_dB >> tmp/CON.p
echo "set yrange[-30:"`expr $stdev_dB*1+$stdev_dB`"]" >> tmp/CON.p
echo "set label 3 \"avg dB : "$avg_dB"\" at graph  0.02, graph  0.95" >> tmp/CON.p
echo "set label 4 \"stdev dB : "$stdev_dB"\" at graph  0.02, graph  0.90" >> tmp/CON.p
if [ $2 == "eps" ]; then
	echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/CON.p
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

grep "LOCAL_MAXIMUM" $1 > tmp/tmp_local_maximums.txt
local_maximums_count=`grep -c "LOCAL_MAXIMUM" $1`
grep "LOCAL_MINIMUM" $1 > tmp/tmp_local_minimums.txt
local_minimums_count=`grep -c "LOCAL_MINIMUM" $1`

avg_local_minimum=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$4 } END { print sum/NR}' tmp/tmp_local_minimums.txt`
stdev_local_minimum=`awk 'BEGIN { FS=":";} { sum+=$4; array[NR]=$4 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' tmp/tmp_local_minimums.txt`

avg_local_maximum=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$4 } END { print sum/NR}' tmp/tmp_local_maximums.txt`
stdev_local_maximum=`awk 'BEGIN { FS=":";} { sum+=$4; array[NR]=$4 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' tmp/tmp_local_maximums.txt`

echo "local minimums="$local_minimums_count
echo "avg_local_minimum="$avg_local_minimum
echo "stdev_local_minimum="$stdev_local_minimum

echo "local_maximums="$local_maximums_count
echo "avg_local_maximum="$avg_local_maximum
echo "stdev_local_maximum="$stdev_local_maximum

echo "##############################################################"
echo
echo
echo
echo "##############################################################"
###############################

#TRACKING INFORMATION
sort -t: -k 2n -k 3n $1 | awk 'BEGIN { FS=":"; } { if ( $1 == "TAR" ) { print $0 > "tmp/tmp_TAR"$2".txt" } }'
for ii in tmp/tmp_TAR*; do
	str=$ii
	s1="${str#"${str%%[[:digit:]]*}"}"
	target_id="${s1%%[^[:digit:]]*}" 
	echo $ii":"$target_id 
	echo "set datafile separator \":\"" > tmp/TAR.p
	echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/TAR.p
	echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/TAR.p
	echo "set xlabel \"x\"" >> tmp/TAR.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/TAR.p
	echo "set title \"target id["$target_id"] movement\"" >> tmp/TAR.p
	echo "set size ratio 1" >> tmp/TAR.p
	echo "unset key" >> tmp/TAR.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/TAR.p
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
	tracker_id=${tar_tra_id::(($dash_pos)-1)}
	target_id=${tar_tra_id:($dash_pos)}
	echo $jj":"$tracker_id":"$target_id
	echo "set datafile separator \":\"" > tmp/TRA.p
	echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/TRA.p
	echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/TRA.p
	echo "set xlabel \"x\"" >> tmp/TRA.p
	echo "set ylabel \"y\" rotate by 360" >> tmp/TRA.p
	echo "set title \"target id["$target_id"] movement based on reports from tracker id["$tracker_id"] \"" >> tmp/TRA.p
	echo "set size ratio 1" >> tmp/TRA.p
	echo "unset key" >> tmp/TRA.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA.p
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
echo "##############################################################"
echo
echo
echo
max_range=`awk 'BEGIN{FS=":"}{ if ($1=="SFM"){ print $2 } }' $1`
tar_db=`awk 'BEGIN{FS=":"; db=0;}{ if ($1=="TAR"){ db=$7 } }END{ print db}' $1`
com_radius=`echo "" | awk -v mr=$max_range -v tdb=$tar_db 'END {print mr*10^(tdb/30)}'`
file1=""
file2=""
file3=""
empty="1"
for yy in tmp/tmp_TRA*; do
	str1=${yy:11}	
	tar_tra_id_pos=`expr index $str1 ".txt"`
	tar_tra_id=${str1::(($tar_tra_id_pos)-1)}
	dash_pos=`expr index $tar_tra_id "-"`
	tracker_id1=${tar_tra_id::(($dash_pos)-1)}
	target_id1=${tar_tra_id:($dash_pos)}
	for xx in tmp/tmp_TAR*; do
		str2=$xx
		s2="${str2#"${str2%%[[:digit:]]*}"}"
		target_id2="${s2%%[^[:digit:]]*}" 
		if [ $target_id2 == $target_id1 ]; then
			file2=$xx
		elif [ $tracker_id1 == $target_id2 ]; then
			file3=$xx
		fi	
	done
	echo "##############################################################"
	echo $yy":"$tracker_id1":"$target_id1
file1=$yy
	if [ "$file1"!="$empty" ] && [ "$file2"!="$empty" ] && [ "$file3"!="$empty" ]; then

		echo $file1 $file2 $file3
	echo "##############################################################"
		cat $file1 $file2 $file3 | awk -v cr=$com_radius 'BEGIN { FS=":"; tar_index=0; tra_index=0; dupes=0; } 
	{ 
		if ( $1 == "TAR" )
		{	
			target_target_id[tar_index]=$2
			target_trace_start_time[tar_index]=$3
			target_trace_id[tar_index]=$4
			target_pos_x[tar_index]=$5
			target_pos_y[tar_index]=$6
			target_transm_dB[tar_index]=$7
			tar_index = tar_index + 1;
		}
		else if ( $1 == "TRA" )
		{

			tracker_tracker_id[tra_index]=$3
			tracker_target_id[tra_index]=$4
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
			tracker_tracker_trace_id[tra_index]=$15
			tracker_detect_lqi[tra_index]=$16
			tracker_detect_rssi[tra_index]=$17
			tra_index = tra_index + 1;	
		}
	}
	END {
		for ( i = 0; i < tra_index; i++ )
		{
			tar_tar_index = 0;
			for ( j = 0; j < tar_index; j++ )
			{
				if ( tracker_tracker_id[i] == target_target_id[j] )
				{
					if ( tracker_tracker_trace_id[i] == target_trace_id[j] )
					{
						tracker_pos_x[i] = target_pos_x[j];
						tracker_pos_y[i] = target_pos_y[j];
					}
				}
				else 
				{
					if ( tracker_trace_id[i] == target_trace_id[j] )
					{
						tracker_target_pos_x[i]=target_pos_x[j];
						tracker_target_pos_y[i]=target_pos_y[j];
						tracker_target_detect_distance[i] = sqrt( ( tracker_detect_pos_x[i] - target_pos_x[j] ) ^ 2 + ( tracker_detect_pos_y[i] - target_pos_y[j] )^2 );
						tracker_target_distance[i] = sqrt( ( tracker_pos_x[i] - target_pos_x[j] ) ^ 2 + ( tracker_pos_y[i] - target_pos_y[j] )^2 );
						tracker_target_transm_dB[i] = target_transm_dB[j];
					}
				}
			}
		}
		for ( i = 0; i < tra_index; i++ )
		{
			if ( ( i > 0 ) && ( tracker_agent_id[i] == tracker_agent_id[i-1] ) )
			{
				dupes=dupes+1;
			}
			else
			{
				A = ((255.0 - tracker_detect_rssi[i] )/255.0)*3;
				B = 10^A;
				tracker_rssi_distance[i] = ( B * cr ) / 1000;
				print i-dupes":"tracker_target_id[i]":"tracker_tracker_id[i]":"tracker_agent_counter[i]":"tracker_agent_start_time[i]":"tracker_agent_end_time[i]":"tracker_agent_duration[i]":"tracker_agent_id[i]":"tracker_target_max_inten[i]":"tracker_agent_hop_count[i]":"tracker_trace_id[i]":"tracker_tracker_trace_id[i]":"tracker_detect_pos_x[i]":"tracker_detect_pos_y[i]":"tracker_target_pos_x[i]":"tracker_target_pos_y[i]":"tracker_pos_x[i]":"tracker_pos_y[i]":"tracker_target_detect_distance[i]":"tracker_target_distance[i]":"tracker_target_transm_dB[i]":"tracker_detect_lqi[i]":"tracker_detect_rssi[i]":"tracker_rssi_distance[i]
			}
		}
	}' > tmp/tmp_TR_full.txt #all reports reaching tracker
		all_reports=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "QTR" ) &&( $2 == id ) ) { i=i+1; } }END{ print i }' $1`
######
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "QTR" ) &&( $2 == id ) ) { print $0} }' $1  > tmp/tmp_REP_init.txt #all reports generated from tracker
		awk 'BEGIN{FS=":";n=0;}{a[n]=$4; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "QTR:dup:"a[i]":"a[j]":"i":"j}}}}' tmp/tmp_REP_init.txt
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "RTR" ) &&( $3 == id ) ) { print "RTR:"$5} }' $1 > tmp/tmp_RTR.txt #pre_hop_report comm range filter
		awk 'BEGIN{FS=":";n=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "RTR:dup:"a[i]":"i":"j}}}}' tmp/tmp_RTR.txt
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "LMQ" ) &&( $7 == id ) ) { print "LMQ:"$5} }' $1 > tmp/tmp_LMQ.txt #hop count limit on query
		awk 'BEGIN{FS=":";n=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "LMQ:dup:"a[i]":"i":"j}}}}' tmp/tmp_LMQ.txt	
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "LMR" ) &&( $7 == id ) ) { print "LMR:"$5} }' $1 > tmp/tmp_LMR.txt #hop count limit on reports
		awk 'BEGIN{FS=":";n=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "LMR:dup:"a[i]":"i":"j}}}}' tmp/tmp_LMR.txt
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "ENR" ) &&( $7 == id ) ) { print "ENR:"$5} }' $1 > tmp/tmp_ENR.txt #lost due to no neigh list
		awk 'BEGIN{FS=":";n=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "ENR:dup:"a[i]":"i":"j}}}}'	tmp/tmp_ENR.txt
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "ZTR" ) &&( $2 == id ) ) { print "ZTR:"$5} }' $1 > tmp/tmp_ZTR.txt #lost due to reliable?
		awk 'BEGIN{FS=":";n=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){print "ZTR:dup:"a[i]":"i":"j}}}}' tmp/tmp_ZTR.txt
		row_sum=`awk '{}END{print FNR}' tmp/tmp_TR_full.txt`
		qtr_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$4; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_REP_init.txt`
		rtr_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_RTR.txt`
		lmq_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_LMQ.txt`	
		lmr_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_LMR.txt`
		enr_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_ENR.txt`
		ztr_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$2; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_ZTR.txt`
		tra_dupes=`awk 'BEGIN{FS=":";n=0;dupes=0;}{a[n]=$8; n=n+1}END{for(i=0; i<n; i++){for(j=0; j<n; j++){if((a[i]""==a[j]"")&&(i!=j)){dupes=dupes+1;}}}print dupes/2;}' tmp/tmp_TR_full.txt`
		#echo $row_sum
		#echo $qtr_dupes
		#echo $rtr_dupes
		#echo $lmq_dupes
		#echo $lmr_dupes
		#echo $enr_dupes
		#echo $ztr_dupes
		#echo $tra_dupes
		cat tmp/tmp_REP_init.txt tmp/tmp_TR_full.txt | awk 'BEGIN{ FS=":"; tra_index=0; q_index=0; }
		{ 
			if ($1 == "QTR")
			{ 
				q_id[q_index]=$4; 
				q_index = q_index + 1; 
			}
			else
			{ 
				tracker_agent_id[tra_index]=$8; 
				tra_index = tra_index + 1; 
			} 
		}
		END{ 
			for (j=0; j< q_index; j++)
			{
				found=0;
				for (i=0; i<tra_index; i++)
				{
					if ( tracker_agent_id[i] == q_id[j] )
					{
						found=1;
					}
				}
				if ( found == 0 )
				{
					print "RNF:"j":"q_id[j]":not found!"
				}
			}
		
		}' > tmp/tmp_REP_not_found.txt

		cat tmp/tmp_RTR.txt tmp/tmp_TR_full.txt | awk 'BEGIN{ FS=":"; tra_index=0; rtr_index=0; }
		{ 
			if ($1 == "RTR")
			{ 
				rtr_id[rtr_index]=$2; 
				rtr_index = rtr_index + 1; 
			}
			else
			{ 
				tracker_agent_id[tra_index]=$8; 
				tra_index = tra_index + 1; 
			} 
		}
		END{ 
			for (j=0; j< rtr_index; j++)
			{
				found=0;
				for (i=0; i<tra_index; i++)
				{
					if ( tracker_agent_id[i] == rtr_id[j] )
					{
						found=1;
					}
				}
				if ( found == 0 )
				{
					print "RTR:"j":"rtr_id[j]":not found!"
				}
			}
		
		}' > tmp/tmp_RTR_not_found.txt

		cat tmp/tmp_REP_not_found.txt tmp/tmp_RTR_not_found.txt tmp/tmp_LMQ.txt tmp/tmp_LMR.txt tmp/tmp_ENR.txt | awk 'BEGIN{ FS=":"; m_index=0; k_index=0; }
		{ 
			if ( $1 == "RTR" )
			{ 
				m[m_index]=$3; 
				m_index = m_index + 1; 
			}
			else if ( $1 == "LMR" )
			{
				m[m_index]=$2
				m_index = m_index + 1;
			}
			else if ( $1 == "LMQ" )
			{
				m[m_index]=$2
				m_index = m_index + 1;
			}
			else if ( $1 == "RNF" )
			{ 
				k[k_index]=$3; 
				k_index = k_index + 1; 
			}
			else if ( $1 == "ENR" )
			{ 
				m[m_index]=$2
				m_index = m_index + 1;
			}
			else if ( $1 == "ZTR" )
			{ 
				m[m_index]=$2
				m_index = m_index + 1;
			}
		}
		END{
			for (j=0; j< k_index; j++)
			{
				found=0;
				for (i=0; i<m_index; i++)
				{
					if ( m[i] == k[j] )
					{
						found=1;
					}
				}
				if ( found == 0 )
				{
					print "UN:"j":"k[j]
				}
			}
		
		}'
		
#filter more
####
		row_sum=`awk '{}END{print FNR}' tmp/tmp_TR_full.txt`
		for ((i=1; i<=$((row_sum)); ++i )) ; 
		do
			len1=${#row_sum}
			len2=${#i}
			len3=$((len1-len2))
			str11=$i
			for ((j=0; j<$((len3)); ++j )) ; 
			do
				str11="0""$str11"
			done
			head -$i "tmp/tmp_TR_full.txt" | tail -1 > "tmp/tmp_TR_row_"$str11"_"$tracker_id1".txt"
		done
		row_num=0
		for jj in tmp/tmp_TR_row_*; do
			echo "set datafile separator \":\"" > tmp/TRA_anim.p
			echo "set size ratio 1" >> tmp/TRA_anim.p
			echo "com_radius="$com_radius >> tmp/TRA_anim.p
			echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/TRA_anim.p
			echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/TRA_anim.p
			echo "set xlabel \"x\"" >> tmp/TRA_anim.p
			echo "set ylabel \"y\" rotate by 360" >> tmp/TRA_anim.p
			echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] transmission vs detection area\"" >> tmp/TRA_anim.p
			if [ $2 == "eps" ]; then
				echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
				echo "set output "\"""$nf"/anim/TRA_mov_anim_"$tracker_id1"_"$target_id1"_"$row_num".eps\"" >> tmp/TRA_anim.p
				echo " plot '"$jj"' using 15:16:(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 13:14:24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 13:14 with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 15:16 with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"">> tmp/TRA_anim.p
			elif [ $2 == "png" ]; then
				echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
				echo "set output "\"""$nf"/anim/TRA_mov_anim_"$tracker_id1"_"$target_id1"_"$row_num".png\"" >> tmp/TRA_anim.p
				echo " plot '"$jj"' using 15:16:(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 13:14:24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 13:14 with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
				echo " '"$jj"' using 15:16 with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"" >> tmp/TRA_anim.p
			fi
			row_num=`expr $row_num + 1`
			gnuplot tmp/TRA_anim.p
			rm tmp/TRA_anim.p
		done
		success_rate=`echo "" | awk -v rs=$row_sum -v ar=$all_reports 'END {print (rs/ar)*100}'`
		reports_missed_zero_echoes=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "XTR" ) &&( $2 == id ) ) { i=i+1; } }END{ print i }' $1`
		reports_missed_out_of_range_after_echoes=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "ZTR" ) &&( $2 == id ) ) { i=i+1} }END{ print i}' $1`
		pre_report_hop=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "RTR" ) &&( $3 == id ) ) { i=i+1; } }END{ print i }' $1`
		reports_missed_hop_count_lim_Q=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "LMQ" ) && ( $7 == id )  ) { i=i+1; } }END{ print i }' $1`
		reports_missed_hop_count_lim_R=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "LMR" ) && ( $7 == id )  ) { i=i+1; } }END{ print i }' $1`
		reports_missed_empty_neigh_list=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "ENR" ) &&( $7 == id ) ) { i=i+1; } }END{ print i }' $1`
		reports_missed_out_of_range=`expr $pre_report_hop - $row_sum`
		dupes=`expr $qtr_dupes + $rtr_dupes + $lmq_dupes + $lmr_dupes + $enr_dupes + $ztr_dupes + $tra_dupes`		

		echo "all reports="`expr $all_reports - $qtr_dupes`
		echo "all successfull reports="`expr $row_sum - $tra_dupes`
		echo "reports missed [due to zero echoes]="$reports_missed_zero_echoes
		echo "reports missed [out of comm range]="`expr $reports_missed_out_of_range - $rtr_dupes + $tra_dupes`
		echo "reports missed [due to comm range after echoes with propability]="`expr $reports_missed_out_of_range_after_echoes - $ztr_dupes`
		echo "reports missed [exceeded hop count limit(R)]="`expr $reports_missed_hop_count_lim_R - $lmr_dupes`
		echo "reports missed [exceeded hop count limit(Q)]="`expr $reports_missed_hop_count_lim_Q - $lmq_dupes`
		echo "reports missed [empty neigh list]="`expr $reports_missed_empty_neigh_list - $enr_dupes`
		echo "dupes="$dupes
		echo "success rate="$success_rate"%"
		avg_hop=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$10 } END { print sum/NR }' tmp/tmp_TR_full.txt`
		stdev_hop=`awk 'BEGIN { FS=":";} {sum+=$10; array[NR]=$10 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' tmp/tmp_TR_full.txt`
		echo "average hop number : "$avg_hop
		echo "stdev hop number: "$stdev_hop
		avg_detect_dist=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$19  } END { print sum/NR}' tmp/tmp_TR_full.txt`
		stdev_detect_dist=`awk 'BEGIN { FS=":";} { sum+=$19; array[NR]=$19 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' tmp/tmp_TR_full.txt`
		avg_detect_rssi_dist=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$24 } END { print sum/NR}' tmp/tmp_TR_full.txt`
		stdev_detect_rssi_dist=`awk 'BEGIN { FS=":";} { sum+=$24; array[NR]=$24 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' tmp/tmp_TR_full.txt`
		echo "average real distance: "$avg_detect_dist
		echo "stdev real distance: "$stdev_detect_dist
		echo "average detect rssi distance: "$avg_detect_rssi_dist
		echo "stdev detect rssi distance: "$stdev_detect_rssi_dist
		echo "com_radius="$com_radius
		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "com_radius="$com_radius >> tmp/TRA_anim.p
		echo "offset=(com_radius*0.5)" >> tmp/TRA_anim.p
		echo "set xrange[-"$TOPO_x_ceiling"/2:"$TOPO_x_ceiling"/2]" >> tmp/TRA_anim.p
		echo "set yrange[-"$TOPO_y_ceiling"/2:"$TOPO_y_ceiling"/2]" >> tmp/TRA_anim.p
		#echo "set xrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set yrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set xlabel \"x\"" >> tmp/TRA_anim.p
		#echo "set ylabel \"y\" rotate by 360" >> tmp/TRA_anim.p
		echo "unset xtics" >> tmp/TRA_anim.p
		echo "unset ytics" >> tmp/TRA_anim.p
		echo "set size ratio 1" >> tmp/TRA_anim.p
		#echo "set label 1 \"avg real detect radius : "$avg_detect_dist"\" at graph  0.02, graph  0.97" >> tmp/TRA_anim.p
		#echo "set label 2 \"stdev real detect radius : "$stdev_detect_dist"\" at graph  0.02, graph  0.94" >> tmp/TRA_anim.p
		echo "set label 3 \"avg detect rssi radius : "$avg_detect_rssi_dist"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 4 \"stdev detect rssi radius : "$stdev_detect_rssi_dist"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 5 \"transmission radius at "$tar_db"dB : "$com_radius"\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "set label 6 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.80" >> tmp/TRA_anim.p
		echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] superimposed detections\"" >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1".eps\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent solid 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\" ">> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1".png\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"">> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p

		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "com_radius="$com_radius >> tmp/TRA_anim.p
		echo "offset=(com_radius*0.5)" >> tmp/TRA_anim.p
		echo "set xrange[-"$TOPO_x_ceiling"/2:"$TOPO_x_ceiling"/2]" >> tmp/TRA_anim.p
		echo "set yrange[-"$TOPO_y_ceiling"/2:"$TOPO_y_ceiling"/2]" >> tmp/TRA_anim.p
		#echo "set xrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set yrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set xlabel \"x\"" >> tmp/TRA_anim.p
		#echo "set ylabel \"y\" rotate by 360" >> tmp/TRA_anim.p
		echo "unset xtics" >> tmp/TRA_anim.p
		echo "unset ytics" >> tmp/TRA_anim.p
		echo "set size ratio 1" >> tmp/TRA_anim.p
		#echo "set label 1 \"avg real detect radius : "$avg_detect_dist"\" at graph  0.02, graph  0.97" >> tmp/TRA_anim.p
		#echo "set label 2 \"stdev real detect radius : "$stdev_detect_dist"\" at graph  0.02, graph  0.94" >> tmp/TRA_anim.p
		echo "set label 3 \"avg detect rssi radius : "$avg_detect_rssi_dist"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 4 \"stdev detect rssi radius : "$stdev_detect_rssi_dist"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 5 \"transmission radius at "$tar_db"dB : "$com_radius"\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "set label 6 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.80" >> tmp/TRA_anim.p
		echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] superimposed detections\"" >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v2.eps\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent solid 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\" ">> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v2.png\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" fs transparent solid 0.15 noborder title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"">> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p

		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "com_radius="$com_radius >> tmp/TRA_anim.p
		echo "offset=(com_radius*0.5)" >> tmp/TRA_anim.p
		echo "set xrange[-"$TOPO_x_ceiling"/2:"$TOPO_x_ceiling"/2]" >> tmp/TRA_anim.p
		echo "set yrange[-"$TOPO_y_ceiling"/2:"$TOPO_y_ceiling"/2]" >> tmp/TRA_anim.p
		#echo "set xrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set yrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set xlabel \"x\"" >> tmp/TRA_anim.p
		#echo "set ylabel \"y\" rotate by 360" >> tmp/TRA_anim.p
		echo "unset xtics" >> tmp/TRA_anim.p
		echo "unset ytics" >> tmp/TRA_anim.p
		echo "set size ratio 1" >> tmp/TRA_anim.p
		#echo "set label 1 \"avg real detect radius : "$avg_detect_dist"\" at graph  0.02, graph  0.97" >> tmp/TRA_anim.p
		#echo "set label 2 \"stdev real detect radius : "$stdev_detect_dist"\" at graph  0.02, graph  0.94" >> tmp/TRA_anim.p
		echo "set label 3 \"avg detect rssi radius : "$avg_detect_rssi_dist"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 4 \"stdev detect rssi radius : "$stdev_detect_rssi_dist"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 5 \"transmission radius at "$tar_db"dB : "$com_radius"\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "set label 6 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.80" >> tmp/TRA_anim.p
		echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] superimposed detections\"" >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v3.eps\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent solid 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\" ">> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v3.png\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"">> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p

		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "com_radius="$com_radius >> tmp/TRA_anim.p
		echo "offset=(com_radius*0.5)" >> tmp/TRA_anim.p
		echo "set xrange[-"$TOPO_x_ceiling"/2:"$TOPO_x_ceiling"/2]" >> tmp/TRA_anim.p
		echo "set yrange[-"$TOPO_y_ceiling"/2:"$TOPO_y_ceiling"/2]" >> tmp/TRA_anim.p
		#echo "set xrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set yrange[-(com_radius+offset):(com_radius+offset)]" >> tmp/TRA_anim.p
		#echo "set xlabel \"x\"" >> tmp/TRA_anim.p
		#echo "set ylabel \"y\" rotate by 360" >> tmp/TRA_anim.p
		echo "unset xtics" >> tmp/TRA_anim.p
		echo "unset ytics" >> tmp/TRA_anim.p
		echo "set size ratio 1" >> tmp/TRA_anim.p
		#echo "set label 1 \"avg real detect radius : "$avg_detect_dist"\" at graph  0.02, graph  0.97" >> tmp/TRA_anim.p
		#echo "set label 2 \"stdev real detect radius : "$stdev_detect_dist"\" at graph  0.02, graph  0.94" >> tmp/TRA_anim.p
		echo "set label 3 \"avg detect rssi radius : "$avg_detect_rssi_dist"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 4 \"stdev detect rssi radius : "$stdev_detect_rssi_dist"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 5 \"transmission radius at "$tar_db"dB : "$com_radius"\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "set label 6 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.80" >> tmp/TRA_anim.p
		echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] superimposed detections\"" >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v4.eps\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent solid 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\" ">> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_superimpose"$tracker_id1"_"$target_id1"_v4.png\"" >> tmp/TRA_anim.p
			#echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):(com_radius)  with circles lc rgb \"green\" fs transparent 0.15 noborder title \"detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16):24 with circles lc rgb \"red\" fs transparent solid 0.15 noborder title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16):(com_radius) with circles lc rgb \"blue\" title \"transm radius\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""13-""$""15):(""$""14-""$""16) with points pointsize 1 pointtype 7 lc rgb \"red\" title \"position of detection\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using (""$""15-""$""15):(""$""16-""$""16) with points pointsize 1 pointtype 7 lc rgb \"black\" title \"real position\"">> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p

		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "set xlabel \"agent reports\"" >> tmp/TRA_anim.p
		echo "set ylabel \"distance\"" >> tmp/TRA_anim.p
		echo "set yrange[0:"$TOPO_y_ceiling"]" >> tmp/TRA_anim.p
		echo "set xrange[0-1:"$all_reports"]" >> tmp/TRA_anim.p
		echo "set title \"tracker id["$tracker_id1"], target id["$target_id1"] agent rssi detection radius\"" >> tmp/TRA_anim.p
		#echo "set label 1 \"avg real detect radius : "$avg_detect_dist"\" at graph  0.02, graph  0.97" >> tmp/TRA_anim.p
		#echo "set label 2 \"stdev real detect radius : "$stdev_detect_dist"\" at graph  0.02, graph  0.94" >> tmp/TRA_anim.p
		echo "set label 3 \"avg detect rssi radius : "$avg_detect_rssi_dist"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 4 \"stdev detect rssi radius : "$stdev_detect_rssi_dist"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 5 \"transmission radius at "$tar_db"dB : "$com_radius"\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "set label 6 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.80" >> tmp/TRA_anim.p
		echo "avg_dd="$avg_detect_dist >> tmp/TRA_anim.p
		echo "avg_rssi_dd="$avg_detect_rssi_dist >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance"$tracker_id1"_"$target_id1".eps\"" >> tmp/TRA_anim.p
			#echo "plot 'tmp/tmp_TR_full.txt' using 1:19 with linespoints pointsize 1 pointtype 7 title \"real detect radius\", \\" >> tmp/TRA_anim.p
			echo "plot 'tmp/tmp_TR_full.txt' using 1:24 with linespoints pointsize 1 pointtype 7 title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			#echo " 'tmp/tmp_TR_full.txt' using 1:(avg_dd) with lines lw 4 lc rgb \"blue\" title \"avg distance\"" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using 1:(avg_rssi_dd) with lines lw 4 lc rgb \"blue\" title \"avg detect rssi radius \"" >> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_distance_"$tracker_id1"_"$target_id1".png\"" >> tmp/TRA_anim.p
			#echo "plot 'tmp/tmp_TR_full.txt' using 1:19 with linespoints pointsize 1 pointtype 7 title \"real detect radius\", \\" >> tmp/TRA_anim.p
			echo " plot 'tmp/tmp_TR_full.txt' using 1:24 with linespoints pointsize 1 pointtype 7 title \"detect rssi radius\", \\" >> tmp/TRA_anim.p
			#echo " 'tmp/tmp_TR_full.txt' using 1:(avg_dd) with lines lw 4 lc rgb \"blue\" title \"avg distance\"" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using 1:(avg_rssi_dd) with lines lw 4 lc rgb \"blue\" title \"avg detect rssi radius\"" >> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p

		echo "set datafile separator \":\"" > tmp/TRA_anim.p
		echo "set xlabel \"agent reports\"" >> tmp/TRA_anim.p
		echo "set ylabel \"hops\"" >> tmp/TRA_anim.p
		echo "set xrange[0-1:"$all_reports"]" >> tmp/TRA_anim.p
		echo "set title \"tracker_id["$tracker_id1"], target_id["$target_id1"] agent hop count\"" >> tmp/TRA_anim.p
		echo "set label 1 \"avg hops : "$avg_hop"\" at graph  0.02, graph  0.95" >> tmp/TRA_anim.p
		echo "set label 2 \"stdev hops : "$stdev_hop"\" at graph  0.02, graph  0.90" >> tmp/TRA_anim.p
		echo "set label 4 \"succes rate : "$success_rate"%\" at graph  0.02, graph  0.85" >> tmp/TRA_anim.p
		echo "avg_h="$avg_hop >> tmp/TRA_anim.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >>tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_hops"$tracker_id1"_"$target_id1".eps\"" >> tmp/TRA_anim.p
			echo "plot 'tmp/tmp_TR_full.txt' using 1:10 with linespoints pointsize 1 pointtype 7 title \"agent hops\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using 1:(avg_h) with lines lw 4 lc rgb \"blue\" title \"avg hops\"" >> tmp/TRA_anim.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/TRA_anim.p
			echo "set output "\"""$nf"/TRA_hops_"$tracker_id1"_"$target_id1".png\"" >> tmp/TRA_anim.p
			echo "plot 'tmp/tmp_TR_full.txt' using 1:10 with linespoints pointsize 1 pointtype 7 title \"agent hops\", \\" >> tmp/TRA_anim.p
			echo " 'tmp/tmp_TR_full.txt' using 1:(avg_h) with lines lw 4 lc rgb \"blue\" title \"avg hops\"" >> tmp/TRA_anim.p
		fi
		gnuplot tmp/TRA_anim.p
		rm tmp/TRA_anim.p
		#rm tmp/tmp_TR_full.txt
		rm tmp/tmp_TR_row_*
	fi
echo "##############################################################"
	echo
	echo
	echo
done
###############################

#MESSAGE STATISTICS
###############################

echo "##############################################################"
tr_mode=`grep -c "STATS_VD" $1`

if [ $tr_mode != 0 ]; then

	max_samples=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_VD" ) 
		{ 
			if ( $3 > max )
			{
				max = $3
			}	
		} 
	}
	END{ print max }'`
	echo "max_samples="$max_samples

	max_DODAG_bytes_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_VD" ) 
		{ 
			if ( $4 > max )
			{
				max = $4
			}	
		} 
	}
	END{ print max }'`
	echo "max_DODAG_bytes_sent="$max_DODAG_bytes_sent

	max_DODAG_messages_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_VD" ) 
		{ 
			if ( $5 > max )
			{
				max = $5
			}	
		} 
	}
	END{ print max }'`
	echo "max_DODAG_messages_sent="$max_DODAG_messages_sent

	max_inhibition_bytes_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_VD" ) 
		{ 
			if ( $6 > max )
			{
				max = $6
			}	
		} 
	}
	END{ print max }'`
	echo "max_inhibition_bytes_sent="$max_inhibition_bytes_sent

	max_inhibition_messages_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_VD" ) 
		{ 
			if ( $7 > max )
			{
				max = $7
			}	
		} 
	}
	END{ print max }'`
	echo "max_inhibition_messages_sent="$max_inhibition_messages_sent

	sort -t: -k 2n $1 | awk -v ms=$max_samples 'BEGIN { FS=":"; } { 
		if ( $1 == "STATS_VD" ) 
		{ 
			zeroes = length(ms) - length($3); str = ""; 
			if ( zeroes!=0 ) 
			{ 
				for (j=0; j<zeroes; j++) 
				{ 
					str=str"0" 
				} 
			} 
			else 
			{ 
				str=""; 
			} 
			print $0 > "tmp/tmp_STATS_VD_"str""$3".txt"
			#print "tmp/tmp_STATS_VD_"$str""$3".txt"  
		} 
	}'

	count=0

	for i in tmp/tmp_STATS_VD_*; do

		avg_DODAG_bytes_sent=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$4 } END { print sum/NR}' $i`
		stdev_DODAG_bytes_sent=`awk 'BEGIN { FS=":";} { sum+=$4; array[NR]=$4 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_DODAG_messages_sent=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$5 } END { print sum/NR}' $i`
		stdev_DODAG_messages_sent=`awk 'BEGIN { FS=":";} { sum+=$5; array[NR]=$5 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_inhibition_bytes_sent=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$6 } END { print sum/NR}' $i`
		stdev_inhibition_bytes_sent=`awk 'BEGIN { FS=":";} { sum+=$6; array[NR]=$6 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_inhibition_messages_sent=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$7 } END { print sum/NR}' $i`
		stdev_inhibition_messages_sent=`awk 'BEGIN { FS=":";} { sum+=$7; array[NR]=$7 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		echo "DODAG:"$count":"$avg_DODAG_bytes_sent":"$stdev_DODAG_bytes_sent":"$avg_DODAG_messages_sent":"$stdev_DODAG_messages_sent":"$avg_inhibition_bytes_sent":"$stdev_inhibition_bytes_sent":"$avg_inhibition_messages_sent":"$stdev_inhibition_messages_sent >> tmp/tmp_AGRR_DODAG_SENT.txt
		echo "DODAG:"$count":"$avg_DODAG_bytes_sent":"$stdev_DODAG_bytes_sent":"$avg_DODAG_messages_sent":"$stdev_DODAG_messages_sent":"$avg_inhibition_bytes_sent":"$stdev_inhibition_bytes_sent":"$avg_inhibition_messages_sent":"$stdev_inhibition_messages_sent
	
		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_bytes_sent*0.3+$max_DODAG_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_dodag_bytes_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"blue\" title \"avg DODAG bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_dodag_bytes_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"blue\" title \"avg DODAG bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_dms="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dms="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_messages_sent*0.3+$max_DODAG_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG_messages_sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG_messages_sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_dodag_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_dodag_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"inhibition bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_inhibition_bytes_sent*0.3+$max_inhibition_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg inhibition_bytes_sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev inhibition_bytes_sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_inhibition_bytes_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:6 with lines lw 4 lc rgb \"red\" title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_inhbition_bytes_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:6 with lines lw 4 lc rgb \"red\" title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"inhibition messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ims="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ims="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_inhibition_messages_sent*0.3+$max_inhibition_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_inhibition_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:7 with lines lw 4 lc rgb \"red\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_inhibition_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:7 with lines lw 4 lc rgb \"red\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ims="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ims="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "avg_dms="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dms="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_messages_sent*0.3+$max_DODAG_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG messages sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG messages sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with points title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with points title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with points title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with points title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ims="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ims="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "avg_dms="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dms="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_messages_sent*0.3+$max_DODAG_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG messages sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG messages sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_ver2_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with lines lw 4 lc rgb \"blue\" title \"inhibition messages sent\"" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_ver2_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with lines lw 4 lc rgb \"blue\" title \"inhibition messages sent\"" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of bytes\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_bytes_sent*0.3+$max_DODAG_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition bytes sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition bytes sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with points title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with points title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with points title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with points title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of bytes\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_bytes_sent*0.3+$max_DODAG_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition bytes sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition bytes sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_ver2_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with lines lw 4 lc rgb \"blue\" title \"inhibition bytes sent\"" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_ver2_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with lines lw 4 lc rgb \"blue\" title \"inhibition bytes sent\"" >> tmp/stats_vd.p
			#echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		#if [ $count == $max_samples ]; then

			echo "set datafile separator \":\"" > tmp/stats_vd.p
			echo "set view map" >> tmp/stats_vd.p
			echo "set palette model XYZ rgbformulae 7,5,15" >> tmp/stats_vd.p
			echo "set size ratio 1" >> tmp/stats_vd.p
			echo "set xlabel \"x\"" >> tmp/stats_vd.p
			echo "set ylabel \"y\"" >> tmp/stats_vd.p
			echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/stats_vd.p
			echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/stats_vd.p
			echo "set ylabel \"y\" rotate by 360" >> tmp/stats_vd.p
			echo "set cbrange[0:"`expr $max_DODAG_messages_sent + $max_inhibition_messages_sent`"]" >> tmp/stats_vd.p
			echo "set cblabel \" all DODAG messages sent \"" >> tmp/stats_vd.p
			echo "set title \" spatial distribution of all DODAG messages sent\"" >> tmp/stats_vd.p
			echo "unset key" >> tmp/stats_vd.p
			if [ $2 == "eps" ]; then
				echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_spatial_"$count".eps\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 12:13:("\$"5+"\$"7) with points palette pointsize 2 pointtype 7" >> tmp/stats_vd.p
			elif [ $2 == "png" ]; then 
				echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_spatial_"$count".png\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 12:13:("\$"5+"\$"7) with points palette pointsize 4 pointtype 7" >> tmp/stats_vd.p
			fi
			gnuplot tmp/stats_vd.p
			rm tmp/stats_vd.p

			echo "set datafile separator \":\"" > tmp/stats_vd.p
			echo "set view map" >> tmp/stats_vd.p
			echo "set palette model XYZ rgbformulae 7,5,15" >> tmp/stats_vd.p
			echo "set size ratio 1" >> tmp/stats_vd.p
			echo "set xlabel \"x\"" >> tmp/stats_vd.p
			echo "set ylabel \"y\"" >> tmp/stats_vd.p
			echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/stats_vd.p
			echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/stats_vd.p
			echo "set ylabel \"y\" rotate by 360" >> tmp/stats_vd.p
			echo "set cbrange[0:"`expr $max_DODAG_bytes_sent + $max_inhibition_bytes_sent`"]" >> tmp/stats_vd.p
			echo "set cblabel \" all DODAG bytes sent \"" >> tmp/stats_vd.p
			echo "set title \" spatial distribution of all DODAG bytes sent\"" >> tmp/stats_vd.p
			echo "unset key" >>  tmp/stats_vd.p
			if [ $2 == "eps" ]; then
				echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_spatial_"$count".eps\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 12:13:("\$"4+"\$"6) with points palette pointsize 2 pointtype 7" >> tmp/stats_vd.p
			elif [ $2 == "png" ]; then 
				echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_spatial_"$count".png\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 12:13:("\$"4+"\$"6) with points palette pointsize 4 pointtype 7" >> tmp/stats_vd.p
			fi
			gnuplot tmp/stats_vd.p
			rm tmp/stats_vd.p		
		#fi

		count=`expr $count + 1`
	done

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $3+$7
		  xy_sum += $2*($3+$7)
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $3+$7
		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_DODAG_bytes_sent.txt

	DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dbs = $1 } END { print Dbs }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dbi = $2 }END { print Dbi }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dbr2 = $3 } END { print Dbr2 }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "All DODAG bytes sent slope ="$DODAG_bytes_slope
	echo "All DODAG bytes sent intercept ="$DODAG_bytes_inter
	echo "All DODAG bytes sent R2 ="$DODAG_bytes_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"bytes\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Correlation coefficient : "$DODAG_bytes_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f(x)="$DODAG_bytes_slope"*x+"$DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"3+"\$"7) with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"3+"\$"7)  with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $5+$9
		  xy_sum += $2*($5+$9)
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $5+$9

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_DODAG_messages_sent.txt

	DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "All DODAG messages sent slope ="$DODAG_messages_slope
	echo "All DODAG messages sent intercept ="$DODAG_messages_inter
	echo "All DODAG messages sent R2 ="$DODAG_messages_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"messages\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Correlation coefficient : "$DODAG_messages_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f(x)="$DODAG_messages_slope"*x+"$DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"5+"\$"9) with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG messages sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"5+"\$"9)  with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $7
		  xy_sum += $2*$7
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $7

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt

	I_DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`
	I_DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`
	I_DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Inhibition DODAG bytes sent slope : "$I_DODAG_bytes_slope
	echo "Inhibition DODAG bytes sent intercept : "$I_DODAG_bytes_inter
	echo "Inhibition DODAG bytes sent R2 : "$I_DODAG_bytes_r2
	echo "--------------------------------------------------------------"
	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $3
		  xy_sum += $2*$3
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $3

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt

	S_DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	S_DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	S_DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Spread DODAG bytes sent slope : "$S_DODAG_bytes_slope
	echo "Spread DODAG bytes sent intercept : "$S_DODAG_bytes_inter
	echo "Spread DODAG bytes sent R2 : "$S_DODAG_bytes_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"bytes\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Spread bytes correlation coefficient : "$S_DODAG_bytes_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f1(x)="$S_DODAG_bytes_slope"*x+"$S_DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 2 \"Inhibition bytes correlation coefficient : "$I_DODAG_bytes_r2"\" at graph  0.02, graph  0.90" >> tmp/tmp_lin_regr_DODAG.p
	echo "f2(x)="$I_DODAG_bytes_slope"*x+"$I_DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr_v2.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread bytes f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:3 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition bytes f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:7 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr_v2.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread bytes f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:3 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition bytes f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:7 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $9
		  xy_sum += $2*$9
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $9

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_I_DODAG_messages_sent.txt

	I_DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	I_DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	I_DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Inhibition DODAG messages sent slope : "$I_DODAG_messages_slope
	echo "Inhibition DODAG messages sent intercept : "$I_DODAG_messages_inter
	echo "Inhibition DODAG messages sent R2 : "$I_DODAG_messages_r2
	echo "--------------------------------------------------------------"
	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $5
		  xy_sum += $2*$5
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $5

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_S_DODAG_messages_sent.txt

	S_DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	S_DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	S_DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Spread DODAG messages sent slope : "$S_DODAG_messages_slope
	echo "Spread DODAG messages sent intercept : "$S_DODAG_messages_inter
	echo "Spread DODAG messages sent R2 : "$S_DODAG_messages_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"messages\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Spread messages correlation coefficient : "$S_DODAG_messages_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f1(x)="$S_DODAG_messages_slope"*x+"$S_DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 2 \"Inhibition messages correlation coefficient : "$I_DODAG_messages_r2"\" at graph  0.02, graph  0.90" >> tmp/tmp_lin_regr_DODAG.p
	echo "f2(x)="$I_DODAG_messages_slope"*x+"$I_DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr_v2.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread messages f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:5 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread messages sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition messages f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:9 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition messages sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr_v2.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread messages f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:5 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread messages sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition messages f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:9 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition messages sent\""  >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p
else

	max_samples=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $3 > max )
			{
				max = $3
			}	
		} 
	}
	END{ print max }'`
	echo "max_samples="$max_samples

	max_DODAG_bytes_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $4 > max )
			{
				max = $4
			}	
		} 
	}
	END{ print max }'`
	echo "max_DODAG_bytes_sent="$max_DODAG_bytes_sent

	max_DODAG_messages_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $5 > max )
			{
				max = $5
			}	
		} 
	}
	END{ print max }'`
	echo "max_DODAG_messages_sent="$max_DODAG_messages_sent

	max_inhibition_bytes_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $6 > max )
			{
				max = $6
			}	
		} 
	}
	END{ print max }'`
	echo "max_inhibition_bytes_sent="$max_inhibition_bytes_sent

	max_inhibition_messages_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $7 > max )
			{
				max = $7
			}	
		} 
	}
	END{ print max }'`
	echo "max_inhibition_messages_sent="$max_inhibition_messages_sent

	max_privacy_bytes_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $8 > max )
			{
				max = $8
			}	
		} 
	}
	END{ print max }'`
	echo "max_privacy_bytes_sent="$max_privacy_bytes_sent

	max_privacy_messages_sent=`sort -t: -k 2n $1 | awk '
	BEGIN { FS=":"; max=0; } 
	{ 
		if ( $1 == "STATS_PD" ) 
		{ 
			if ( $9 > max )
			{
				max = $9
			}	
		} 
	}
	END{ print max }'`
	echo "max_privacy_messages_sent="$max_privacy_messages_sent

	sort -t: -k 2n $1 | awk -v ms=$max_samples 'BEGIN { FS=":"; } { 
		if ( $1 == "STATS_PD" ) 
		{ 
			zeroes = length(ms) - length($3); str = ""; 
			if ( zeroes!=0 ) 
			{ 
				for (j=0; j<zeroes; j++) 
				{ 
					str=str"0" 
				} 
			} 
			else 
			{ 
				str=""; 
			} 
			print $0 > "tmp/tmp_STATS_PD_"str""$3".txt"
			#print "tmp/tmp_STATS_PD_"$str""$3".txt"  
		} 
	}'


count=0

	for i in tmp/tmp_STATS_PD_*; do

		avg_DODAG_bytes_sent=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$4 } END { print sum/NR}' $i`
		stdev_DODAG_bytes_sent=`awk 'BEGIN { FS=":";} { sum+=$4; array[NR]=$4 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_DODAG_messages_sent=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$5 } END { print sum/NR}' $i`
		stdev_DODAG_messages_sent=`awk 'BEGIN { FS=":";} { sum+=$5; array[NR]=$5 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_inhibition_bytes_sent=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$6 } END { print sum/NR}' $i`
		stdev_inhibition_bytes_sent=`awk 'BEGIN { FS=":";} { sum+=$6; array[NR]=$6 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_inhibition_messages_sent=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$7 } END { print sum/NR}' $i`
		stdev_inhibition_messages_sent=`awk 'BEGIN { FS=":";} { sum+=$7; array[NR]=$7 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_decryption_request_bytes_sent=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$8 } END { print sum/NR}' $i`
		stdev_decryption_request_bytes_sent=`awk 'BEGIN { FS=":";} { sum+=$8; array[NR]=$8 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

		avg_decryption_request_messages_sent=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$9 } END { print sum/NR}' $i`
		stdev_decryption_request_messages_sent=`awk 'BEGIN { FS=":";} { sum+=$9; array[NR]=$9 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`


		echo "DODAG:"$count":"$avg_DODAG_bytes_sent":"$stdev_DODAG_bytes_sent":"$avg_DODAG_messages_sent":"$stdev_DODAG_messages_sent":"$avg_inhibition_bytes_sent":"$stdev_inhibition_bytes_sent":"$avg_inhibition_messages_sent":"$stdev_inhibition_messages_sent":"$avg_decryption_request_bytes_sent":"$stdev_decryption_request_bytes_sent":"$avg_decryption_request_messages_sent":"$stdev_decryption_request_messages_sent >> tmp/tmp_AGRR_DODAG_SENT.txt
		echo "DODAG:"$count":"$avg_DODAG_bytes_sent":"$stdev_DODAG_bytes_sent":"$avg_DODAG_messages_sent":"$stdev_DODAG_messages_sent":"$avg_inhibition_bytes_sent":"$stdev_inhibition_bytes_sent":"$avg_inhibition_messages_sent":"$stdev_inhibition_messages_sent":"$avg_decryption_request_bytes_sent":"$stdev_decryption_request_bytes_sent":"$avg_decryption_request_messages_sent":"$stdev_decryption_request_messages_sent

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_bytes_sent*0.3+$max_DODAG_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_dodag_bytes_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"blue\" title \"avg DODAG bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_dodag_bytes_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"blue\" title \"avg DODAG bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_dms="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dms="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_DODAG_messages_sent*0.3+$max_DODAG_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG_messages_sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG_messages_sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_dodag_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_dodag_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"inhibition bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_inhibition_bytes_sent*0.3+$max_inhibition_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg inhibition_bytes_sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev inhibition_bytes_sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_inhibition_bytes_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:6 with lines lw 4 lc rgb \"red\" title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_inhbition_bytes_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:6 with lines lw 4 lc rgb \"red\" title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"inhibition messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ims="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ims="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_inhibition_messages_sent*0.3+$max_inhibition_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_inhibition_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:7 with lines lw 4 lc rgb \"red\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_inhibition_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:7 with lines lw 4 lc rgb \"red\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ims) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of bytes\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"dectryption request bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_drbs="$avg_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "stdev_drbs="$stdev_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_bytes_sent*0.5+$max_privacy_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg decryption request bytes sent : "$avg_decryption_request_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev decryption request bytes sent : "$stdev_decryption_request_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_decryption_request_bytes_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with lines lw 4 lc rgb \"red\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drbs) with lines lw 4 lc rgb \"blue\" title \"avg decryption request bytes sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_decryption_request_bytes_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with lines lw 4 lc rgb \"red\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drbs) with lines lw 4 lc rgb \"blue\" title \"avg decryption request bytes sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"dectryption request messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_drms="$avg_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "stdev_drms="$stdev_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_messages_sent*0.5+$max_privacy_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg decryption request messages sent : "$avg_decryption_request_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev decryption request messages sent : "$stdev_decryption_request_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_decryption_request_messages_sent"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with lines lw 4 lc rgb \"red\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drms) with lines lw 4 lc rgb \"blue\" title \"avg decryption request messages sent\"" >> tmp/stats_vd.p
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_decryption_request_messages_sent"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with lines lw 4 lc rgb \"red\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drms) with lines lw 4 lc rgb \"blue\" title \"avg decryption request messages sent\"" >> tmp/stats_vd.p
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of bytes\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "avg_drbs="$avg_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "stdev_drbs="$stdev_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_bytes_sent*0.5+$max_privacy_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition bytes sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition bytes sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		echo "set label 5 \"avg decryption request bytes sent : "$avg_decryption_request_bytes_sent"\" at graph  0.02, graph  0.75" >> tmp/stats_vd.p
		echo "set label 6 \"stdev decryption request bytes sent : "$stdev_decryption_request_bytes_sent"\" at graph  0.02, graph  0.70" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with points lc rgb \"green\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drbs) with lines lw 4 lc rgb \"green\" title \"avg decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:4 with points title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with points lc rgb \"blue\"title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
	
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with points lc rgb \"green\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drbs) with lines lw 4 lc rgb \"green\" title \"avg decryption request bytes sent\", \\" >> tmp/stats_vd.p			
			echo " '"$i"' using 2:4 with points lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with points lc rgb \"blue\" title \"inhibition bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition bytes sent\"" >> tmp/stats_vd.p
	
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of bytes\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG bytes sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_bytes_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_bytes_sent >> tmp/stats_vd.p
		echo "avg_drbs="$avg_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "stdev_drbs="$stdev_decryption_request_bytes_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_bytes_sent*0.5+$max_privacy_bytes_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG bytes sent : "$avg_DODAG_bytes_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG bytes sent : "$stdev_DODAG_bytes_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition bytes sent : "$avg_inhibition_bytes_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition bytes sent : "$stdev_inhibition_bytes_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		echo "set label 5 \"avg decryption request bytes sent : "$avg_decryption_request_bytes_sent"\" at graph  0.02, graph  0.75" >> tmp/stats_vd.p
		echo "set label 6 \"stdev decryption request bytes sent : "$stdev_decryption_request_bytes_sent"\" at graph  0.02, graph  0.70" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_ver2_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with lines lw 4 lc rgb \"green\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p			
			echo " '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with lines lw 4 lc rgb \"blue\" title \"inhibition bytes sent\"" >> tmp/stats_vd.p
			
			
			
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_ver2_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:8 with lines lw 4 lc rgb \"green\" title \"decryption request bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG bytes sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:6 with lines lw 4 lc rgb \"blue\" title \"inhibition bytes sent\"" >> tmp/stats_vd.p
			
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "avg_drms="$avg_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "stdev_drms="$stdev_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_messages_sent*0.5+$max_privacy_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG messages sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG messages sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		echo "set label 5 \"avg decryption request messages sent : "$avg_decryption_request_messages_sent"\" at graph  0.02, graph  0.75" >> tmp/stats_vd.p
		echo "set label 6 \"stdev decryption request messages sent : "$stdev_decryption_request_messages_sent"\" at graph  0.02, graph  0.70" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with points lc rgb \"green\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drms) with lines lw 4 lc rgb \"green\" title \"avg decryption request messages sent\", \\" >> tmp/stats_vd.p		
			echo " '"$i"' using 2:5 with points lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with points lc rgb \"blue\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
	
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with points lc rgb \"green\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_drms) with lines lw 4 lc rgb \"green\" title \"avg decryption request messages sent\", \\" >> tmp/stats_vd.p	
			echo " '"$i"' using 2:5 with points lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_dbs) with lines lw 4 lc rgb \"red\" title \"avg DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with points lc rgb \"blue\" title \"inhibition messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:(avg_ibs) with lines lw 4 lc rgb \"blue\" title \"avg inhibition messages sent\"" >> tmp/stats_vd.p
			
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p

		echo "set datafile separator \":\"" > tmp/stats_vd.p
		echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
		echo "set xlabel \"node id\"" >> tmp/stats_vd.p
		echo "set title \"all DODAG messages sent per node ID\"" >> tmp/TRA_anim.p
		echo "avg_ibs="$avg_inhibition_messages_sent >> tmp/stats_vd.p
		echo "stdev_ibs="$stdev_inhibition_messages_sent >> tmp/stats_vd.p
		echo "avg_dbs="$avg_DODAG_messages_sent >> tmp/stats_vd.p
		echo "stdev_dbs="$stdev_DODAG_messages_sent >> tmp/stats_vd.p
		echo "avg_drms="$avg_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "stdev_drms="$stdev_decryption_request_messages_sent >> tmp/stats_vd.p
		echo "set yrange[0:"`expr $max_privacy_messages_sent*0.5+$max_privacy_messages_sent`"]" >> tmp/stats_vd.p
		echo "set label 1 \"avg DODAG messages sent : "$avg_DODAG_messages_sent"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
		echo "set label 2 \"stdev DODAG messages sent : "$stdev_DODAG_messages_sent"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
		echo "set label 3 \"avg inhibition messages sent : "$avg_inhibition_messages_sent"\" at graph  0.02, graph  0.85" >> tmp/stats_vd.p
		echo "set label 4 \"stdev inhibition messages sent : "$stdev_inhibition_messages_sent"\" at graph  0.02, graph  0.80" >> tmp/stats_vd.p
		echo "set label 5 \"avg decryption request messages sent : "$avg_decryption_request_messages_sent"\" at graph  0.02, graph  0.75" >> tmp/stats_vd.p
		echo "set label 6 \"stdev decryption request messages sent : "$stdev_decryption_request_messages_sent"\" at graph  0.02, graph  0.70" >> tmp/stats_vd.p
		if [ $2 == "eps" ]; then
			echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_ver2_"$count".eps\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with lines lw 4 lc rgb \"green\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with lines lw 4 lc rgb \"blue\" title \"inhibition messages sent\"" >> tmp/stats_vd.p	
		elif [ $2 == "png" ]; then
			echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
			echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_ver2_"$count".png\"" >> tmp/stats_vd.p
			echo "plot '"$i"' using 2:9 with lines lw 4 lc rgb \"green\" title \"decryption request messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:5 with lines lw 4 lc rgb \"red\" title \"DODAG messages sent\", \\" >> tmp/stats_vd.p
			echo " '"$i"' using 2:7 with lines lw 4 lc rgb \"blue\" title \"inhibition messages sent\"" >> tmp/stats_vd.p			
		fi
		gnuplot tmp/stats_vd.p
		rm tmp/stats_vd.p


		#if [ $count == $max_samples ]; then

			echo "set datafile separator \":\"" > tmp/stats_vd.p
			echo "set view map" >> tmp/stats_vd.p
			echo "set palette model XYZ rgbformulae 7,5,15" >> tmp/stats_vd.p
			echo "set size ratio 1" >> tmp/stats_vd.p
			echo "set xlabel \"x\"" >> tmp/stats_vd.p
			echo "set ylabel \"y\"" >> tmp/stats_vd.p
			echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/stats_vd.p
			echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/stats_vd.p
			echo "set ylabel \"y\" rotate by 360" >> tmp/stats_vd.p
			echo "set cbrange[0:"`expr $max_DODAG_messages_sent + $max_inhibition_messages_sent +  $max_privacy_messages_sent`"]" >> tmp/stats_vd.p
			echo "set cblabel \" all DODAG messages sent \"" >> tmp/stats_vd.p
			echo "set title \" spatial distribution of all DODAG messages sent\"" >> tmp/stats_vd.p
			echo "unset key" >> tmp/stats_vd.p
			if [ $2 == "eps" ]; then
				echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_spatial_"$count".eps\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 16:17:("\$"5+"\$"7+"\$"9) with points palette pointsize 2 pointtype 7" >> tmp/stats_vd.p
			elif [ $2 == "png" ]; then 
				echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_PD_all_DODAG_messages_sent_spatial_"$count".png\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 16:17:("\$"5+"\$"7+"\$"9) with points palette pointsize 4 pointtype 7" >> tmp/stats_vd.p
			fi
			gnuplot tmp/stats_vd.p
			rm tmp/stats_vd.p

			echo "set datafile separator \":\"" > tmp/stats_vd.p
			echo "set view map" >> tmp/stats_vd.p
			echo "set palette model XYZ rgbformulae 7,5,15" >> tmp/stats_vd.p
			echo "set size ratio 1" >> tmp/stats_vd.p
			echo "set xlabel \"x\"" >> tmp/stats_vd.p
			echo "set ylabel \"y\"" >> tmp/stats_vd.p
			echo "set xrange[0-1:"$TOPO_x_ceiling"+1]" >> tmp/stats_vd.p
			echo "set yrange[0-1:"$TOPO_y_ceiling"+1]" >> tmp/stats_vd.p
			echo "set ylabel \"y\" rotate by 360" >> tmp/stats_vd.p
			echo "set cbrange[0:"`expr $max_DODAG_bytes_sent + $max_inhibition_bytes_sent +  $max_privacy_bytes_sent`"]" >> tmp/stats_vd.p
			echo "set cblabel \" all DODAG messages sent \"" >> tmp/stats_vd.p
			echo "set title \" spatial distribution of all DODAG bytes sent\"" >> tmp/stats_vd.p
			echo "unset key" >>  tmp/stats_vd.p
			if [ $2 == "eps" ]; then
				echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_spatial_"$count".eps\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 16:17:("\$"4+"\$"6+"\$"8) with points palette pointsize 2 pointtype 7" >> tmp/stats_vd.p
			elif [ $2 == "png" ]; then 
				echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
				echo "set output "\"""$nf"/STATS_PD_all_DODAG_bytes_sent_spatial_"$count".png\"" >> tmp/stats_vd.p
				echo "splot '"$i"' using 16:17:("\$"4+"\$"6+"\$"8) with points palette pointsize 4 pointtype 7" >> tmp/stats_vd.p
			fi
			gnuplot tmp/stats_vd.p
			rm tmp/stats_vd.p		
		#fi

		count=`expr $count + 1`
	done

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $3+$7+$11
		  xy_sum += $2*($3+$7+$11)
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $3+$7+$11
		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_DODAG_bytes_sent.txt

	DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dbs = $1 } END { print Dbs }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dbi = $2 }END { print Dbi }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dbr2 = $3 } END { print Dbr2 }' tmp/tmp_lin_regr_DODAG_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "All DODAG bytes sent slope ="$DODAG_bytes_slope
	echo "All DODAG bytes sent intercept ="$DODAG_bytes_inter
	echo "All DODAG bytes sent R2 ="$DODAG_bytes_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"bytes\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Correlation coefficient : "$DODAG_bytes_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f(x)="$DODAG_bytes_slope"*x+"$DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"3+"\$"7+"\$"11) with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"3+"\$"7+"\$"11)  with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $5+$9+$13
		  xy_sum += $2*($5+$9+$13)
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $5+$9+$13

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_DODAG_messages_sent.txt

	DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "All DODAG messages sent slope ="$DODAG_messages_slope
	echo "All DODAG messages sent intercept ="$DODAG_messages_inter
	echo "All DODAG messages sent R2 ="$DODAG_messages_r2
	echo "--------------------------------------------------------------"
	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"messages\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Correlation coefficient : "$DODAG_messages_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f(x)="$DODAG_messages_slope"*x+"$DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"5+"\$"9+"\$"13) with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG messages sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f(x) with lines title \"f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:("\$"5+"\$"9+"\$"13)  with points pointsize 2 pointtype 7 lc rgb \"red\" title \"all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $7
		  xy_sum += $2*$7
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $7

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt

	I_DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`
	I_DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`
	I_DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_I_DODAG_bytes_sent.txt`

	echo "--------------------------------------------------------------"
	echo "Inhibition DODAG bytes sent slope : "$I_DODAG_bytes_slope
	echo "Inhibition DODAG bytes sent intercept : "$I_DODAG_bytes_inter
	echo "Inhibition DODAG bytes sent R2 : "$I_DODAG_bytes_r2
	echo "--------------------------------------------------------------"

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $3
		  xy_sum += $2*$3
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $3

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt

	S_DODAG_bytes_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	S_DODAG_bytes_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	S_DODAG_bytes_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_S_DODAG_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Spread DODAG bytes sent slope : "$S_DODAG_bytes_slope
	echo "Spread DODAG bytes sent intercept : "$S_DODAG_bytes_inter
	echo "Spread DODAG bytes sent R2 : "$S_DODAG_bytes_r2
	echo "--------------------------------------------------------------"

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $11
		  xy_sum += $2*$11
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $11

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_decryption_requests_bytes_sent.txt

	decryption_requests_bytes_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_decryption_requests_bytes_sent.txt`
	decryption_requests_bytes_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_decryption_requests_bytes_sent.txt`
	decryption_requests_bytes_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_decryption_requests_bytes_sent.txt`
	echo "--------------------------------------------------------------"
	echo "decryption requests bytes sent slope="$decryption_requests_bytes_slope
	echo "decryption requests bytes sent intercept="$decryption_requests_bytes_inter
	echo "decryption requests bytes sent R2="$decryption_requests_bytes_r2
	echo "--------------------------------------------------------------"

	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"bytes\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG bytes sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Spread bytes correlation coefficient : "$S_DODAG_bytes_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f1(x)="$S_DODAG_bytes_slope"*x+"$S_DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 2 \"Inhibition bytes correlation coefficient : "$I_DODAG_bytes_r2"\" at graph  0.02, graph  0.90" >> tmp/tmp_lin_regr_DODAG.p
	echo "f2(x)="$I_DODAG_bytes_slope"*x+"$I_DODAG_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 3 \"Decr. req. bytes correlation coefficient : "$decryption_requests_bytes_r2"\" at graph  0.02, graph  0.85" >> tmp/tmp_lin_regr_DODAG.p
	echo "f3(x)="$decryption_requests_bytes_slope"*x+"$decryption_requests_bytes_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr_v2.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread bytes f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:3 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition bytes f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:7 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f3(x) with lines title \"Decryption request bytes f(x)\" lc rgb \"green\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:11 with points pointsize 2 pointtype 7 lc rgb \"green\" title \"Decryption request bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_bytes_sent_lin_regr_v2.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread bytes f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:3 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition bytes f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:7 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition bytes sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f3(x) with lines title \"Decryption request bytes f(x)\" lc rgb \"green\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:11 with points pointsize 2 pointtype 7 lc rgb \"green\" title \"Decryption request bytes sent\""  >> tmp/tmp_lin_regr_DODAG.p
	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $9
		  xy_sum += $2*$9
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $9

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_I_DODAG_messages_sent.txt

	I_DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	I_DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	I_DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_I_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Inhibition DODAG messages sent slope="$I_DODAG_messages_slope
	echo "Inhibition DODAG messages sent intercept="$I_DODAG_messages_inter
	echo "Inhibition DODAG messages sent R2="$I_DODAG_messages_r2
	echo "--------------------------------------------------------------"
	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $5
		  xy_sum += $2*$5
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $5

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_S_DODAG_messages_sent.txt

	S_DODAG_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	S_DODAG_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	S_DODAG_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_S_DODAG_messages_sent.txt`
	echo "--------------------------------------------------------------"
	echo "Spread DODAG messages sent slope="$S_DODAG_messages_slope
	echo "Spread DODAG messages sent intercept="$S_DODAG_messages_inter
	echo "Spread DODAG messages sent R2="$S_DODAG_messages_r2
	echo "--------------------------------------------------------------"

	awk 'BEGIN { FS = ":" }
	{ x_sum += $2
		  y_sum += $13
		  xy_sum += $2*$13
		  x2_sum += $2*$2
		  num += 1
		  x[NR] = $2
		  y[NR] = $13

		}
	END { mean_x = x_sum / num
	      mean_y = y_sum / num
	      mean_xy = xy_sum / num
	      mean_x2 = x2_sum / num
	      slope = (mean_xy - (mean_x*mean_y)) / (mean_x2 - (mean_x*mean_x))
	      inter = mean_y - slope * mean_x
	      for (i = num; i > 0; i--) {
		  ss_total += (y[i] - mean_y)^2
		  ss_residual += (y[i] - (slope * x[i] + inter))^2
	      }
	      r2 = 1 - (ss_residual / ss_total)
	      printf("%g:%g:%g", slope, inter, r2)
	    }' tmp/tmp_AGRR_DODAG_SENT.txt > tmp/tmp_lin_regr_decryption_requests_messages_sent.txt

	decryption_requests_messages_slope=`awk 'BEGIN{ FS=":" } { Dms = $1 } END { print Dms }' tmp/tmp_lin_regr_decryption_requests_messages_sent.txt`
	decryption_requests_messages_inter=`awk 'BEGIN{ FS=":" } { Dmi = $2 } END { print Dmi }' tmp/tmp_lin_regr_decryption_requests_messages_sent.txt`
	decryption_requests_messages_r2=`awk 'BEGIN{ FS=":" } { Dmr2 = $3 } END { print Dmr2 }' tmp/tmp_lin_regr_decryption_requests_messages_sent.txt`

	echo "--------------------------------------------------------------"
	echo "decryption request messages sent slope="$decryption_requests_messages_slope
	echo "decryption request messages sent intercept="$decryption_requests_messages_inter
	echo "decryption request messages sent R2="$decryption_requests_messages_r2
	echo "--------------------------------------------------------------"


	echo "set datafile separator \":\"" > tmp/tmp_lin_regr_DODAG.p
	echo "set xlabel \"time (sample steps)\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set ylabel \"messages\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set title \" linear regression of all DODAG messages sent\"" >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 1 \"Spread messages correlation coefficient : "$S_DODAG_messages_r2"\" at graph  0.02, graph  0.95" >> tmp/tmp_lin_regr_DODAG.p
	echo "f1(x)="$S_DODAG_messages_slope"*x+"$S_DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 2 \"Inhibition messages correlation coefficient : "$I_DODAG_messages_r2"\" at graph  0.02, graph  0.90" >> tmp/tmp_lin_regr_DODAG.p
	echo "f2(x)="$I_DODAG_messages_slope"*x+"$I_DODAG_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set label 3 \"Decr. req. messages correlation coefficient : "$decryption_requests_messages_r2"\" at graph  0.02, graph  0.85" >> tmp/tmp_lin_regr_DODAG.p
	echo "f3(x)="$decryption_requests_messages_slope"*x+"$decryption_requests_messages_inter >> tmp/tmp_lin_regr_DODAG.p
	echo "set xrange[0:"`expr $max_samples*1.5`"]" >> tmp/tmp_lin_regr_DODAG.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr_v2.eps\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread messages f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:5 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread messages sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition messages f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:9 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition messages sent\, \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f3(x) with lines title \"Decryption request messages f(x)\" lc rgb \"green\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:13 with points pointsize 2 pointtype 7 lc rgb \"green\" title \"Decryption request messages sent\""  >> tmp/tmp_lin_regr_DODAG.p

	elif [ $2 == "png" ]; then 
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/tmp_lin_regr_DODAG.p
		echo "set output "\"""$nf"/STATS_VD_all_DODAG_messages_sent_lin_regr_v2.png\"" >> tmp/tmp_lin_regr_DODAG.p
		echo "plot f1(x) with lines title \"Spread messages f(x)\" lc rgb \"blue\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:5 with points pointsize 2 pointtype 7 lc rgb \"blue\" title \"Spread messages sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f2(x) with lines title \"Inhibition messages f(x)\" lc rgb \"red\", \\" >> tmp/tmp_lin_regr_DODAG.p
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:9 with points pointsize 2 pointtype 7 lc rgb \"red\" title \"Inhibition messages sent\", \\"  >> tmp/tmp_lin_regr_DODAG.p
		echo "f3(x) with lines title \"Decryption request messages f(x)\" lc rgb \"green\", \\" >> tmp/tmp_lin_regr_DODAG.p	
		echo "'tmp/tmp_AGRR_DODAG_SENT.txt' using 2:13 with points pointsize 2 pointtype 7 lc rgb \"green\" title \"Decryption request messages sent\""  >> tmp/tmp_lin_regr_DODAG.p		

	fi
	gnuplot tmp/tmp_lin_regr_DODAG.p
	rm tmp/tmp_lin_regr_DODAG.p



echo "##############################################################"
echo
echo
echo
fi
###############################
#rm -rf $1
#rm -rf tmp

