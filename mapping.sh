#!/bin/bash

# database connection
PSQL="psql -X --username=usuario --dbname=web_crawler --no-align --tuples-only -c"

# maps the web searching for links
MAP() { # arguments: path, depth

	# extract path structure components
	server=$(echo "$1" | sed -r 's/(http[s]*:\/\/)([^\/]*)(.*)/\2/g')
	
	node="$1"
	depth=$2
	percentage=$3
	
	# getting parent_node_id
	parent_node_id=0;
	
	if [[ $depth != 1 ]]
	then
		parent_node_id=$($PSQL "SELECT node_id FROM nodes WHERE path='$1'")
	fi
	
	### identify NODE directories structure
	
	prefijo=$(echo "$node" | sed -r 's/(http[s]*:)(.*)/\1/')
	structure=$(echo "$node" | sed -r 's/(http[s]*:\/\/)//; s/\//\|/g')
	IFS="|" read -ra directories <<< $structure

		
	#### PROCEDURE TO LINKS EXTRACTION
	
	echo -e "\n>> TARGET: $node"
	echo -e "\n>> GETTING LINKS IN DEPTH $depth ----"
	
	links=$(curl --silent "$node" | sed -r 's/<a/\n<a/g' | grep -E "<a .*[ ]*href" | sed -r 's/\x27/\"/g' | sed -r 's/(.*)(href=[\"][^"]*[\"])(.*)/\2/g; s/(href=[\"])([^\"]*)([\"])/\2/g')
	
	
	### FILTER LINKS INTO SITE NODES OR FOREIGN SITES
	
	# choose links based on map progress achieved (from last site porcentage cover to new one)) ()
	
	# get last percentage achieved on server
	PERCENTAGE_MAPPED=$($PSQL "SELECT mapped FROM urls WHERE url LIKE '%$server%'")
	
	# get amount of links in total
	total_links_amount=$(echo -e "$links" | sed -n '$=')
	
	# get the last line (based on last porcentage) where the mapping left the process
	starting_line_is_at=$(expr $PERCENTAGE_MAPPED \* $total_links_amount / 100 )
	if [[ $PERCENTAGE_MAPPED == '0'  || $starting_line_is_at == '0' ]]
	then 
		starting_line_is_at=1
	fi
	
	ending_line_is_at=$(expr $percentage \* $total_links_amount / 100 )
	if [[ $ending_line_is_at == '0' ]]
	then
		ending_line_is_at=1
	fi
	
	links=$(echo -e $links | sed -r 's/ /\n/g' | sed -n "${starting_line_is_at},${ending_line_is_at}p")
	
	# loop through links to check where to add them
	echo -e $links | sed -r 's/ /\n/g' | while IFS= read link
	do
		path=$(echo $link)
		
		# if link has http[s] prefix add to web-urls-table if is not part of site
		if [[ $path =~ http[s]* ]]
		then
			#parseS3=$(echo $3 | sed -r 's/http[s]*/https/g')
			
			# if path is not part of server
			if [[ ! "$path" =~ "$server" ]]
			then
				# extract foreign server's url and add to urls-database
				path=$(echo "$path" | sed -r 's/(http[s]*:\/\/[^\/]*)(.*)/\1/')
				if [[ -z $($PSQL "SELECT * FROM urls WHERE url='$path'") ]]
				then
					echo -e "\n>> Encontrado un link ajeno a la estructura de $server:\n: $path\n"
					$PSQL "INSERT INTO urls(url, mapped) VALUES('$path', 0);"
					echo -e " : $path"
				fi
			
			# else add to nodes-table
			else
				
				CANDIDATE_TO_ADD=$($PSQL "SELECT * FROM nodes WHERE path='$path'")
				if [[ -z $CANDIDATE_TO_ADD ]]
				then
					$PSQL "INSERT INTO nodes(path, depth, mapped, parent_node_id) VALUES('$path', $depth, 0, $parent_node_id);"
					echo -e " : $path"
				fi
			fi
			
			
			
		# if link has no http[s] prefix add to web-nodes-table
		else 
		
			# if $path is full url
			if [[ $path != "" && $path != "/" ]]
			then
				# clean path from first / character
				if [[ $path =~ ^/ ]]
				then 
					path=$(echo -e $path | sed -r 's/\///')
				fi
				
				dir_length=${#directories[@]}
				dir_cpy=("${directories[@]}")
				
				# if last element of body directories is file, delete that part from body path array
				if [[ ${directories[$dir_length - 1]} =~ . && $dir_length > 1 ]]
				then
					((dir_length-=1))
					unset dir_cpy[$dir_length]
				fi
				
				# convert candidate  path into array base on / separation if candidate not just file
				if [[ $path =~ "/" ]]
				then
					IFS="/" read -ra candidate_tree <<< $path

					# if path has ../, go up as many level as ../ times in body path array
					level_back=${#dir_cpy[@]}
					
					# loop thought the candidate path array looking from ../ triggers back 
					count=0
					for i in "${candidate_tree[@]}"
					do
						# if ../ found, go back one level on the body path array and delete candidate path element
						if [[ $i =~ ".." ]]
						then
							((level_back-=1))
							unset candidate_tree[$count]
							((count+=1))
						fi
					done
					node_body=""
					
					# reconstruct body path from body path array
					for (( j=0; j<(($level_back)); j++ ))
					do
						node_body+="${dir_cpy[$j]}/"
					done
					
					# reconstruct candidate path from candidate path array
					path=$(echo ${candidate_tree[*]} | sed -r 's/ /\//g')

				else # If candidate just a file or an alone directory node
					node_body=$(echo ${dir_cpy[*]} | sed -r 's/ /\//g')
					node_body+="/"
				fi
	
				# add node to nodes table if extension is htm[l]
				CANDIDATE_TO_ADD=$($PSQL "SELECT * FROM nodes WHERE path='$prefijo//$node_body$path'")
				if [[ $path =~ .htm && -z $CANDIDATE_TO_ADD ]]
				then
					echo -e " : $prefijo//$node_body$path"
					$PSQL "INSERT INTO nodes(path, depth, mapped, parent_node_id) VALUES('$prefijo//$node_body$path', $depth, 0, $parent_node_id);"
				fi
				
			fi
		fi
	done

}

MAP $1 $2 $3

