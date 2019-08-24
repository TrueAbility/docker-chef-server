#!/bin/sh


mkdir -p data 
docker run -d --rm \
    --name chef-server \
    -v ${PWD}/data:/var/opt \
    -p 0.0.0.0:580:80 \
    -p 0.0.0.0:5443:443 \
    --privileged \
    -e EXTERNAL_URL="https://chef-server.wongsrus.net.au" \
    harbor.wongsrus.net.au/swong/chef-server-manage

cat<<EOT:

	Run other chef server with commands
	docker exec -it harbor.wongsrus.net.au/swong/chef-server chef-server-ctl ..
  eg. 
      ef-server-ctl grant-server-admin-permissions swong
			chef-server-ctl user-create swong "steven" "wong" steven.wong@mastercard.com 'sw0ng@28' --filename admin.key
			chef-server-ctl org-create bizops 'Bizops MasterCard' --association_user swong --filename bizops-validator.pem

EOT:
