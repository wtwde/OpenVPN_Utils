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



echo Generate user guide:
USER_GUIDE="OpenVPN_USER_GUIDE"
USER_GUIDE_TMPL="$USER_GUIDE.tmpl"
OVPN_FILE="$name.ovpn"
CONF_FILES="ca_$name.crt/$name.crt/$name.key/$OVPN_FILE"

apt-get install -y rst2pdf

sed -e "s#CONF_FILES#${CONF_FILES}#g" \
    -e "s#OVPN_FILE#${OVPN_FILE}#g" \
    -e "s#USER_NAME#${name}#g" \
    ${USER_GUIDE_TMPL} > ${USER_GUIDE}

rst2pdf ${USER_GUIDE}
cp ${USER_GUIDE}.pdf $WORK_KEYS

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
echo -e ca ca_$name.crt'\n\r'>>$name.ovpn
echo -e cert $name.crt'\n\r'>>$name.ovpn
echo -e  key $name.key'\n\r'>>$name.ovpn



tar -cvf $name.tar $name.crt $name.key $name.ovpn ca_$name.crt ${USER_GUIDE}.pdf
cp $name.tar $KEY

echo your key have been stored in this folder :$KEY
