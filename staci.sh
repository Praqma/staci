#!/bin/bash
# ------------------------------------------------------------------
# [Henrik Hoegh] staci.sh                                 10/11/2015
#
#          Here we control what to do, and how. There is no
#          functionality here, as it calls out to functions
#          placed in the $STACI_HOME/functions folder.
#
# ------------------------------------------------------------------

VERSION=0.1.0

usage(){
	echo -e "Usage: \nstaci.sh [OPTIONS] COMMAND [property-file]

	Options:
	\t -i \t\tInteractive mode, used with install
	\t -v \t\tPrint version
	\t -h \t\tPrint usage

	Commands:
	\t install \tInstall STACI
	\t wwig    \tWhat Will I Get - outcome of property file
	\t stop    \tStop all running containers
	\t start   \tStart all configured containers
	\t delete  \tDelete created containers

"
}
# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    usage
    exit 1;
fi

interactive=0

while getopts "::hiv" optname
  do
    case "$optname" in
			"h")
        usage
        exit 0;
        ;;
			"i")
        interactive=1
        ;;
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit 0;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit 0;
        ;;
      *)
        echo "Unknown error while processing options"
        exit 0;
        ;;
    esac
  done

shift $(($OPTIND - 1))

param1=$1
param2=$2

# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE

# Sourcing env setup
export STACI_HOME=$(pwd)
source $STACI_HOME/functions/tools.f
source $STACI_HOME/functions/build.f
source $STACI_HOME/functions/staciOperations.f

if [ $param1 == "install" ];then
	if [ $interactive -eq 1 ]; then
		echo "Interactive install"
		installStaciInteractive
	else
    echo "Installing, please wait...."
    create_cluster=$(getProperty "createCluster")
    installStaci $create_cluster
	fi
  exit 0;
fi

if [ $param1 == "wwig" ];then
  echo "Analyzing configuration, please wait...."
  if [ ! -z "$param2" ];then
    echo " - Analyzing file $param2"
  else
    echo " - Analyzing file $STACI_HOME/conf/staci.properties"
  fi
  exit 0;
fi

if [ $param1 == "delete" ];then
  echo "Deleting containers, please wait...."
  deleteStaci
  exit 0;
fi

if [ $param1 == "start" ];then
  echo "Starting containers, please wait...."
  startStaci
  exit 0;
fi

if [ $param1 == "stop" ];then
  echo "Stopping containers, please wait...."
  stopStaci
  exit 0;
fi

usage
# -----------------------------------------------------------------
