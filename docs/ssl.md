## Install Certbot
```
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx 
```

## Generate certs

*Email:* ssl@sugarventures.co

#### For staging
```
sudo certbot certonly --webroot -w /var/proj/kluje-staging/current/public/ -d staging.kluje.com -d www.staging.kluje.com
```

#### For production
```
sudo certbot certonly --webroot -w /var/proj/kluje-production/current/public/ -d kluje.com -d www.kluje.com
```

## Auto renew
Create bash script file
```
sudo vi /var/proj/letsencrypt.sh
```
Paste content
```
#!/bin/sh

# Automating renewal Let's Encrypt certificates
certbot renew

rm -rf /var/proj/kluje-staging/current/public/.well-known
```
Add execute
```
sudo chmod +x /var/proj/letsencrypt.sh
```
Add cron job run every day
```
sudo crontab -e
```
Paste content
```
# Auto renew
30 9 * * * /var/proj/letsencrypt.sh
# @reboot /var/proj/letsencrypt.sh
# End Auto renew
```