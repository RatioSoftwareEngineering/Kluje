#!/bin/bash

cookbook=kluje

security_group=sg-6917ce0c
subnet=subnet-479b4622
image=ami-ca381398

node_name=$cookbook-staging-web1

key_name=$cookbook-staging
key_path=~/.ssh/$cookbook/aws/$key_name.pem
iam_role=$cookbook-staging

if [ ! -f $key_path ]; then
    echo "$key does not exist!"
    exit 1
fi

knife ec2 server create \
    --flavor t2.small \
    --security-group-ids $security_group \
    --ssh-user ubuntu \
    --ssh-key $key_name \
    --identity-file $key_path \
    --node-name $node_name \
    --environment staging \
    --run-list "recipe[$cookbook],recipe[$cookbook::rails_server],recipe[$cookbook::deploy]" \
    --iam-profile $iam_role \
    --associate-public-ip \
    --subnet $subnet \
    --image $image
