#!/bin/bash

cookbook=kluje

security_group=sg-6b17ce0e
subnet=subnet-3627d641
image=ami-96f1c1c4

node_name=$cookbook-web3

key_name=$cookbook-production
key_path=~/.ssh/$cookbook/aws/$key_name.pem
iam_role=$cookbook-production

if [ ! -f $key_path ]; then
    echo "$key does not exist!"
    exit 1
fi

knife ec2 server create \
    --flavor m3.large \
    --security-group-ids $security_group \
    --ssh-user ubuntu \
    --ssh-key $key_name \
    --identity-file $key_path \
    --node-name $node_name \
    --environment production \
    --run-list "recipe[$cookbook],recipe[$cookbook::newrelic],recipe[$cookbook::rails_server],recipe[$cookbook::deploy]" \
    --iam-profile $iam_role \
    --associate-public-ip \
    --subnet $subnet \
    --image $image
