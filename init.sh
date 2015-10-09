#!/bin/bash

# create directory for project and own it
sudo mkdir /var/www
sudo mkdir /var/www/$BITBUCKET_PROJECT
sudo chown worker:worker -R /var/www/
sudo chown worker:worker -R /var/www/$BITBUCKET_PROJECT

# add ssh key to bitbucket project
mkdir /home/worker/.ssh
cd /home/worker/.ssh
ssh-keygen -t rsa -f worker_rsa -N '' && cat ./worker_rsa.pub | while read key; do curl --user "$BITBUCKET_USER:$BITBUCKET_PASS" --data-urlencode "key=$key" -X POST https://bitbucket.org/api/1.0/users/$BITBUCKET_USER/ssh-keys ; done
touch known_hosts
ssh-keyscan bitbucket.org >> known_hosts

# clone our eve project
cd /var/www
git clone https://$BITBUCKET_USER:$BITBUCKET_PASS@bitbucket.org/$BITBUCKET_USER/$BITBUCKET_PROJECT.git
cd /var/www/$BITBUCKET_PROJECT

echo "MONGO_HOST = os.environ.get('MONGO_HOST', 'localhost')" | cat - /var/www/$BITBUCKET_PROJECT/settings.py > /home/worker/settings.py.tmp && sudo mv /home/worker/settings.py.tmp /var/www/$BITBUCKET_PROJECT/settings.py
echo "MONGO_PORT = os.environ.get('MONGO_PORT', 27107)" | cat - /var/www/$BITBUCKET_PROJECT/settings.py > /home/worker/settings.py.tmp && sudo mv /home/worker/settings.py.tmp /var/www/$BITBUCKET_PROJECT/settings.py
echo "MONGO_USERNAME = os.environ.get('MONGO_USERNAME', 'user')" | cat - /var/www/$BITBUCKET_PROJECT/settings.py > /home/worker/settings.py.tmp && sudo mv /home/worker/settings.py.tmp /var/www/$BITBUCKET_PROJECT/settings.py
echo "MONGO_PASSWORD = os.environ.get('MONGO_PASSWORD', 'user')" | cat - /var/www/$BITBUCKET_PROJECT/settings.py > /home/worker/settings.py.tmp && sudo mv /home/worker/settings.py.tmp /var/www/$BITBUCKET_PROJECT/settings.py
echo "MONGO_DBNAME = os.environ.get('MONGO_DBNAME', 'evedemo')" | cat - /var/www/$BITBUCKET_PROJECT/settings.py > /home/worker/settings.py.tmp && sudo mv /home/worker/settings.py.tmp /var/www/$BITBUCKET_PROJECT/settings.py

python run.py
