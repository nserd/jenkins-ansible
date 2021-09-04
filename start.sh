#!/bin/bash

function usage {
    echo
    echo "Usage: start.sh <domain> <ip>"
    echo "       start.sh <--help>"
    echo
}

function arg-handler {
    [ -z "$1" ] && echo "No agruments found. Use --help" && exit 1
    [ "$1" == "--help" ] && usage && exit 0
    [ -z "$2" ] && echo "No IP found. Use --help" && exit 1

    domain="$1"
    ip="$2"

    [ `echo $domain | grep -c "\."` -eq 0 ] && echo "Invalid domain format. Exit." && exit 1
    [ `echo $ip | egrep '^(((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])\.){3})(25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])$' -c` -eq 0 ] && echo "Invalid IP format. Exit." && exit 1
}

function check-domain {
   [ `dig a $domain +short | grep -c $ip` -eq 0 ] && echo "Domain $domain is not directed to the server. Exit." && exit 2
   [ `dig a www.$domain +short | grep -c $ip` -eq 0 ] && echo "Domain www.$domain is not directed to the server. Exit." && exit 2
}

function create-inventory-file {
    if ! [ -f $scriptDir/inventory_file ]
    then
        sed "s#__IP__#$ip#g" $scriptDir/inventory_file.tpl | \
        sed "s#__DOMAIN__#$domain#g" > inventory_file
    fi
}

scriptDir=`dirname $0`

arg-handler "$@"
check-domain
create-inventory-file

if which ansible-playbook > /dev/null
then
    sh -c "cd $scriptDir && ansible-playbook -i inventory_file jenkins.yml -u root"
else
    echo "Ansible not found. To install, use:"
    echo 
    echo "  apt install ansible"
    echo
fi
