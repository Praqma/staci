#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
version=$(getProperty "imageVersion")

# Here we will find all containers
images=$(cd $STACI_HOME/images/;echo */)

# Lets build all the found images
for image in $images; do
  echo " - Building : $image -- please wait..."
  docker build -t staci/$image:$version $STACI_HOME/images/$image/context/ > $STACI_HOME/logs/"$image".log 2>&1 &
done
wait
