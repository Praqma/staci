openssl req -new -newkey rsa:2048 -nodes -x509 \
    -subj "/C=DK/ST=Aarhus/L=Aarhus/OU=Praqma/O=Praqma/CN=jira.praqma.net" \
    -keyout /etc/ssl/private/jira.key  -out /etc/ssl/certs/jira.crt


echo '<IfModule mod_ssl.c>
	<VirtualHost _default_:443>
		ServerAdmin webmaster@localhost
		ServerName praqma-100.intern.it-huset.dk:443

		DocumentRoot /var/www/html
		ErrorLog ${APACHE_LOG_DIR}/error.log
		CustomLog ${APACHE_LOG_DIR}/access.log combined
		LogLevel warn

		SSLEngine on

		<FilesMatch "\.(cgi|shtml|phtml|php)$">
				SSLOptions +StdEnvVars
		</FilesMatch>
		<Directory /usr/lib/cgi-bin>
				SSLOptions +StdEnvVars
		</Directory>

		BrowserMatch "MSIE [2-6]" \
				nokeepalive ssl-unclean-shutdown \
				downgrade-1.0 force-response-1.0
		# MSIE 7 and newer should be able to use keepalive
		BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown

                # JIRA Proxy Configuration:
		<Proxy *>
			Require all granted
		</Proxy>
                ProxyRequests           Off
                ProxyPreserveHost       On
                ProxyPass               /jira       http://praqma-100.intern.it-huset.dk:8080/jira
                ProxyPassReverse        /jira       http://praqma-100.intern.it-huset.dk:8080/jira

                SSLCertificateFile    /etc/ssl/certs/jira.crt
                SSLCertificateKeyFile /etc/ssl/private/jira.key
	</VirtualHost>
</IfModule>' > /etc/apache2/sites-available/default-ssl.conf

