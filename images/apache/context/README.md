Add :
		ServerName home.softica.dk:443
to /etc/apache2/sites-available/default-ssl.conf right below ServerAdmin email

Add :
                # JIRA Proxy Configuration:
		<Proxy *>
			Require all granted
		</Proxy>
                ProxyRequests           Off
                ProxyPreserveHost       On
                ProxyPass               /jira       http://home.softica.dk:8080/jira
                ProxyPassReverse        /jira       http://home.softica.dk:8080/jira

                SSLCertificateFile    /etc/ssl/certs/jira.crt
                SSLCertificateKeyFile /etc/ssl/private/jira.key

to /etc/apache2/sites-available/default-ssl.conf 

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/jira.key -out /etc/ssl/certs/jira.crt

docker restart staci/apache2:0.1
