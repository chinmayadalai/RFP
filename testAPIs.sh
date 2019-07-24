#!/bin/bash
#
# Copyright Example. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

config_file="project-config.json"

NETWORK="$( jq -r '.FAB_NET_NM' "$config_file" )"
CHANNEL="$( jq -r '.CHANNEL' "$config_file" )"
CHAINCODE="$( jq -r '.CHAINCODE' "$config_file" )"
CHAINCODE_V="$( jq -r '.CHAINCODE_V' "$config_file" )"

ORG1_NAME="$( jq -r '.ORG1_NAME' "$config_file" )"
ORG1_MSP="$( jq -r '.ORG1_MSP' "$config_file" )"

PEER0_ORG1="$( jq -r '.PEER0_ORG1' "$config_file" )"

INIT_FUNCTION="$( jq -r '.INIT_FUNCTION' "$config_file" )"
INVOKE_FUNCTION="$( jq -r '.INVOKE_FUNCTION' "$config_file" )"
QUERY_FUNCTION="$( jq -r '.QUERY_FUNCTION' "$config_file" )"
INIT_ARGS="$( jq -r '.INIT_ARGS' "$config_file" )"
INVOKE_ARGS="$( jq -r '.INVOKE_ARGS' "$config_file" )"
QUERY_ARGS="$( jq -r '.QUERY_ARGS' "$config_file" )"


echo "Network name is ${NETWORK}_default"
echo "Channel name is ${CHANNEL}"
echo "Chaincode name is ${CHAINCODE}"
echo "Chaincode version is ${CHAINCODE_V}"

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/${NETWORK}_cc/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/${NETWORK}/src/github.com/${NETWORK}_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

rm -rf token.txt

echo
echo "POST request Enroll on ${ORG1_NAME}  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d "username=Jim&orgName=${ORG1_NAME}")
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "${ORG1_NAME} token is $ORG1_TOKEN"
echo

echo $ORG1_TOKEN>>token.txt

echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"channelName\":\"${CHANNEL}\",
	\"channelConfigPath\":\"../${NETWORK}/channel/${CHANNEL}.tx\"
}"
echo 
echo


sleep 5
echo "POST request Join channel on ${ORG1_NAME}"
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/peers" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"${PEER0_ORG1}\"]
}"
echo
echo

echo "POST request Update anchor peers on ${ORG1_NAME}"
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/anchorpeers" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"configUpdatePath\":\"../${NETWORK}/channel/${ORG1_MSP}anchors.tx\"
}"
echo
echo

echo "POST Install chaincode on ${ORG1_NAME}"
echo
curl -s -X POST \
 http://localhost:4000/chaincodes \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"${PEER0_ORG1}\"],
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"${CHAINCODE_V}\",
	\"chaincodeName\":\"${CHAINCODE}\"
}"
echo
echo

echo "POST instantiate chaincode on ${ORG1_NAME}"
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeVersion\":\"${CHAINCODE_V}\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"$INIT_ARGS\"],
	\"chaincodeName\":\"${CHAINCODE}\",
  	\"fcn\":\"$INIT_FUNCTION\"
}"
echo
echo

echo "POST invoke test chaincode on peers of ${ORG1_NAME}"
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"${INVOKE_FUNCTION}\",
        \"transient_data\":"[]",
  	    \"args\":"[]"
}"
echo
echo

echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
