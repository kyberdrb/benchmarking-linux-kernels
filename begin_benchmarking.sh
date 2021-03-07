#!/bin/sh

SCRIPT_DIR="$(dirname $0)"

sudo ls -d
clear -x

date

sleep 5
ubench

date

sleep 10
rm -f "${HOME}"/interbench.*
#sudo interbench

date

# https://linuxhandbook.com/check-group-of-user/
GROUP=$(id --group --name $USER)

sudo chown $USER:$GROUP "${HOME}/$(uname -r).log"
mv "${HOME}/$(uname -r).log" "${SCRIPT_DIR}/data/raw_data/interbench-$(uname -r).log"

#rm -f "${HOME}"/interbench.*

echo
echo "Check vulnerability status"
echo

paste <( ls -1 /sys/devices/system/cpu/vulnerabilities/ ) <( cat /sys/devices/system/cpu/vulnerabilities/* ) | sed 's/\t/: /g'

echo

touch "${SCRIPT_DIR}"/data/raw_data/unixbench-$(uname -r).txt

echo
echo "Manual post-processing instructions for 'unixbench' output:"
echo
echo "Copy 'unixbench' output from terminal"
echo
echo "    - select text from the beginning of the 'unixbench' output starting with date"
echo "    - scroll down until the next date"
echo "    - press 'Ctrl+Shift+C'"
echo
echo "Open file in 'vim'"
echo
echo "    vim "${SCRIPT_DIR}"/data/raw_data/unixbench-$(uname -r).txt"
echo
echo "Paste copied output to the file"
echo
echo "    press 'i', then 'Ctrl+Shift+V', then 'Esc'"
echo
echo "Remove lines to attain unified file format"
echo
echo "    press ':', then '2,63d'"
echo
echo "Remove all empty lines at the bottom of the file"
echo
echo "    press 'G', then 'dd' as many times, as there are blank lines"
echo
echo "Add padding to ensure format uniformity when you disabled SMT/HyperTreading or swapped CPU that has different amout of cores"
echo
echo "    press ':', then ':15put! =repeat(\"\n\",4)'"
echo "which puts 4 new lines after the line 15"
echo "https://unix.stackexchange.com/questions/14746/vi-command-for-adding-blank-line/616581#616581"
echo
echo "Save and exit file"
echo
echo "    press ':', then 'wq'"
echo

