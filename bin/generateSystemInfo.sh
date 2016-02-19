#!/bin/bash
source $STACI_HOME/functions/tools.f
docker_host_ip=$(echo $DOCKER_HOST | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')

# Set version of images
version=$(getProperty "imageVersion")

# Find out what to start
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")
start_crowd=$(getProperty "start_crowd")
start_bitbucket=$(getProperty "start_bitbucket")
start_crucible=$(getProperty "start_crucible")

cluster=$(getProperty "createCluster")

   if [ "$cluster" == "1" ]; then
      node_prefix=$(getProperty "clusterNodePrefix")
      atlassiandb_ip=$(docker-machine ip "$node_prefix-mysql")
   else
      atlassiandb_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' atlassiandb)
   fi

cat << EOF
<html>
<style>
.settingsdiv{
    display        : none;
    border-top-left-radius     : 20px;
    border-bottom-right-radius : 20px;
    border         : 2px solid #FF6600;
    background     : #FFFFFF;
    padding        : 15px;
    width          : 766px;
}

.headline{
    text-align     : right;
    text-decoration: none;
    width          : 800px;
}

</style>
<script>
function showElement(elem) {
   // First hide all
EOF
if [ "$start_jira" == "1" ]; then
cat << EOF
    document.getElementById('jira').style.display = 'none';
EOF
fi
if [ "$start_confluence" == "1" ]; then
cat << EOF
    document.getElementById('confluence').style.display = 'none';
EOF
fi
if [ "$start_bitbucket" == "1" ]; then
cat << EOF
    document.getElementById('bitbucket').style.display = 'none';
EOF
fi
if [ "$start_bamboo" == "1" ]; then
cat << EOF
    document.getElementById('bamboo').style.display = 'none';
EOF
fi
if [ "$start_crowd" == "1" ]; then
cat << EOF
    document.getElementById('crowd').style.display = 'none';
EOF
fi
if [ "$start_mysql" == "1" ]; then
cat << EOF
    document.getElementById('atlassiandb').style.display = 'none';
EOF
fi
if [ "$start_crucible" == "1" ]; then
cat << EOF
    document.getElementById('crucible').style.display = 'none';
EOF
fi
cat << EOF

    document.getElementById('info').style.display = 'none';

   // Then show the one asked for
    document.getElementById(elem).style.display = 'block';
}
</script>
<body onLoad="document.getElementById('info').style.display = 'block';">

<div class="headline">-
  <a href="#" onClick="showElement('info');">Info</a> |
EOF

if [ "$start_jira" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('jira');">Jira</a> |
EOF
fi

if [ "$start_crucible" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('crucible');">Crucible</a> |
EOF
fi

if [ "$start_confluence" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('confluence');">Confluence</a> | 
EOF
fi

if [ "$start_bitbucket" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('bitbucket');">Bitbucket</a> | 
EOF
fi

if [ "$start_bamboo" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('bamboo');">Bamboo</a> |
EOF
fi

if [ "$start_crowd" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('crowd');">Crowd</a> |
EOF
fi

if [ "$start_mysql" == "1" ]; then
cat << EOF
  <a href="#" onClick="showElement('atlassiandb');">Database</a> -
EOF
fi

cat << EOF
</div>

<div id="info" class="settingsdiv">
  <b>Welcome to your Atlassian tools stack.</b><br><br>Here you will find all the information you need, to set up your software.<br>
</div>
EOF
if [ "$start_jira" == "1" ]; then
   jira_username=$(getProperty "jira_username")
   jira_password=$(getProperty "jira_password")
   jira_database=$(getProperty "jira_database_name")
   jira_contextpath=$(getProperty "jira_contextpath")

   if [ "$cluster" == "1" ]; then
      jiraip=$(docker-machine ip "$node_prefix-jira")
   else
      jiraip=$docker_host_ip
   fi

cat << EOF
<div id="jira" class="settingsdiv">
  <b>Use the following to setup Jira db connection</b>
  <a href="http://$jiraip:8080$jira_contextpath" target="_blank">Jira link</a>
  <ul>
    <li>Database Type : MySQL</li>
    <li>Hostname : $atlassiandb_ip</li>
    <li>Port : 3306</li>
    <li>Database : $jira_database</li>
    <li>Username : $jira_username</li>
    <li>Password : $jira_password</li>
  </ul>
</div>
EOF
fi

if [ "$start_crucible" == "1" ]; then
  crucibleContextPath=$(getProperty "crusible_contextpath")

   if [ "$cluster" == "1" ]; then
      crucibleip=$(docker-machine ip "$node_prefix-crucible")
   else
      crucibleip=$docker_host_ip
   fi

cat << EOF
<div id="crucible" class="settingsdiv">
  <b>Use the following to setup Crucible db connection</b>
  <a href="http://$docker_host_ip:8060$crucibleContextPath" target="_blank">Crucible link</a>

  <ul>
    <li>Crucible link : http://$docker_host_ip:8060$crucibleContextPath</li>
EOF
  if [ "$start_jira" == "1" ]; then
     echo "<li>Link to Jira : http://$docker_host_ip:8080$jira_contextpath</li>"
  fi
cat << EOF
  </ul>
</div>
EOF
fi

if [ "$start_confluence" == "1" ]; then
   confluence_username=$(getProperty "confluence_username")
   confluence_password=$(getProperty "confluence_password")
   confluence_database=$(getProperty "confluence_database_name")
   confluence_contextpath=$(getProperty "confluence_contextpath")

   if [ "$cluster" == "1" ]; then
      confluenceip=$(docker-machine ip "$node_prefix-confluence")
   else
      confluenceip=$docker_host_ip
   fi

cat << EOF
<div id="confluence" class="settingsdiv">
  <b>Use the following to setup Confluence db connection</b>
  <a href="http://$docker_host_ip:8090$confluence_contextpath" target="_blank">Confluence link</a>
  <ul>
    <li>Install type : Production install</li>
    <li>Database Type : MySQL</li>
    <li>Connection : Direct JDBC</li>
    <li>Driver Class Name : com.mysql.jdbc.Driver</li>
    <li>Database URL : jdbc:mysql://$atlassiandb_ip/$confluence_database?sessionVariables=storage_engine%3DInnoDB&useUnicode=true&characterEncoding=utf8</li>
    <li>User Name : $confluence_username</li>
    <li>Password : $confluence_password</li>
  </ul>
</div>
EOF
fi

if [ "$start_bamboo" == "1" ]; then
   bamboo_username=$(getProperty "bamboo_username")
   bamboo_password=$(getProperty "bamboo_password")
   bamboo_database=$(getProperty "bamboo_database_name")
   bamboo_contextpath=$(getProperty "bamboo_contextpath")

   if [ "$cluster" == "1" ]; then
      bambooip=$(docker-machine ip "$node_prefix-bamboo")
   else
      bambooip=$docker_host_ip
   fi

cat << EOF
<div id="bamboo" class="settingsdiv">
  <b>Use the following to setup Bamboo db connection</b>
  <a href="http://$docker_host_ip:8085$bamboo_contextpath" target="_blank">Bamboo link</a>
  <ul>
    <li>install type : Production install</li>
    <li>Select database : External MySQL</li>
    <li>Connection : Direct JDBC</li>
    <li>Database URL : jdbc:mysql://$atlassiandb_ip/$bamboo_database?autoReconnect=true</li>
    <li>User name : $bamboo_username</li>
    <li>Password : $bamboo_password</li>
    <li>Overwrite Existing data : Yes, if you want</li>
  </ul>
</div>
EOF
fi

if [ "$start_bitbucket" == "1" ]; then
   bitbucket_username=$(getProperty "bitbucket_username")
   bitbucket_password=$(getProperty "bitbucket_password")
   bitbucket_database=$(getProperty "bitbucket_database_name")
   bitbucket_contextpath=$(getProperty "bitbucket_contextpath")

   if [ "$cluster" == "1" ]; then
      bitbucketip=$(docker-machine ip "$node_prefix-bitbucket")
   else
      bitbucketip=$docker_host_ip
   fi

cat << EOF
<div id="bitbucket" class="settingsdiv">
  <b>Use the following to setup Bitbucket db connection</b>
  <a href="http://$docker_host_ip:7990$bitbucket_contextpath" target="_blank">Bitbucket link</a>
  <ul>
    <li>Database : External</li>
    <li>Database type : MySQL</li>
    <li>Hostname : $atlassiandb_ip</li>
    <li>Port : 3306</li>
    <li>Database name : $bitbucket_database</li>
    <li>Database username : $bitbucket_username</li>
    <li>Database password : $bitbucket_password</li>
  </ul>
</div>
EOF
fi

if [ "$start_crowd" == "1" ]; then
   crowd_username=$(getProperty "crowd_username")
   crowd_password=$(getProperty "crowd_password")
   crowd_database=$(getProperty "crowd_database_name")

   if [ "$cluster" == "1" ]; then
      crowdip=$(docker-machine ip "$node_prefix-crowd")
   else
      crowdip=$docker_host_ip
   fi

cat << EOF
<div id="crowd" class="settingsdiv">
  <b>Use the following to setup Crowd db connection</b>
  <a href="http://$docker_host_ip:8095/crowd" target="_blank">Crowd link</a>

  <ul>
    <li>Install type : New installation</li>
    <li>Database type : JDBC connection</li>
    <li>Database : MySQL</li>
    <li>Database URL : jdbc:mysql://$atlassiandb_ip/$crowd_database?autoReconnect=true&characterEncoding=utf8&useUnicode=true</li>
    <li>User name : $crowd_username</li>
    <li>Password : $crowd_password</li>
    <li>Overwrite Existing data : Yes, if you want</li>
  </ul>
</div>
EOF
fi

if [ "$start_mysql" == "1" ]; then
mysql_root_pass=$(getProperty "mysql_root_pass")

   if [ "$cluster" == "1" ]; then
      mysqlip=$(docker-machine ip "$node_prefix-mysql")
   else
      mysqlip=$docker_host_ip
   fi

cat << EOF
<div id="atlassiandb" class="settingsdiv">
  <b>Information about the database</b>
  <ul>
    <li>Hostname : $atlassiandb_ip</li>
    <li>User name : root</li>
    <li>Password : $mysql_root_pass</li>
  </ul>
</div>
EOF
fi

cat << EOF
</body>
</html>
EOF

