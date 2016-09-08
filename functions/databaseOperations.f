#! /bin/bash


source $STACI_HOME/functions/tools.f
node_prefix=$(getProperty "clusterNodePrefix")
cluster=$(getProperty "createCluster")
provider_type=$(getProperty "provider_type")

function exec_mysql_sql(){
   local sqlcmd=$1
   local appdb=$2
   mysql_pwd=$(getProperty "mysql_root_pass")

   # Point to cluster, if used
   if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-mysql")
   elif [ ! "$provider_type" == "none" ]; then
      eval $(docker-machine env "$node_prefix-Atlassian")
   fi

   local sql='mysql --user=root --password='"$mysql_pwd"' --database '"$appdb"' -e "'"$sqlcmd"'"'

   docker exec atlassiandb /bin/bash -c "$sql" & >> $STACI_HOME/logs/mysql.log
}
