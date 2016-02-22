#!/bin/bash

# Install the basics
read -p "Install updates? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    yum update -y
    yum install -y epel-release
    yum repolist
    yum install -y git vim wget tmux htop nano nginx mlocate python-devel zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel httpd-tools
    yum groupinstall -y "Development Tools"
    updatedb
fi

# Install NodeJS
read -p "Install NodeJS? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd lib
    python install_node.py
    cd ..
fi

# Install Meteor
read -p "Install Meteor? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl https://install.meteor.com/ | sh
fi

# Install Docker
read -p "Install Docker? [y/N]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl -sSL https://get.docker.com/ | sh
    sudo systemctl enable docker
    sudo systemctl start docker
    yum install -y bash-completion
    wget https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker -O /etc/bash_completion.d/docker
fi

# Create dev user
read -p "Create dev user? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo -n "Enter dev username: "
    read DEV_USER
    echo "Creating user $DEV_USER..."
    useradd $DEV_USER
    passwd $DEV_USER
    echo "$DEV_USER ALL=(ALL) ALL" > /etc/sudoers.d/$DEV_USER
    echo "Added $DEV_USER to sudoers"

    tmux start-server

    # Install pyenv
    read -p "Install Pyenv for $DEV_USER? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        PYENV_SESSION='pyenv-install'
echo 1
        tmux new-session -d -s $PYENV_SESSION -n pyenv-install
echo 2
        PYENV_WINDOW="$PYENV_SESSION:0"
echo $PYENV_WINDOW
        #tmux select-window -t $PYENV_WINDOW
        tmux rename-window -t $PYENV_WINDOW "Pyenv Install"
        tmux send-keys -t $PYENV_WINDOW "su - dev" C-m
        tmux send-keys -t $PYENV_WINDOW "echo 'export PATH=\"/home/$DEV_USER/.pyenv/bin:\$PATH\"' >> .bash_profile" C-m
        tmux send-keys -t $PYENV_WINDOW "echo 'eval \"\$(pyenv init -)\"' >> .bash_profile" C-m
        tmux send-keys -t $PYENV_WINDOW "echo 'eval \"\$(pyenv virtualenv-init -)\"' >> .bash_profile" C-m
        tmux send-keys -t $PYENV_WINDOW "curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash" C-m
        tmux send-keys -t $PYENV_WINDOW "source ~/.bash_profile" C-m
        tmux send-keys -t $PYENV_WINDOW "exit" C-m
        tmux send-keys -t $PYENV_WINDOW "exit" C-m
        # tmux send-keys -t $PYENV_WINDOW "pyenv install 2.7.10" C-m
        tmux attach-session -t $PYENV_SESSION
    fi

    # Install Cloud9
    read -p "Install Cloud9 for $DEV_USER? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Installing requirements..."
        sleep 1
        yum install -y glibc-static httpd-tools nginx
        setsebool -P httpd_can_network_connect on
        
        echo "Creating SSL certs..."
        sleep 1
        mkdir -p /etc/nginx/ssl/
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/c9.key -out /etc/nginx/ssl/c9.crt
        
        echo "Creating authentication for $DEV_USER..."
        sleep 1
        htpasswd -c /etc/nginx/auth $DEV_USER
        
        echo "Copying nginx config..."
        sleep 1
        cp lib/c9.conf /etc/nginx/conf.d/
        vim /etc/nginx/conf.d/c9.conf
        systemctl restart nginx
        
        echo "Copying c9 service file..."
        sleep 1
        cp lib/c9.service /usr/lib/systemd/system/
        vim /usr/lib/systemd/system/c9.service
        systemctl enable c9
        
        echo "Installing Cloud9..."
        sleep 1

        C9_SESSION='c9-install'
        tmux new-session -d -s $C9_SESSION -n c9-install

        C9_WINDOW="$C9_SESSION:0"
        tmux rename-window -t $C9_WINDOW "Cloud9 Install"
        tmux send-keys -t $C9_WINDOW "su - dev" C-m
        tmux send-keys -t $C9_WINDOW "git clone git://github.com/c9/core.git .c9sdk" C-m
        tmux send-keys -t $C9_WINDOW "cd .c9sdk" C-m
        tmux send-keys -t $C9_WINDOW "git reset --hard c471ab0e4c7cb983e1e4c40675b3fd63916c9394"
        tmux send-keys -t $C9_WINDOW "scripts/install-sdk.sh" C-m
        tmux send-keys -t $C9_WINDOW "exit" C-m
        tmux send-keys -t $C9_WINDOW "exit" C-m
        tmux attach-session -t $C9_SESSION
        
        echo "Cloud9 Installed. To run it type 'systemctl start c9'."
    fi
fi
