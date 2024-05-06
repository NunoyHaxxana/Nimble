#!/bin/bash

function Install_Golang {
echo -e "\e[1m\e[32mInstalling Golang ... \e[0m" && sleep 1
cd $HOME
sudo wget https://golang.org/dl/go1.22.2.linux-amd64.tar.gz < "/dev/null"
sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
echo -e "$Go version 1.22 has been installed."
}


function Install_Python {
echo " "
echo -e "\e[1m\e[32mInstalling Python 3 ... \e[0m" && sleep 1
sudo apt-get install python3-venv -y < "/dev/null"
}


function Install_Component {
echo " "
echo -e "\e[1m\e[32mInstalling Component ... \e[0m" && sleep 1
sudo sudo apt-get install tmux -y < "/dev/null"
sudo apt-get install software-properties-common -y < "/dev/null"
sudo add-apt-repository ppa:deadsnakes/ppa -y < "/dev/null"
sudo apt-get install make -y < "/dev/null"
sudo apt-get install build-essential -y < "/dev/null"
}



function Miner {
echo " "
echo -e "\e[1m\e[32mSet chain id mamaki and keyring-backend test... \e[0m" && sleep 1
cd $HOME/nimble/nimble-miner-public/
source ./nimenv_localminers/bin/activate
make run addr=$(cat $HOME/nimble/nimble-miner-public/Sub.wallet)  # 
}



function Checkbalances  {
echo " "
cd $HOME/nimble/nimble-miner-public/
make check addr=$(cat $HOME/nimble/nimble-miner-public/Master.wallet)  
}


function Install_Miner {
    echo " "
    echo -e "\e[1m\e[32mInstalling Miner ... \e[0m" && sleep 1
    mkdir $HOME/nimble && cd $HOME/nimble
    git clone https://github.com/nimble-technology/nimble-miner-public.git
    cd nimble-miner-public
    git pull
    sudo rm requirements.txt

    echo '
    requests==2.31.0
    torch==1.10.0
    accelerate==0.27.0
    transformers==4.38.1
    datasets==2.17.1
    numpy==1.24
    gitpython==3.1.42' > requirements.txt
    make install
    clear
    echo -e "\e[1m\e[32mSetup Wallet ... \e[0m" && sleep 3
    echo -e "Please enter your Master address wallet:"
    read -r varaddress
    echo "$varaddress" > $HOME/nimble/nimble-miner-public/Master.wallet 
    echo -e "\e[1m\e[32mYour Master Address is : $(cat $HOME/nimble/nimble-miner-public/Master.wallet)  \e[0m" && sleep 1
    echo "                "
    echo "                "

    echo -e "Please enter your Sub address wallet"
    read -r varaddress
    echo "$varaddress" > $HOME/nimble/nimble-miner-public/Sub.wallet 
    echo -e "\e[1m\e[32mYour Sub Address is : $(cat $HOME/nimble/nimble-miner-public/Sub.wallet)  \e[0m" && sleep 1
    echo "                "
    echo "                "
    echo -e "\e[1m\e[32mYour Nimble Miner was Installed!\e[0m" && sleep 1
    main_menu
}

function main_menu {
    PS3='Please enter your choice (input your option number and press enter): '
    options=("Install Nimble Miner" "Run the Miner" "Check Balance" "Quit")

    select opt in "${options[@]}"
    do
        case $opt in
            "Install Nimble Miner")
                echo -e '\e[1m\e[32mYou choose Install Nimble Miner ...\e[0m' && sleep 1
                Install_Golang
                Install_Python
                Install_Component
                Install_Miner
                continue
                ;;

            "Run the Miner")
                echo -e '\e[1m\e[32mYou choose Run the Miner ...\e[0m' && sleep 1
                Miner
                echo -e "\e[1m\e[32mReturning to the main menu...\e[0m" && sleep 1
                main_menu
                ;;

            "Check Balance")
                echo -e '\e[1m\e[32mYou choose Check Balance...\e[0m' && sleep 1
                Checkbalances
                echo -e "\e[1m\e[32mReturning to the main menu...\e[0m" && sleep 1
                main_menu
                ;;

            "Quit")
                echo -e "\e[1m\e[32mExiting the program...\e[0m" && sleep 1
                break
                ;;

            *)
                echo -e "\e[91minvalid option $REPLY\e[0m"
                ;;
        esac
    done
}

main_menu
