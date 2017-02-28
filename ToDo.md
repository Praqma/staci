Actually these should be issues in the repo. But anyway.
* docker-compose file should get the persistent storage directory location from the setup.conf file.
* DOMAIN_NAME should be dynamic and should be picked from setup.conf
* May be we can get rid of FQDN container names and just have simple container names in docker-compose.
* It is a good idea to give each container a short hostname (without DOMAIN_NAME). Helps later in GUI configuration.
