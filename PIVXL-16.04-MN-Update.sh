#!/bin/bash

#stop_daemon function
function stop_daemon {
    if pgrep -x 'pivxld' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop pivxld${NC}"
        pivxl-cli stop
        sleep 30
        if pgrep -x 'pivxld' > /dev/null; then
            echo -e "${RED}pivxld daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            sudo pkill -9 pivxld
            sleep 30
            if pgrep -x 'pivxld' > /dev/null; then
                echo -e "${RED}Can't stop pivxld! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}


echo "Your PivxLite Masternode Will be Updated To The Latest Version v2.1.0 Now" 
sudo apt-get -y install unzip

#remove crontab entry to prevent daemon from starting
crontab -l | grep -v 'pivxlauto.sh' | crontab -

#Stop pivxld by calling the stop_daemon function
stop_daemon

rm -rf /usr/local/bin/pivxl*
mkdir PIVXL_2.1.0
cd PIVXL_2.1.0
wget https://github.com/PivxLiteDev/PivxLite/releases/download/v2.1.0/pivxl-2.1.0-ubuntu-16.04.tar.gz
tar -xzvf pivxl-2.1.0-ubuntu-16.04.tar.gz
mv pivxld /usr/local/bin/pivxld
mv pivxl-cli /usr/local/bin/pivxl-cli
chmod +x /usr/local/bin/pivxl*
rm -rf ~/.pivxl/blocks
rm -rf ~/.pivxl/chainstate
rm -rf ~/.pivxl/sporks
rm -rf ~/.pivxl/zerocoin
rm -rf ~/.pivxl/evodb
rm -rf ~/.pivxl/peers.dat
cd ~/.pivxl/
wget https://github.com/PivxLiteDev/PivxLite/releases/download/v2.1.0/bootstrap.zip
unzip bootstrap.zip

cd ..
rm -rf ~/.pivxl/bootstrap.zip ~/PIVXL_2.1.0

# add new nodes to config file
sed -i '/addnode/d' ~/.pivxl/pivxl.conf

echo "addnode=51.79.86.43
addnode=3.123.42.9
addnode=44.231.117.119
addnode=34.209.36.103
addnode=51.75.71.14
addnode=51.75.70.32
addnode=51.79.74.146
addnode=51.79.74.147
addnode=139.99.61.24
addnode=139.99.61.72
addnode=139.99.61.16
addnode=149.56.99.99" >> ~/.pivxl/pivxl.conf

#start pivxld
pivxld -daemon

printf '#!/bin/bash\nif [ ! -f "~/.pivxl/pivxl.pid" ]; then /usr/local/bin/pivxld -daemon ; fi' > /root/pivxlauto.sh
chmod -R 755 /root/pivxlauto.sh
#Setting auto start cron job for PivxLite
if ! crontab -l | grep "pivxlauto.sh"; then
    (crontab -l ; echo "*/5 * * * * /root/pivxlauto.sh")| crontab -
fi

echo "Masternode Updated!"
echo "Please wait a few minutes and start your Masternode again on your Local Wallet"