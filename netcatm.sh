#!/bin/bash
# Herramienta dirigida a personas con poca experiencia con netcat
# Desarrollado por: Jorge Arana Fedriani
# Para salir de la herramienta se recomienda utilizar Ctrl + Z

# Paleta de colores
sin_color="\033[0m"
red="\033[0;31m"
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'

# Evitamos que el usuario reciba un error con tput civis
reset_cursor() {
    tput cnorm
    exit 1
}
trap reset_cursor SIGINT

# Comprobamos los privilegios de sistema
if ! [ "$(id -u)" == "0" ]; then
	echo -e "${red}YOU AREN'T ROOT!!${sin_color}"
	exit
fi

clear

# Comprobamos que la herramienta esta instalada
if ! [ "$(which netcat)" == "/usr/bin/netcat" ]; then
	echo -e "${red}Netcat not installed"
	read -p "$(echo -e ${cyan})Do you want to install netcat? $(echo -e ${green})[y/n]: " netcat
	if [ $netcat == "y" ]; then
		apt install netcat-traditional
		clear
	else
		clear
		exit
	fi
fi

# Iniciamos el bucle
while true; do
	echo -e " ${red} _   _       _${sin_color}"
	echo -e " ${red}| \\ | | ___ | |__${sin_color}"
	echo -e " ${red}|C \\| |/ _ \ T__|${sin_color}"
	echo -e " ${red}| |\\  | A _/| |${sin_color}"
	echo -e " ${red}|_| \\_|\\___ |_|${sin_color}${cyan}  By: Jorge Arana Fedriani${sin_color}"
	echo ""
	echo -e " ${green}[0]${sin_color} ${magenta}Open port${sin_color}"
	echo -e " ${green}[1]${sin_color} ${magenta}Open port with shell${sin_color}"
	echo -e " ${green}[2]${sin_color} ${magenta}Connect to IP using port number${sin_color}"
	echo -e " ${green}[3]${sin_color} ${magenta}Scan ports${sin_color}"
	echo -e ""
	read -p " $(echo -e ${yellow})Select the best option for your case: $(echo -e ${sin_color})" option
	case $option in
		0)
		  read -p " $(echo -e ${cyan})Do you want to activate verbose mode?$(echo -e ${green}) [y/n]:$(echo -e ${sin_color}) " verbose
		  if [ $verbose == "y" ]; then
		  	sigint_handler() {
                        	return 1
                  	}
                  	trap sigint_handler SIGINT
                  	while true; do
                        	echo -e "${blue}     -----------------------------${sin_color}"
                        	read -p " $(echo -e ${yellow})Port you want to open: $(echo -e ${sin_color})" port
                        	echo -ne "${red}"
                        	clear & netcat -lvp $port
                        	if [ $? -eq 1 ]; then
                                	clear
					break
                        	fi
                        	echo -ne "${sin_color}"
                  	done
		  else
			echo -e "${blue}     -----------------------------${sin_color}"
                        read -p " $(echo -e ${yellow})Port you want to open: $(echo -e ${sin_color})" port
		  	netcat -lvp $port > /dev/null 2>&1 & nc_pid=$!
                  	tput civis
                  	read -n 1 -s -r -p "$(echo -e ${cyan}) Press 'q' to stop listening and return to menu$(echo -e ${sin_color})" input
                  	while true; do
                        	if [ -n "$input" ]; then
                                	# Detener netcat y volver al bucle principal
                                	kill $nc_pid > /dev/null 2&>1
                                	wait $nc_pid 2>/dev/null
                                	echo -e "${red} --> Stopped listening on port ${port}.${sin_color}"
                                	tput cnorm
                                	break
                        	fi
                  	done
		  fi
                  ;;
		1)
		  read -p " $(echo -e ${cyan})Do you want to activate verbose mode?$(echo -e ${green}) [y/n]:$(echo -e ${sin_color}) " verbose
                  if [ $verbose == "y" ]; then
                        sigint_handler() {
                                return 1
                        }
                        trap sigint_handler SIGINT
                        while true; do
                                echo -e "${blue}     -----------------------------"
                                read -p " $(echo -e ${yellow})Port you want to open: $(echo -e ${sin_color})" port
                                echo -ne "${red}"
                                clear & netcat -lvp $port -e /bin/bash -k
                                if [ $? -eq 1 ]; then
                                        clear
                                        break
                                fi
                                echo -ne "${sin_color}"
                        done
                  else
                        echo -e "${blue}     -----------------------------${sin_color}"
                        read -p " $(echo -e ${yellow})Port you want to open: $(echo -e ${sin_color})" port
                        netcat -lvp $port -e /bin/bash -k > /dev/null 2>&1 & nc_pid=$!
                        tput civis
                        read -n 1 -s -r -p "$(echo -e ${cyan}) Press 'q' to stop listening and return to menu$(echo -e ${sin_color})" input
                        while true; do
                                if [ -n "$input" ]; then
                                        # Detener netcat y volver al bucle principal
                                        kill $nc_pid > /dev/null 2&>1
                                        wait $nc_pid 2>/dev/null
                                        echo -e "${red} --> Stopped listening on port ${port}.${sin_color}"
                                        tput cnorm
                                        break
                                fi
                        done
                  fi
		  ;;
		2)
		  sigint_handler() {
    		  	return 1
		  }
		  trap sigint_handler SIGINT
		  while true; do
			  echo -e "${blue}     -----------------------------${sin_color}"
			  read -p " $(echo -e ${yellow})IP to connect: $(echo -e ${sin_color})" ip
			  read -p " $(echo -e ${yellow})Destination port: $(echo -e ${sin_color})" port
			  echo -ne "${red}"
			  clear & netcat $ip $port
			  if [ $? -eq 1 ]; then
				echo -ne "${sin_color}"
				clear
        		  	break
    			  fi
		  done
		  ;;
		3)
		  echo -e "${blue}     -----------------------------${sin_color}"
                  read -p " $(echo -e ${yellow})Ip to scan: $(echo -e ${sin_color})" ip
		  read -p " $(echo -e ${yellow})Ports to map [x-y]: $(echo -e ${sin_color})" ports
		  netcat -zvn $ip $ports > nc_output.txt 2>&1
		  echo -e "${red}"
		  cat nc_output.txt | sed 's/^/ /'
		  echo -ne "${sin_color}"
		  rm nc_output.txt
		  ;;
		*)
		  echo ""
		  echo -ne "${red} ";sleep .1;echo -n "E";sleep .1;echo -n "R";sleep .1;echo -n "R";sleep .1;echo -n "O";sleep .1;echo -ne "R${sin_color}";sleep .2
		  echo ""
		  ;;
	esac
done
