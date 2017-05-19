#!/bin/bash
##################################################################################
# Date  : 05/04/2017
# Author: HHuo
# Usage :  
#		   ./admintool.sh hhuo 127.0.0.1:4000,127.0.0.1:4001,127.0.0.1:4002,127.0.0.1:4003 TestPOA SM2 4 5000 true /Users/huohongbo/tools/cita/data
# Params:
#		1.   SIZE            -- node SIZE
#		2.   CONSENSUS_NAME
#       3.   DATA_PATH       -- All the configuration's path
##################################################################################
#ADMIN_ID=$1
#IP_LIST=$2
#CONSENSUS_NAME=$3
#CRYPTO_METHOD=$4
#SIZE=$5
#DURATION=$6
#IS_TEST=$7
#DATA_PATH=$8

##################################################################################
#							The Command Line Help								 #
##################################################################################
display_help()
{
	echo 
	echo "Usage: $0 [option...] {ADMIN_ID} {IP_LIST} {CONSENSUS_NAME} {CRYPTO_METHOD} {SIZE} {DURATION} {IS_TEST} {DATA_PATH}"
	echo
	echo "Parameter 1 - ADMIN_ID :  This is for genesis block"
	echo "	The default value is [admin] "
	echo "Parameter 2 - IP_LIST  :  This parameter list all the node's IP and port"
	echo "	The default value is [127.0.0.1:4000,127.0.0.1:4001,127.0.0.1:4002,127.0.0.1:4003]"
	echo "Parameter 3 - CONSENSUS_NAME : This is for the consensus we choose"
	echo "	The default value is ['tendermint']"
	echo "Parameter 4 - CRYPTO_METHOD : This is for the crypto"
	echo "	The default value is ['SECP']"
	echo "Parameter 5 - SIZE : This is for node size we setup for CITA"
	echo "	The default value is [4]"
	echo "Parameter 6 - DURATION : This is for the block generating duration"
	echo "	The default value is [3000]"
	echo "Parameter 7 - IS_TEST : This is test flag"
	echo "	The default is [false]"
	echo "Parameter 8 - DATA_PATH: This is the path for all the configuration files"
	echo
#	exit 0
}
echo "=====================Welcome to use Admin Tool====================="
echo ""
while [ -n "$1" ]; do
case $1 in 
	-h|--help) 
		display_help
		shift 1
		;;	# show this tool's Usage
	--) 
		shift
		break
		;; # end of options 
	-*) 
		echo "error: no such option $1. -h for help"
		exit 1
		;; 
	*) 
		break
		;; 
esac 
done 

read -p "Enter the ADMIN_ID:" ADMIN_ID
if [ ! -n "$ADMIN_ID" ]; then
 ADMIN_ID="admin"
fi

read -p "Enter the IP_LIST:" IP_LIST
if [ ! -n "$IP_LIST" ]; then
 IP_LIST="127.0.0.1:4000,127.0.0.1:4001,127.0.0.1:4002,127.0.0.1:4003"
fi

read -p "Enter the CONSENSUS_NAME:" CONSENSUS_NAME
if [ ! -n "$CONSENSUS_NAME" ]; then
 CONSENSUS_NAME="tendermint"
fi

read -p "Enter the CRYPTO_METHOD:" CRYPTO_METHOD
if [ ! -n "$CRYPTO_METHOD" ]; then
 CRYPTO_METHOD="SECP"
fi

read -p "Enter the SIZE:" SIZE
if [ ! -n "$SIZE" ]; then
 SIZE=4
fi

read -p "Enter the DURATION:" DURATION
if [ ! -n "$DURATION" ]; then
 DURATION=3000
fi

read -p "Enter the IS_TEST:" IS_TEST
if [ ! -n "$IS_TEST" ]; then
 IS_TEST=false
fi

read -p "Enter the DATA_PATH:" DATA_PATH
if [ ! -n "$DATA_PATH" ]; then
 DATA_PATH=../data
fi

if [ ! -f "$DATA_PATH" ]; then
 mkdir $DATA_PATH
fi

echo "Step 1: ********************************************************"
echo "Start Genesis Block's Configuration creating!"
python create_keys_addr.py $DATA_PATH 
python create_genesis.py $ADMIN_ID $CRYPTO_METHOD $DATA_PATH 

if [ -f "$DATA_PATH/authorities" ]; then
 rm $DATA_PATH/authorities
fi

echo "End for Genesis Block Configuration creating!"
echo "Step 2: ********************************************************"
for ((ID=0;ID<$SIZE;ID++))
do
	mkdir $DATA_PATH/node$ID
	echo "Start generating private Key for Node" $ID "!"
	python create_keys_addr.py $DATA_PATH $ID 
	echo "[PrivateKey Path] : " $DATA_PATH/node$ID
	echo "End generating private Key for Node" $ID "!"
	cp $DATA_PATH/genesis.json $DATA_PATH/node$ID/
	echo "Start creating Network Node" $ID "Configuration!"
	python create_network_config.py $DATA_PATH $ID $SIZE $IP_LIST
	echo "End creating Network Node" $ID "Configuration!"
	echo "########################################################"
done
echo "Step 3: ********************************************************"
for ((ID=0;ID<$SIZE;ID++))
do
	echo "Start creating Node " $ID " Configuration!"
	python create_node_config.py $DATA_PATH $CONSENSUS_NAME $ID $DURATION $IS_TEST
	echo "End creating Node " $ID "Configuration!"
done
echo "All tasks have been done!"
echo "********************************************************"