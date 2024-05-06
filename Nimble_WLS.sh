#!/bin/bash

function Install_Golang {
    echo -e "\e[1m\e[32mChecking for existing Go installation... \e[0m" && sleep 1

    # Check if Go is installed and get the version if it exists
    if go version &>/dev/null; then
        INSTALLED_GO_VERSION=$(go version | awk '{print $3}')
        echo "Found Go: $INSTALLED_GO_VERSION"
        # Check if the installed version is not what we want
        if [[ "$INSTALLED_GO_VERSION" == "go1.22.2" ]]; then
            echo -e "Go version 1.22.2 is already installed."
            return 0
        else
            echo "Removing older version of Go..."
            sudo rm -rf /usr/local/go
        fi
    fi

    echo "Installing Golang 1.22.2..."
    sudo apt-get update > /dev/null
    cd /tmp
    sudo wget -q https://go.dev/dl/go1.22.2.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.22.2.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.profile
    source $HOME/.profile

    echo -e "Go version 1.22.2 has been installed."
}




function Install_Python {
    echo " "
    echo -e "\e[1m\e[32mChecking and installing Python 3.10 if necessary ... \e[0m" && sleep 1

    # Check current Python version
    PYTHON_VERSION=$(python3 --version 2>&1 | grep -Po '(?<=Python )\d+\.\d+\.\d+')

    # Check if Python 3.10 is already installed
    if [[ "$PYTHON_VERSION" == "3.10"* ]]; then
        echo "Python 3.10 is already installed."
        return 0
    fi

    if [[ "$PYTHON_VERSION" < "3.10" ]]; then
        echo "Removing older version of Python..."
        sudo apt-get remove --purge python3 -y
    fi
    sudo apt update
    sudo add-apt-repository ppa:deadsnakes/ppa -y
    sudo apt update
    echo "Installing Python 3.10..."
    sudo apt install python3.10 python3.10-venv python3.10-distutils -y
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo python3.10 get-pip.py
    sudo apt install git -y
    rm get-pip.py

    echo "Python 3.10 installation is complete."
}








function Install_Component {
    echo " "
    echo -e "\e[1m\e[32mInstalling Component ... \e[0m" && sleep 1

    # Install tmux, make, and build-essential if not specified they need to be checked
    sudo apt install screen -y > /dev/null
    sudo apt-get install tmux -y > /dev/null
    sudo apt-get install make -y > /dev/null
    sudo apt-get install build-essential -y > /dev/null

    # Check if nvidia-driver-545 is installed
    if ! dpkg -l | grep -qw nvidia-driver-545; then
        echo "Installing nvidia-driver-545..."
        sudo apt-get install nvidia-driver-545 -y
    else
        echo "nvidia-driver-545 is already installed, skipping..."
    fi

    # Check if nvidia-cuda-toolkit is installed
    if ! dpkg -l | grep -qw nvidia-cuda-toolkit; then
        echo "Installing nvidia-cuda-toolkit..."
        sudo apt-get install nvidia-cuda-toolkit -y
    else
        echo "nvidia-cuda-toolkit is already installed, skipping..."
    fi
}




function Miner {
    echo " "
    echo -e "\e[1m\e[32mStart Miner... \e[0m" && sleep 1

cd $HOME/nimble/nimble-miner-public/
source ./nimenv_localminers/bin/activate
make run addr=\$(cat $HOME/nimble/nimble-miner-public/Sub.wallet)
#    # Check the status of the 'Nimble' screen session
#    SCREEN_STATUS=$(screen -list | grep "Nimble")
#
#    if [[ "$SCREEN_STATUS" == *Detached* ]]; then
#        echo "Resuming detached 'Nimble' screen session."
#        screen -r Nimble
#    else
#        if [[ ! -z "$SCREEN_STATUS" ]]; then
#            echo "Existing 'Nimble' session is not detached. Killing session."
#            # Extract session ID and kill it
#            SCREEN_ID=$(echo $SCREEN_STATUS | awk -F '.' '{print $1}' | awk '{print $1}')
#            screen -S $SCREEN_ID -X quit
#        fi
#
#        echo "Creating new 'Nimble' screen session and executing commands."
#        screen -S Nimble -dm bash -c "cd $HOME/nimble/nimble-miner-public/; source ./nimenv_localminers/bin/activate; make run addr=\$(cat $HOME/nimble/nimble-miner-public/Sub.wallet); exec bash"
#  
#        screen -r Nimble
#   fi
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
    pip uninstall torch


echo '
requests==2.31.0
torch==2.3.0
accelerate==0.27.0
transformers==4.38.1
datasets==2.17.1
numpy==1.24
gitpython==3.1.42' > requirements.txt

make install
pip uninstall fsspec -y
pip install 'fsspec==2023.10.0'
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





