#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
version=$(getProperty "imageVersion")

# Here we will find all containers
images=$(ls $STACI_HOME/images/)

# Get context path for each application
jiraContextPath=$(getProperty "jira_contextpath")
confluenceContextPath=$(getProperty "confluence_contextpath")
bambooContextPath=$(getProperty "bamboo_contextpath")

# Set context path for Jira
if [ ! -z "$jiraContextPath" ]; then
  jiraContextPath='\'$jiraContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$jiraContextPath\"/g' /opt/atlassian/jira/conf/server.xml" > $STACI_HOME/images/jira/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/jira/context/setContextPath.sh
fi

# Set context path for Confluence
if [ ! -z "$confluenceContextPath" ]; then
  confluenceContextPath='\'$confluenceContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$confluenceContextPath\"/g' /opt/atlassian/confluence/conf/server.xml" > $STACI_HOME/images/confluence/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/confluence/context/setContextPath.sh
fi

# Set context path for Bamboo
if [ ! -z "$bambooContextPath" ]; then
  bambooContextPath='\'$bambooContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$bambooContextPath\"/g' /opt/atlassian/bamboo/conf/server.xml" > $STACI_HOME/images/bamboo/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bamboo/context/setContextPath.sh
fi

# Lets build all the found images
for image in $images; do
  echo " - Building : $image -- please wait..."
  docker build -t staci/$image:$version $STACI_HOME/images/$image/context/ > $STACI_HOME/logs/"$image".log 2>&1 &
done
wait

# Cleanup
rm $STACI_HOME/images/jira/context/setContextPath.sh
rm $STACI_HOME/images/confluence/context/setContextPath.sh
rm $STACI_HOME/images/bamboo/context/setContextPath.sh
