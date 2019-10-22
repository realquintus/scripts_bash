#!/bin/bash
usage(){
	echo -e "Mkgraph is a script that can create or combine dot files in order to make a net map.\n\nOptions:\n\t-f : This option is required, enter a file that will be used to create the dot file.\n\t-a : Use this option to enter the IPv4 address that will be add to the file.\n\t-A : Use this option to enter a AS number, if not entered the AS will be [AS?].\n\t-e : Use it to indicate that this line is the last of the file, in order to add '}' at the end.\n\t-c : This option is used to combine 2 dot in a file named NetMap.dot. Enter the second file after. You can also choose a name different than NetMap by indicating the name after ':'.\n\t\tExemple: ./mkgraph.sh -f file.dot -c other_file.dot:example.dot\n\t\t-m : This option need to by used with -c. It will add the fill entered with -c to the file entered with -f";
}
while getopts "hc:f:a:A:em" option;do
	case $option in
		h)
			usage
			exit 0;
			;;
		c)
			combine="true";
			if [[ $(echo $OPTARG | grep ":") ]];then
				file_to_combine=$(echo $OPTARG | cut -d":" -f1);
				dst_file=$(echo $OPTARG | cut -d":" -f2);
			else
				file_to_combine=$OPTARG;
				dst_file="NetMap.dot";
			fi;
			;;
		f)
			file=$OPTARG;
			;;
		a)
			host=$OPTARG;
			;;
		A)
			AS=$OPTARG;
			;;
		e)
			end="true";
			;;
		m)
			if [[ $combine = "true" ]];then
				modify="true";
			else
				usage;
				exit 1;
			fi;
			;;
		esac;
done
if [[ $combine = "true" ]];then
	if [[ $modify = "true" ]];then
		sed -i '$d' $file;
		sed '1,7d' $file_to_combine >> $file;
	else
		sed '$d' $file > $dst_file;
		sed '1,7d' $file_to_combine >> $dst_file;
	#while read line;do
	#	if [[ $(cat combine_$file | grep "$(echo $line | cut -d';' -f1)" ) = "" ]];then
	#	echo -e "\t$line" >> combine_$file;
	#	fi;
	#done < file.tmp;
	#uniq combine_$file > combine_$file;

	fi;
else
	colors=("" "" "darkorange" "darkorchid4" "firebrick" "chocolate" "blueviolet" "red4" "salmon" "slateblue3" "goldenrod" "darkslategrey" "darkslategrey" "peru" "yellowgreen" "crimson"); # Color array
	if [[ $(cat $file) = "" ]];then # Write begining of .dot file and style informations
		echo "digraph NetMap{" > $file;
		echo -e "\tbgcolor=azure;" >> $file;
		echo -e "\tnode [shape=box, color=lightblue2, style=filled];" >> $file;
		echo -e "\tedge [arrowsize=2, color=gold];" >> $file;
		echo -e "\tlocalhost [color=blue]" >> $file;
		echo -e "\tlocalhost -> " >> $file;
	fi;

	if [[ $AS = "#" ]];then #Check if the AS is known
		AS="AS?";
		AScolor="lightblue2";

	elif ! [[ $(cat AS.txt | grep "$AS") = "" ]];then # Check if the AS number is written in AS.txt
		AScolor=${colors[$(cat -n AS.txt | grep $AS | awk '{print $1}')]}; #Use the line number of AS number in color array
		cat -n AS.txt | grep $AS;
	else
		echo $AS >> AS.txt; # Write the AS number in AS.txt
		AScolor=${colors[$(cat AS.txt | wc -l)]};
	fi;

	if [[ $(echo $host | egrep -o '([0-9]{1,3}\.){3}[0-9]{1,3}') = $host ]];then
		sed -i 's/ $/'" \"$host [$AS]\";\"$host [$AS]\" [color=$AScolor];"'/' $file;
	else
		sed -i 's/ $/'" \"$host [$AS]\";\"$host [$AS]\" [color=red];"'/' $file;
	fi

	if ! [[ $end = "true" ]];then	
		echo -e "\t\"$host [$AS]\" -> " >> $file;
	else
		echo -e "\t\"$host [$AS]\" [color=blue];" >> $file;
		echo "}" >> $file;
	fi;
fi;
