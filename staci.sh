#!/bin/bash
# ------------------------------------------------------------------
# [Henrik Hoegh] staci.sh                                 10/11/2015
#
#          This scipt is where the login in staci is placed.
#          Here we control what to do, and how. There is no
#          functionality here, as it calls out to functions
#          placed in the $STACI_HOME/functions folder.
#
# ------------------------------------------------------------------

VERSION=0.1.0

usage(){
	echo -e "Usage: \nstaci.sh [OPTIONS] COMMAND [property-file]
	
	Options:
	\t -v \t\tPrints version
	\t -h \t\tPrint usage
	
	Commands:
	\t install \tInstalls STACI
	\t wwig   \tWhat Will I Get - outcome of property file
	\t stop   \tStops all runing containers
	\t start  \tStarts all configured containers
	\t delete  \tDeletes created containers
	
"
}
# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    usage
    exit 1;
fi

while getopts "::vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "h")
        usage
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

# Find out, if we are using a cluster or not
cluster=$(getProperty "createCluster")

if [ $param1 == "install" ];then
  echo "Doing install, please wait...."
  exit 0;
fi

if [ $param1 == "wwig" ];then
  echo "Analyzing configuration, please wait...."
  if [ ! -z "$param2" ];then
    echo " - Analyzing file $param2"
  else
    echo " - Analyzing file ./bin/staci/properties"
  fi
  exit 0;
fi

if [ $param1 == "delete" ];then
  echo "Deleting containers, please wait...."
  exit 0;
fi

if [ $param1 == "start" ];then
  echo "Starting containers, please wait...."
  startContainers
  exit 0;
fi

if [ $param1 == "stop" ];then
  echo "Stopping containers, please wait...."
  stopContainers
  exit 0;
fi

usage
# -----------------------------------------------------------------
