# build
build the openVPN certificate

copy the file template.ovpn to the directory /etc/openvpn/easy-rsa/keys.you need to add ip and port after  remote in line 42
you can run the script by command "bash run_build_key -h" to see the help.
otherwise you can run script like this "bash run_build_key -n <name> -p <purpose>"
