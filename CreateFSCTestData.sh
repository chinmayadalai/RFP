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
TRANSIENT_FUNCTION="$( jq -r '.TRANSIENT_FUNCTION' "$config_file" )"
TRANSIENT_ARGS="$( jq -r '.TRANSIENT_ARGS' "$config_file" )"


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

file="token.txt" 
ORG1_TOKEN=$(cat "$file")

echo "POST invoke createRFxAsset chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"createRFxAsset\",
        \"transient_data\":"[]",
  	    \"args\":[\"15515\",\"Released\",\"DLA-COLUMBUS\",\"B-1B\",\"15515\",\"2019-02-08 16:56:20\",\"DLA-Columbus\",\"DLA-Columbus User\",\"2019-09-20 01:00:18\"]
}"
echo
echo

echo "POST invoke updateStatusToReceived chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToReceived\",
        \"transient_data\":"[]",
        \"args\":[\"15515\",\"Received\",\"2019-02-09 16:56:50\",\"PROP-19-000020\",\"SOS Team\",\"SOS User\"]
}"
echo
echo

echo "POST invoke updateStatusToPartVerification on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToPartVerification\",
        \"transient_data\":"[]",
        \"args\":[\"15515\",\"Part Verification\",\"2019-02-25 00:00:00\",\"Engineering\",\"Engineering User\"]
}"
echo
echo

echo "POST updateStatusToEstimationCompletion on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToEstimationCompletion\",
        \"transient_data\":"[]",
        \"args\":[\"15515\",\"Estimation Complete\",\"2019-04-07 00:00:00\",\"2019-03-07 00:00:00\",\"2019-03-27 00:00:00\",\"2019-03-08 00:00:00\"
        ,\"2019-03-10 00:00:00\",\"2019-03-15 00:00:00\",\"2019-04-05 00:00:00\",\"Supplier Mgmt\",\"Supplier Mgmt User\"]
}"
echo
echo

echo "POST updateStatusToPricingComplete on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToPricingComplete\",
        \"transient_data\":"[]",
        \"args\":[\"15515\",\"Pricing Complete\",\"2019-05-07 00:00:00\",\"Contracts\",\"Contracts User\"]
}"
echo
echo

echo "POST updateStatusToSubmitted on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToSubmitted\",
        \"transient_data\":"[]",
        \"args\":[\"15515\",\"Submitted\",\"2019-05-10 00:00:00\",\"123546987.23\",\"Contracts\",\"Contracts User\"]
}"
echo
echo

echo "POST invoke createRFxAsset chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"createRFxAsset\",
        \"transient_data\":"[]",
  	    \"args\":[\"15677\",\"Released\",\"DLA-COLUMBUS\",\"B-1B\",\"TEST123TESTT\",\"2019-06-18 10:25:21\",\"DLA-Columbus\",\"DLA-Columbus User\",\"2019-10-27 01:00:18\"]
}"
echo
echo

echo "POST invoke updateStatusToReceived chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToReceived\",
        \"transient_data\":"[]",
        \"args\":[\"15677\",\"Received\",\"2019-06-18 14:25:21\",\"PROP-19-000066\",\"SOS Team\",\"SOS User\"]
}"
echo
echo

echo "POST invoke updateStatusToPartVerification on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToPartVerification\",
        \"transient_data\":"[]",
        \"args\":[\"15677\",\"Part Verification\",\"2019-07-25 00:00:00\",\"Engineering\",\"Engineering User\"]
}"
echo
echo

echo "POST updateStatusToEstimationCompletion on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToEstimationCompletion\",
        \"transient_data\":"[]",
        \"args\":[\"15677\",\"Estimation Complete\",\"2019-08-07 00:00:00\",\"2019-08-07 00:00:00\",\"2019-08-27 00:00:00\",\"2019-08-08 00:00:00\"
        ,\"2019-09-10 00:00:00\",\"2019-09-15 00:00:00\",\"2019-10-05 00:00:00\",\"Supplier Mgmt\",\"Supplier Mgmt User\"]
}"
echo
echo

echo "POST invoke createRFxAsset chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"createRFxAsset\",
        \"transient_data\":"[]",
  	    \"args\":[\"18554\",\"Released\",\"DLA-COLUMBUS\",\"C-17\",\"SPE7AS-HV-3-368\",\"2019-04-18 10:15:21\",\"DLA-Columbus\",\"DLA-Columbus User\",\"2019-05-08 12:00:18\"]
}"
echo
echo

echo "POST invoke updateStatusToReceived chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToReceived\",
        \"transient_data\":"[]",
        \"args\":[\"18554\",\"Received\",\"2019-04-18 10:15:21\",\"PROP-19-000878\",\"SOS Team\",\"SOS User\"]
}"
echo
echo

echo "POST invoke updateStatusToPartVerification on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToPartVerification\",
        \"transient_data\":"[]",
        \"args\":[\"18554\",\"Part Verification\",\"2019-04-25 00:00:00\",\"Engineering\",\"Engineering User\"]
}"
echo
echo

echo "POST invoke updateStatusToAcceptedOrRejected on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToAcceptedOrRejected\",
        \"transient_data\":"[]",
        \"args\":[\"18554\",\"Rejected\",\"2019-04-27 00:00:00\",\"Engineering\",\"Engineering\",\"Insufficient Information\"]
}"
echo
echo

echo "POST invoke createRFxAsset chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"createRFxAsset\",
        \"transient_data\":"[]",
  	    \"args\":[\"19871\",\"Released\",\"DLA-COLUMBUS\",\"C-17\",\"19871\",\"2019-06-09 10:15:21\",\"DLA-Columbus\",\"DLA-Columbus User\",\"2019-09-06 2:00:18\"]
}"
echo
echo

echo "POST invoke updateStatusToReceived chaincode on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToReceived\",
        \"transient_data\":"[]",
        \"args\":[\"19871\",\"Received\",\"2019-06-09 10:32:21\",\"PROP-19-000878\",\"SOS Team\",\"SOS User\"]
}"
echo
echo

echo "POST invoke updateStatusToPartVerification on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToPartVerification\",
        \"transient_data\":"[]",
        \"args\":[\"19871\",\"Part Verification\",\"2019-06-26 11:12:21\",\"Engineering\",\"Engineering User\"]
}"
echo
echo

<<COMMENT
echo "POST updateStatusToSubmitted on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToSubmitted\",
        \"transient_data\":"[]",
        \"args\":[\"14869\",\"Submitted\",\"2018-11-04\",\"Contracts\",\"34260.52\"]
}"
echo
echo
COMMENT

echo "GET query to get all RFx Assets  display chaincode on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getAllRFxAsset&args=%5B%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo
