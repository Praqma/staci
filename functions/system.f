function checkStaciPropertyFile(){
  if [ ! -f $STACI_HOME/conf/staci.properties ]; then
    echo "Error : You need to create conf/staci.properties from conf/staci.properties.template"
    exit 0
  fi
}

check_docker_dependencies() {
  local check_result=0
  local supported_docker_version="1.11.1"
  local supported_docker_compose_version="1.6.0"
  local supported_docker_machine_version="0.6.0"

  # Check that docker is installed, and has the right version
  #
  echo " - Running dependency checks, please wait..."
  if command_exists "docker";  then
     local docker_version=$(docker version --format '{{.Client.Version}}')
     echo -ne "  - Docker version\t\t: $docker_version"
     if $(do_version_check $docker_version $supported_docker_version);then
       echo -e " - OK"
     else
       echo -e " - Error, please upgrade to $supported_docker_version"
       return 1
     fi
  else
     echo "  - Docker not installed, please install at lest version $supported_docker_version"
     return 1
  fi

  # Check that docker-compose is installed, and has the right version
  #
  if command_exists docker-compose; then
     local docker_compose_version=$(docker-compose version --short)
     echo -ne "  - Docker-compose version\t: $docker_compose_version"
     if $(do_version_check $docker_compose_version $supported_docker_compose_version); then
       echo -e "\t - OK"
     else
       echo -e "\t - Error, please upgrade to $supported_docker_compose_version"
       return 1
     fi
  else
     echo "  - Docker-compose not installed, please install at lest version $supported_docker_compose_version"
     return 1
  fi

  # Check that docker-machine is installed, and has the right version
  #
  if command_exists docker-machine; then
     local docker_machine_version=$(docker-machine version | cut -d"," -f1|cut -d" " -f3)
     echo -ne "  - Docker-machine version\t: $docker_machine_version"
     if $(do_version_check $docker_machine_version $supported_docker_machine_version); then
       echo -e "\t - OK"
     else
       echo -e "\t - Error, please upgrade to $supported_docker_machine_version"
       return 1
     fi
  else
     echo "  - Docker-machine not installed, please install at lest version $supported_docker_machine_version"
     return 1
  fi
  return 0
}
