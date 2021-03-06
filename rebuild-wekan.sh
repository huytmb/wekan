#!/bin/bash

echo "Note: If you use other locale than en_US.UTF-8 , you need to additionally install en_US.UTF-8"
echo "      with 'sudo dpkg-reconfigure locales' , so that MongoDB works correctly."
echo "      You can still use any other locale as your main locale."

#Below script installs newest node 8.x for Debian/Ubuntu/Mint.

function pause(){
	read -p "$*"
}

echo
PS3='Please enter your choice: '
options=("Install Wekan dependencies" "Build Wekan" "Run Meteor for dev on http://localhost:4000" "Run Meteor for dev on http://CURRENT-IP-ADDRESS:4000" "Run Meteor for dev on http://CUSTOM-IP-ADDRESS:PORT" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "Install Wekan dependencies")

		if [[ "$OSTYPE" == "linux-gnu" ]]; then
	                echo "Linux";
			# Debian, Ubuntu, Mint
			sudo apt-get install -y build-essential gcc g++ make git curl wget
			# npm nodejs
			#sudo npm -g install npm
			curl -0 -L https://npmjs.org/install.sh | sudo sh
			sudo chown -R $(id -u):$(id -g) $HOME/.npm
			sudo npm -g install n
			sudo n 14.15.0
			#curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
			#sudo apt-get install -y nodejs
		elif [[ "$OSTYPE" == "darwin"* ]]; then
		        echo "macOS";
			pause '1) Install XCode 2) Install Node 8.x from https://nodejs.org/en/ 3) Press [Enter] key to continue.'
		elif [[ "$OSTYPE" == "cygwin" ]]; then
		        # POSIX compatibility layer and Linux environment emulation for Windows
		        echo "TODO: Add Cygwin";
			exit;
		elif [[ "$OSTYPE" == "msys" ]]; then
		        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
		        echo "TODO: Add msys on Windows";
			exit;
		elif [[ "$OSTYPE" == "win32" ]]; then
		        # I'm not sure this can happen.
		        echo "TODO: Add Windows";
			exit;
		elif [[ "$OSTYPE" == "freebsd"* ]]; then
		        echo "TODO: Add FreeBSD";
			exit;
		else
		        echo "Unknown"
			echo ${OSTYPE}
			exit;
		fi

		## Latest npm with Meteor 1.8.x
		sudo npm -g install npm
		sudo npm -g install node-gyp
		# Latest fibers for Meteor 1.8.x
		sudo mkdir -p /usr/local/lib/node_modules/fibers/.node-gyp
		sudo npm -g install fibers
		# Install Meteor, if it's not yet installed
		curl https://install.meteor.com | bash
		sudo chown -R $(id -u):$(id -g) $HOME/.npm $HOME/.meteor
		break
		;;

    "Build Wekan")
		echo "Building Wekan."
		#if [[ "$OSTYPE" == "darwin"* ]]; then
		#	echo "sed at macOS";
		#	sed -i '' 's/api\.versionsFrom/\/\/api.versionsFrom/' ~/repos/wekan/packages/meteor-useraccounts-core/package.js
		#else
		#	echo "sed at ${OSTYPE}"
		#	sed -i 's/api\.versionsFrom/\/\/api.versionsFrom/' ~/repos/wekan/packages/meteor-useraccounts-core/package.js
		#fi
		#cd ..
		sudo chown -R $(id -u):$(id -g) $HOME/.npm $HOME/.meteor
		rm -rf node_modules .meteor/local
		npm install
		rm -rf .build
		meteor build .build --directory
		cp -f fix-download-unicode/cfs_access-point.txt .build/bundle/programs/server/packages/cfs_access-point.js
		# Remove legacy webbroser bundle, so that Wekan works also at Android Firefox, iOS Safari, etc.
		rm -rf .build/bundle/programs/web.browser.legacy
		#Removed binary version of bcrypt because of security vulnerability that is not fixed yet.
		#https://github.com/wekan/wekan/commit/4b2010213907c61b0e0482ab55abb06f6a668eac
		#https://github.com/wekan/wekan/commit/7eeabf14be3c63fae2226e561ef8a0c1390c8d3c
		#cd ~/repos/wekan/.build/bundle/programs/server/npm/node_modules/meteor/npm-bcrypt
		#rm -rf node_modules/bcrypt
		#meteor npm install bcrypt
		cd .build/bundle/programs/server
		rm -rf node_modules
		npm install
		#meteor npm install bcrypt
		cd ../../../..
		echo Done.
		break
		;;

    "Run Meteor for dev on http://localhost:4000")
		WITH_API=true RICHER_CARD_COMMENT_EDITOR=false ROOT_URL=http://localhost:4000 meteor run --exclude-archs web.browser.legacy,web.cordova --port 4000
		break
		;;

    "Run Meteor for dev on http://CURRENT-IP-ADDRESS:4000")
		IPADDRESS=$(ip a | grep 'noprefixroute' | grep 'inet ' | cut -d: -f2 | awk '{ print $2}' | cut -d '/' -f 1)
		echo "Your IP address is $IPADDRESS"
		WITH_API=true RICHER_CARD_COMMENT_EDITOR=false ROOT_URL=http://$IPADDRESS:4000 meteor run --exclude-archs web.browser.legacy,web.cordova --port 4000
		break
		;;

    "Run Meteor for dev on http://CUSTOM-IP-ADDRESS:PORT")
		ip address
		echo "From above list, what is your IP address?"
		read IPADDRESS
		echo "On what port you would like to run Wekan?"
		read PORT
		echo "ROOT_URL=http://$IPADDRESS:$PORT"
    WITH_API=true RICHER_CARD_COMMENT_EDITOR=false ROOT_URL=http://$IPADDRESS:$PORT meteor run --exclude-archs web.browser.legacy,web.cordova --port $PORT
		break
    ;;

    "Quit")
		break
    ;;
    *) echo invalid option;;
    esac
done
