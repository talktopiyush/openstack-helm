#!/usr/bin/env bash

. /container.init/common.sh

echo "Waiting for keystone application.."

URL_BASE={{.Values.global.keystone_api_endpoint_protocol_internal}}://{{include "keystone_api_endpoint_host_internal" .}}:{{.Values.global.keystone_api_port_internal}}

n=1
m=12
until [ $n -ge $m ]
do
    curl ${URL_BASE} > /dev/null 2>&1  && break
    echo "Attempt $n of $m waiting 10 seconds to retry"
    n=$[$n+1]
    sleep 10
done

if [ $n -eq $m ]
then
    echo "Keystone not available within 120 seconds"
    exit 1
fi

export OS_AUTH_URL=${URL_BASE}/v3
export OS_AUTH_PLUGIN=v3password
export OS_USERNAME={{.Values.bootstrap_user}}
export OS_PASSWORD={{.Values.bootstrap_password}}
export OS_USER_DOMAIN_ID=default
#export OS_PROJECT_NAME=admin
#export OS_PROJECT_DOMAIN_ID=default
export OS_DOMAIN_ID=default
export OS_REGION={{.Values.global.region}}

export http_proxy=
export all_proxy=

# seed the keystone configmap with the keystone-config tool
echo "Loading keystone database content.."
keystone_config_seeder --input /keystone-config/keystone-seed.yaml --interface internal --watch
