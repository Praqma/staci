

# Sourcing env setup
source setEnv.sh
source $STACI_HOME/functions/tools.f

# Get info on what is running
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")

# Get data directory
volume_dir=$(getProperty "volume_dir")

# Get backup folder
backup_folder=$(getProperty "backup_folder")

# Create folders for persistant container data, if not existing
if [ ! -d "$backup_folder" ]; then
  mkdir $backup_folder
fi

# Create new backupfolder, with date
backup_dir=$backup_folder/$(date +"%m_%d_%Y")
mkdir $backup_dir

echo " - Taking backup of staci.properties"
cp $STACI_HOME/bin/staci.properties $backup_dir/staci.properties

# Do backup
echo " - Taking backup of $volume_dir to $backup_dir."
cd $volume_dir

if [ "$start_jira" == "1" ]; then
  mkdir $backup_dir/jira
  tar czf $backup_dir/jira/jira.tgz jira &
fi

if [ "$start_confluence" == "1" ]; then
  mkdir $backup_dir/confluence
  tar czf $backup_dir/confluence/confluence.tgz confluence &
fi

if [ "$start_bamboo" == "1" ]; then
  mkdir $backup_dir/bamboo
  tar czf $backup_dir/bamboo/bamboo.tgz bamboo &
fi

if [ "$start_mysql" == "1" ]; then
  mkdir $backup_dir/mysql
  tar czf $backup_dir/mysql/mysql.tgz atlassiandb &
fi

wait

echo "
 - Backup is done... Have a good night sleep.

"

