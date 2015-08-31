# Support Ticketing and Continous Integration

## Important information
Remember to turn off SE-LINUX and APPAMOR.
Application linking does now yet work. Confluence looses its users, when administrated from Jira.

## Preperation
- Create a folder structure in /data where a user with uid has full read-write access. 
- Create a jira, atlassiandb, confluence and bamboo folder inside this folder with same rights. 
- You can specify another folder in ./bin/staci.properties instead of /data (look for volume_dir=/data)

## Getting started
```
pull the repository (git clone https://github.com/Praqma/staci.git)
cd staci
export DOCKER_HOST=YOUR-IP:2375
./run.sh
```

If you want to change the behavour of STACI, edit the file ./bin/staci.properties

## Setting up MySQL for JIRA
run a mysql container to get a mysql-client
```
docker run -it --link compose_atlassiandb_1:mysql  mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p'
enter mysql root password "pass_word" (found in ./bin/generateCompose.sh if changed)

CREATE USER 'jiradbuser'@'%' IDENTIFIED BY 'jirapass';
CREATE DATABASE jiradb CHARACTER SET utf8 COLLATE utf8_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on jiradb.* TO 'jiradbuser'@'%';
FLUSH PRIVILEGES;
```

Use the folloing when setup Jira DB connection
- Database Type : MySQL
- Hostname : 192.168.0.175  (docker host ip)
- Port : 3306
- Database : jiradb
- Username : jiradbuser
- Password : jirapass

## Setting up MySQL for Confluence
run a mysql container to get a mysql-client
```
docker run -it --link compose_atlassiandb_1:mysql  mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p'
enter mysql root password "pass_word" (found in ./bin/generateCompose.sh if changed)

CREATE USER 'jiradbuser'@'%' IDENTIFIED BY 'jirapass';
CREATE DATABASE jiradb CHARACTER SET utf8 COLLATE utf8_bin;
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on jiradb.* TO 'jiradbuser'@'%';
FLUSH PRIVILEGES;
```

Use the folloing when setup Jira DB connection
- Database Type : MySQL
- choose Direct connect
- Driver Class Name : com.mysql.jdbc.Driver
- Database URL : jdbc:mysql://192.168.0.175/confluence?sessionVariables=storage_engine%3DInnoDB
- User Name : confluenceuser
- Password : confluencepass
