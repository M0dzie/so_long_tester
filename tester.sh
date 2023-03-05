#! /bin/bash

blue='\033[1;34m'
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[3;33m'
bold="\033[1m"
nc='\033[0m'

dir_path="../"
dir_prog="${dir_path}./so_long"

## Make project ##

if test -f "$dir_path"Makefile; then
    make -C "$dir_path"
	echo 
	if [[ $? -eq 0 ]]; then
		echo -e "${green}${bold}Compilation succeeded ✓${nc}"
	else
		echo -e "${red}${bold}⚠️ Compilation failed ⚠️${nc}"
	fi
	echo 
fi

## Norm test ##
printf "${blue}${bold}#####		TEST NORM		#####\n\n${nc}"
norminette_success=true
find . -name "*.c" -exec sh -c '
    if test -f norminette; then
        ./norminette -R CheckForbiddenSourceHeader "$1"
        if [ $? -ne 0 ]; then
            exit 1
        fi  
    fi
' sh {} \; || norminette_success=false

if [ $norminette_success = true ]; then
    echo -e "${green}${bold}Norm OK ✓${nc}"
else
    echo -e "${red}${bold}⚠️ Norm KO ⚠️${nc}"
fi

function test_leaks() {
	os=$(uname)
	program="$1"

## Check os for leaks ##
	if [ "$os" == "Linux" ]; then
		leak="valgrind --leak-check=full $program"
		leak_check="ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)"
	elif [ "$os" == "Darwin" ]; then
		leak="leaks --atExit -- $program"
		leak_check="Process [0-9]+: 0 leaks for 0 total leaked bytes."
	else
		echo -e "${red}${bold}⚠️ Wrong OS ⚠️${nc}"
		exit 1
	fi

## Test leaks ##
	output=$(eval "$leak" 2>&1)
	echo "Leak test result: $output"	

	if [[ "$output" == *"$leak_check"* ]]; then
    	echo -e "${green}${bold}No leaks detected ✓${nc}"
	else
    	echo -e "${red}${bold}⚠️ Leaks detected ⚠️ :${nc}"
    	echo "$output"
	fi
}

## Tests ##

printf "${blue}${bold}\n\n#####		TEST MAPS		#####\n\n${nc}"
i=1
printf "${yellow}Test nº$i :	no arguments\n./so_long\n\n${nc}"; ((i=i+1)); "$dir_prog"; test_leaks "$dir_prog"; sleep 1

printf "${blue}${bold}\n\n\n#####		TEST Extensions		#####${nc}"
i=1
printf "${yellow}\n\nTest nº$i : 	no extension\n./so_long map\n\n${nc}"; ((i=i+1)); "$dir_prog map"; test_leaks "$dir_prog map"; sleep 1
printf "${yellow}\n\nTest nº$i : 	uncomplete\n./so_long map.\n\n${nc}"; ((i=i+1)); "$dir_prog map."; sleep 1
printf "${yellow}\n\nTest nº$i : 	uncomplete\n./so_long map.b\n\n${nc}"; ((i=i+1)); "$dir_prog map.b"; sleep 1
printf "${yellow}\n\nTest nº$i : 	uncomplete\n./so_long map.be\n\n${nc}"; ((i=i+1)); "$dir_prog map.be"; sleep 1
printf "${yellow}\n\nTest nº$i : 	too long\n./so_long map.berr\n\n${nc}"; ((i=i+1)); "$dir_prog map.berr"; sleep 1
printf "${yellow}\n\nTest nº$i : 	too short\n./so_long .ber\n\n${nc}"; ((i=i+1)); "$dir_prog .ber"; sleep 1
printf "${yellow}\n\nTest nº$i : 	with folder\n./so_long /.ber\n\n${nc}"; ((i=i+1)); "$dir_prog /.ber"; sleep 1

printf "${blue}${bold}\n\n\n#####		TEST Map		#####${nc}"
i=1
printf "${yellow}\n\nTest nº$i :	no such file\n./so_long map.ber\n${nc}"; ((i=i+1)); $dir_prog map.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	non square\n./so_long maps/non_square.ber\n${nc}"; ((i=i+1)); $dir_prog maps/non_square.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	map non closed\n./so_long maps/non_closed.ber\n${nc}"; ((i=i+1)); $dir_prog maps/non_closed.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	need 1 start\n./so_long maps/no_start.ber\n${nc}"; ((i=i+1)); $dir_prog maps/no_start.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	need 1 exit\n./so_long maps/no_exit.ber\n${nc}"; ((i=i+1)); $dir_prog maps/no_exit.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	need at least 1 collectibles\n./so_long maps/no_collectibles.ber\n${nc}"; ((i=i+1)); $dir_prog maps/no_collectibles.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	no more than 1 start\n./so_long maps/two_start.ber\n${nc}"; ((i=i+1)); $dir_prog maps/two_start.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	no more than 1 exit\n./so_long maps/two_exit.ber\n${nc}"; ((i=i+1)); $dir_prog maps/two_exit.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	only 0, 1, C, E, P characters\n./so_long maps/extra_letter.ber\n${nc}"; ((i=i+1)); $dir_prog maps/extra_letter.ber; sleep 1

printf "${blue}${bold}\n\n\n#####		TEST Finishable		#####${nc}"
i=1
printf "${yellow}\n\nTest nº$i :	player stuck\n./so_long maps/unfinishable_basic_1.ber\n${nc}"; ((i=i+1)); $dir_prog maps/unfinishable_basic_1.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	exit blocked\n./so_long maps/unfinishable_basic_2.ber\n${nc}"; ((i=i+1)); $dir_prog maps/unfinishable_basic_2.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	collectible blocked\n./so_long maps/unfinishable_basic_3.ber\n${nc}"; ((i=i+1)); $dir_prog maps/unfinishable_basic_3.ber; sleep 1
printf "${yellow}\n\nTest nº$i :	wall split map in two\n./so_long maps/unfinishable_basic_4.ber\n${nc}"; ((i=i+1)); $dir_prog maps/unfinishable_basic_4.ber; sleep 1

## Cleaning ##
make fclean -C $dir_path