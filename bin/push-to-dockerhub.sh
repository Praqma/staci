#! /bin/bash
source $STACI_HOME/functions/tools.f

# Set version of images
version=$(getProperty "imageVersion")

##
# This script pushes our locally build images
# to the docker hub.
##
echo "Pushing version $version of images to the Docker hub"
# Here we will push to the Docker hub
