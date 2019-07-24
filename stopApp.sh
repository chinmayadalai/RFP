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

function removeNetworkFiles(){

	echo
	#rm -rf ./${NETWORK}

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

	echo
}


stopNetwork
