#!/bin/bash
docker stop staci-cd
docker rm staci-cd
docker run -d -p 8080:8080 -p 50000:50000 \
              --name staci-cd praqma/staci-cd
echo ==================================
echo Following the logs, press Ctrl+C to quit
echo ==================================
docker logs -f staci-cd
