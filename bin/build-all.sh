#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
version=$(getProperty "imageVersion")

# Here we will find all containers
images=$(ls $STACI_HOME/images)

# Lets build all the found images
for image in $images; do
  echo "-- Building : $image --"
  docker build -t staci/$image:$version $STACI_HOME/images/$image/context/ &
  echo "
"
done

wait

