#!/bin/bash
#
# Copyright Boeing. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

config_file="project-config.json"
NETWORK="$( jq -r '.FAB_NET_NM' "$config_file" )"

ORG1_NAME="$( jq -r '.ORG1_NAME' "$config_file" )"
ORG1_NAME_S="${ORG1_NAME,,}"
CHANNEL="$( jq -r '.CHANNEL' "$config_file" )"

function dkcl(){
	CONTAINER_IDS=$(docker ps -aq)
	echo
	if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
		echo "========== No containers available for deletion =========="
	else
		docker rm -f $CONTAINER_IDS
	fi
	echo
}

function dkrm(){
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
	echo
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
	echo
}

function createNetworkFiles(){
	./applyConfig.sh
}

function removeNetworkFiles(){

	echo
	rm -rf ${NETWORK}

	echo "========== Deleted network files ==========="
	echo
}

function stopNetwork() {
	
	echo
    #teardown the network and clean the containers and intermediate images
	if [ -f $NETWORK/docker-compose.yaml ]; then
	    docker-compose -f $NETWORK/docker-compose.yaml down
	fi
	
	dkcl
	dkrm
	#removeNetworkFiles
}

<<COMMMENT
function verifyResult () {
	if [ $1 -ne 0 ] ; then
		echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========== ERROR !!! FAILED to execute End-2-End Scenario ==========="
		echo
   		exit 1
	fi
}

function createChannel() {
	docker exec cli peer channel create -o orderer.boeing.com:7050 -c ${CHANNEL} -f ${NETWORK}/channel/${CHANNEL}.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
	res=$?

	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "========== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}
COMMMENT

function restartNetwork() {

  	#teardown the network and clean the containers and intermediate images
	stopNetwork

	#Start the network
	#createNetworkFiles
	docker-compose -f ./$NETWORK/docker-compose.yaml up -d
	echo
}

function installNodeModules() {
	echo
	if [ -d node_modules ]; then
		echo "============== node modules installed already ============="
	else
		echo "============== Installing node modules ============="
		npm install
	fi
	echo
}

restartNetwork

installNodeModules

PORT=4000 node app
