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

echo "GET query chaincode on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getRFxAssetByIMIM&args=%5B%22IMIM_0000%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query to get all RFx Assets  display chaincode on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getAllRFxAsset&args=%5B%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query to print all RFx assets with Status Accepted on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getRFxAssetByStatus&args=%5B%22Accepted%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query chaincode on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getRFxHistory&args=%5B%22IMIM_0000%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
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
  	    \"args\":[\"RFP_9999\",\"Received\",\"Defense\",\"new\",\"152635\",\"2019-05-21\",\"SOS\",\"SOSUser\",\"2019-05-29\",\"jlasfasfjwelefknewfjewkfjwekfmwlkgneklrjgkrwgwregwrmegerkgrergreg\"]
}"
echo
echo

<<COMMENT
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
        \"args\":[\"IMIM_0000\",\"Received\",\"2019-05-22\",\"SOS\",\"SOSUser\"]
}"
echo
echo


echo "POST invoke updateStatusToVerificationPending on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToVerificationPending\",
        \"transient_data\":"[]",
        \"args\":[\"IMIM_0000\",\"VerificationPending\",\"2019-05-23\",\"Engineering\",\"EngineeringUser\"]
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
        \"args\":[\"IMIM_0000\",\"Accepted\",\"2019-05-24\",\"Estimators\",\"Estimators\"]
}"
echo
echo

echo "POST invoke updateStatusToEstimation on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToEstimation\",
        \"transient_data\":"[]",
        \"args\":[\"IMIM_0000\",\"Estimation\",\"2019-05-28\",\"2019-05-24\",\"2019-05-25\",\"2019-05-26\",\"SupplierManagement\",\"SupplierUser\"]
}"
echo
echo

echo "POST invoke updateStatusToSupplierEstimation on peers of ${ORG1_NAME} "
echo
curl -s -X POST \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d "{
        \"peers\": [\"${PEER0_ORG1}\"],
        \"fcn\":\"updateStatusToSupplierEstimation\",
        \"transient_data\":"[]",
        \"args\":[\"IMIM_0000\",\"SupplierEstimation\",\"2019-05-27\",\"2019-05-27\",\"Estimators\",\"Estimators\"]
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
        \"args\":[\"IMIM_0000\",\"EstimationComplete\",\"2019-05-28\",\"Contracts\",\"ContractsUser\"]
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
        \"args\":[\"IMIM_0000\",\"PricingComplete\",\"2019-05-29\",\"Contracts\",\"ContractsUser\"]
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
        \"args\":[\"IMIM_0000\",\"Submitted\",\"2019-05-30\",\"ContractUser\",\"3426.52\"]
}"
echo
echo

echo "GET query chaincode on peer0 of ${ORG1_NAME}"
echo
curl -s -X GET \
  "http://localhost:4000/channels/${CHANNEL}/chaincodes/${CHAINCODE}?peer=${PEER0_ORG1}&fcn=getRFxHistory&args=%5B%22IMIM_0000%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo
COMMENT