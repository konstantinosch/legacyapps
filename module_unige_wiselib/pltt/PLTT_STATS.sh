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
rm tmp/CON.p
echo "set datafile separator \":\"" > tmp/CON.p
echo "set xlabel \"time\"" >> tmp/CON.p
echo "set ylabel \"connectivity\"" >> tmp/CON.p
echo "set title \"average topology connectivity convergence\"" >> tmp/CON.p
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
	echo $yy":"$tracker_id1":"$target_id1
file1=$yy
	if [ "$file1"!="$empty" ] && [ "$file2"!="$empty" ] && [ "$file3"!="$empty" ]; then
		echo $file1 $file2 $file3
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
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "QTR" ) &&( $2 == id ) ) { print $0} }' $1 > tmp/tmp_REP_init.txt #all reports generated from tracker
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "RTR" ) &&( $3 == id ) ) { print "RTR:"$5} }' $1 > tmp/tmp_RTR.txt #pre_hop_report comm range filter
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "LMQ" ) &&( $7 == id ) ) { print "LMQ:"$5} }' $1 > tmp/tmp_LMQ.txt #hop count limit on query
		awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{  if ( ( $1 == "LMR" ) &&( $7 == id ) ) { print "LMR:"$5} }' $1 > tmp/tmp_LMR.txt #hop count limit on reports

		cat tmp/tmp_REP_init.txt tmp/tmp_TR_full.txt | awk 'BEGIN{ FS=":"; tra_index=0; q_index=0; }
		{
		}
		END{}'

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
						#print i":"tracker_agent_id[i]"="q_id[j]
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

		cat tmp/tmp_REP_not_found.txt tmp/tmp_RTR_not_found.txt tmp/tmp_LMQ.txt tmp/tmp_LMR.txt | awk 'BEGIN{ FS=":"; m_index=0; k_index=0; }
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
		pre_report_hop=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "RTR" ) &&( $3 == id ) ) { i=i+1; } }END{ print i }' $1`
		reports_missed_hop_count_lim_Q=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "LMQ" ) && ( $7 == id )  ) { i=i+1; } }END{ print i }' $1`
		reports_missed_hop_count_lim_R=`awk -v id=$tracker_id1 'BEGIN{FS=":"; i=0; }{ if ( ( $1 == "LMR" ) && ( $7 == id )  ) { i=i+1; } }END{ print i }' $1`
		reports_missed_out_of_range=`expr $pre_report_hop - $row_sum`
		echo "all reports="$all_reports
		echo "all successfull reports="$row_sum
		echo "reports missed [due to zero echoes]="$reports_missed_zero_echoes
		echo "reports missed [out of comm range]="$reports_missed_out_of_range
		echo "reports missed [exceeded hop count limit(R)]="$reports_missed_hop_count_lim_R
		echo "reports missed [exceeded hop count limit(Q)]="$reports_missed_hop_count_lim_Q
		echo "success rate="$success_rate
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
done
###############################

#MESSAGE STATISTICS
###############################

count=0
sort -t: -k 2n $1 | awk 'BEGIN { FS=":"; } { if ( $1 == "STATS_VD" ) { print $0 > "tmp/tmp_STATS_VD_"$3".txt" } }'
for i in tmp/tmp_STATS_VD_*; do
		
	avg_DODAG_messages_send=`awk 'BEGIN { FS=":"; sum=0; } { sum+=$4 } END { print sum/NR}' $i`
	stdev_DODAG_messages_send=`awk 'BEGIN { FS=":";} { sum+=$4; array[NR]=$4 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

	avg_DODAG_bytes_send=`awk 'BEGIN { FS=":"; sum=0; } {  sum+=$5 } END { print sum/NR}' $i`
	stdev_DODAG_bytes_send=`awk 'BEGIN { FS=":";} { sum+=$5; array[NR]=$5 } END {for(x=1;x<=NR;x++){sumsq+=((array[x]-(sum/NR))^2);}print sqrt(sumsq/NR)}' $i`

	echo "set datafile separator \":\"" > tmp/stats_vd.p
	echo "set ylabel \"number of messages\"" >> tmp/stats_vd.p
	echo "set xlabel \"node id\"" >> tmp/stats_vd.p
	echo "avg_dms="$avg_DODAG_messages_send >> tmp/stats_vd.p
	echo "stdev_dms="$stdev_DODAG_messages_send >> tmp/stats_vd.p
	echo "set label 1 \"avg DODAG_messages_send : "$avg_DODAG_messages_send"\" at graph  0.02, graph  0.95" >> tmp/stats_vd.p
	echo "set label 2 \"stdev DODAG_messages_send : "$stdev_DODAG_messages_send"\" at graph  0.02, graph  0.90" >> tmp/stats_vd.p
	if [ $2 == "eps" ]; then
		echo "set terminal postscript eps enhanced color font 'Helvetica,12'" >> tmp/stats_vd.p
		echo "set output "\"""$nf"/STATS_VD_"$count".eps\"" >> tmp/stats_vd.p
		echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG messages send\", \\" >> tmp/stats_vd.p
		echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages send\"" >> tmp/stats_vd.p
	elif [ $2 == "png" ]; then
		echo "set terminal png font '/usr/share/fonts/truetype/ttf-liberation/LiberationSans-Regular.ttf' 16 size 1280,1024" >> tmp/stats_vd.p
		echo "set output "\"""$nf"/STATS_VD_"$count".png\"" >> tmp/stats_vd.p
		echo "plot '"$i"' using 2:4 with lines lw 4 lc rgb \"red\" title \"DODAG messages send\", \\" >> tmp/stats_vd.p
		echo " '"$i"' using 2:(avg_dms) with lines lw 4 lc rgb \"blue\" title \"avg DODAG messages send\"" >> tmp/stats_vd.p
	fi
	gnuplot tmp/stats_vd.p
	#rm tmp/stats_vd.p
	count=`expr $count + 1`
done

###############################
#rm -rf $1
#rm -rf tmp

