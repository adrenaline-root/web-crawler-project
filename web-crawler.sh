#!/bin/bash

# database connection
PSQL="psql -X --username=usuario --dbname=web_crawler --tuples-only -c"


# print greeting
echo -e "\n~~~~~~~~~~  Bienvenido al mapeador de webs  ~~~~~~~~~~\n"

# if no first parameter as target has been provided, ask for target url
if [[ -z $1 || $1 =~ ^[0-9]*$ ]]
then 
	echo -e "\nNo has introducido ningún objetivo.\nPor favor, introduce uno para poder continuar:"
	read TARGET
else
	TARGET="$1"
fi


# check if target is already in database
TARGET_DB=$($PSQL "SELECT * FROM urls WHERE url='$TARGET'")
IFS=" | " read -ra target_db <<< $TARGET_DB

# if target is not in database
if [[ -z $TARGET_DB ]]
then
	echo ">> $TARGET no está en tu database."
else
	echo ">> ${target_db[1]} ya existe en tu database y ha sido mapeado al ${target_db[2]} %."
fi


# if first argument is number
if [[ "$TARGET" =~ ^[0-9]*$ ]]
then
	PERCENTAGE=$1
# if first argument is not number
else
# if second argument is not provided or not a number
	if [[ -z "$2" || ! "$2" =~ ^[0-9]*$ ]]
	then 
		echo "No has introducido ningún porcentaje de mapeo. ¿Qué porcetaje de $TARGET te gustaría mapear?"
		read PERCENTAGE
	
	# if second argument provided
	else
		PERCENTAGE=$2
	fi
fi

# while percentage is not valid
while [[ "$PERCENTAGE" -lt "0" || "$PERCENTAGE" -gt "100" ||  "${target_db[2]}" -ge "$PERCENTAGE" ]]
do
	if [[ $PERCENTAGE -lt "0" || "$PERCENTAGE" -gt "100" ]]
	then 
		echo "El porcentaje introducido debe estar en el rango {0, 100}. Por favor, introduce un porcentaje válido:"
		read PERCENTAGE
	else
		echo "El porcentaje mapeado es mayor o igual que el introducido. Por favor introduce un porcentaje de mapeo mayor al ${target_db[2]} %:"
		read PERCENTAGE

	fi
done

if [[ ! -z $TARGET_DB ]]
then
	echo "Actualizando porcentaje..."
fi



# parse TARGET TO >> https format
TARGET=$(echo -e "$TARGET" | sed -r 's/(https:\/\/)//; s/(.*)/https:\/\/\1/')


# depth
DEPTH=0

CONNECTING_TO_URL() {

	TARGET="$1"
	DEPTH=$2
	PERCENTAGE=$3
	
	SITE=$(echo $TARGET | sed -r 's/http[s]:\/\///g')

	# if connection has been established correctly
	CONNECTION_RESULT=$(curl --silent "$TARGET" > /dev/null; echo $?)
	
	if [[ $CONNECTION_RESULT == '0' ]]
	then
		# print succes conection message
		echo -e "\n>> Conexión establecida con éxito. Mapeando $TARGET al $PERCENTAGE %..."
		
		TARGET_ID=$($PSQL "SELECT url_id FROM urls WHERE url='$TARGET'")
		
		# push url to web-crawler-database
		
		if [[ -z $TARGET_ID ]]
		then
			$PSQL "INSERT INTO urls(url, mapped) VALUES('$TARGET', 0);"
			DEPTH=0
		else
			DEPTH=$($PSQL "SELECT depth FROM nodes WHERE mapped < $PERCENTAGE AND path LIKE '%$SITE%' LIMIT 1")
		fi
		((DEPTH+=1))
		
		bash ./mapping.sh $TARGET $DEPTH $PERCENTAGE
		
		node=$($PSQL "SELECT path, depth FROM nodes WHERE mapped < $PERCENTAGE AND path LIKE '%$SITE%' LIMIT 1")
		
		while [[ ! -z $node ]]
		do
			echo "$node" | while read path bar depth
			do
				((depth+=1))
				bash ./mapping.sh $path $depth $PERCENTAGE
				$PSQL "UPDATE nodes SET mapped=$PERCENTAGE WHERE path='$path';"
			done
			node=$($PSQL "SELECT path, depth FROM nodes WHERE mapped < $PERCENTAGE AND path LIKE '%$SITE%' LIMIT 1")
		done 
		
		$PSQL "UPDATE urls SET mapped=$PERCENTAGE WHERE url='$TARGET'"
		
	fi
	
}

CONNECTING_TO_URL $TARGET $DEPTH $PERCENTAGE





