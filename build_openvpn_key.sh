#!/bin/bash

if [[ $(whoami) != "root" ]];then
    echo "Permission denied please change to user of root"
    exit 1
fi
Git_Dir=$(pwd)
KEY=/home/opnfv/openvpnkeys
if [[ ! -d "$KEY" ]]; then 
    mkdir -p "$KEY" 
fi 
usage="Script to build the the openVPN certificate automatically.

usage:
    bash $(basename "$0") [-h|--help] -n <name> -p <purpose>

where:
    -h|--help         show this help text
    -n|--name         name of the user of openVPN
        <name>
    -p|--purpose      the purpose of usr this openVPN 
        <purpose>
     "

if [[ $# < 1 ]];then
    echo "need more parament you can use commend bash $(basename "$0") -h"
    exit 1
fi
while [[ $# > 0 ]]
    do
    key="$1"
    case $key in
        -h|--help)
            echo "$usage"
            exit 0
            shift
        ;;
        -n|--name)
            name=$2
            echo $name
            if [[ $# < 4 ]];then
                echo "need more parament you can use commendi bash $(basename "$0") -h"
                exit 1
            fi
            shift
        ;;
        -p|--purpose)
            purpose="$2"
            echo $purpose
            shift
        ;;
        *)
            echo "unknown option $1 $2"
            exit 1
        ;;
    esac
    shift # past argument or value
done
WORK_DIR=/etc/openvpn/easy-rsa
WORK_KEYS=$WORK_DIR/keys
cd $WORK_DIR

source vars

# Make a certificate/private key pair using a locally generated
# root certificate.
#if [  -z $2 ]; then  
#  echo "please enter the purpose at the second parament"
#  exit 1  
#fi 
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool"  $name

echo name: $name >>/home/openvpn.info
echo purpose: $purpose >>/home/openvpn.info
echo time: $(date)>>/home/openvpn.info
echo "">>//home/openvpn.info

cd $WORK_KEYS

cp $Git_Dir/template.ovpn $name.ovpn
cp ca.crt ca_$name.crt
#sed -i "s/test_key/$1/g" $name.ovpn
echo  ca ca_$name.crt>>$name.ovpn
echo  cert $name.crt>>$name.ovpn
echo  key $name.key>>$name.ovpn


tar -czvf $name.tar $name.crt $name.key $name.ovpn ca_$name.crt
cp $name.tar $KEY

