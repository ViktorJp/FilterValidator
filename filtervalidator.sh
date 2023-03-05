#!/bin/sh

# -------------------------------------------------------------------------------------------------------------------------
# About Filter Validator v0.2 - by Viktor Jaep, SomewhereOverTheRainbow 2023
# -------------------------------------------------------------------------------------------------------------------------
# Filter Validator tests the IPv4 addresses (and IPv6 if present) on a given filter list that are to be used with the
# Skynet Firewall on Asus-Merlin Firmware in order to block incoming/outgoing IPs. This script arose out of the need to
# determine exactly which blacklist URL contained an invalid IP that was causing our Skynet firewalls fail importing the
# correct IP sets due to an invalid IP somewhere on these lists.

# -------------------------------------------------------------------------------------------------------------------------
# Usage Guide
# -------------------------------------------------------------------------------------------------------------------------
# Execute the script as such:  sh filtervalidator.sh
# Upon execution, it will ask for a valid URL to the specified filter list to be tested.  For example, here is a valid
# filter list URL that will be used if you press enter: https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list
# NOTE: Should any list come back with any invalid IP entries (marked in Red), it would be advisable to #COMMENT out the
# offending entry in your filter list in order to get Skynet back in working condition, or get in touch with the entity that
# takes care of the list in order to correct their mistake.

# Color variables
CRed="\e[1;31m"
CGreen="\e[1;32m"
CCyan="\e[1;36m"
CYellow="\e[1;33m"
CClear="\e[0m"

#DEBUG=; set -x # uncomment/comment to enable/disable debug mode
#{              # uncomment/comment to enable/disable debug mode

#cleanup
rm -f /jffs/scripts/filter.txt

clear
echo -e "${CYellow}"
echo -e "   _____ ____            _   __     ___    __     __          "
echo -e "  / __(_) / /____ ____  | | / /__ _/ (_)__/ /__ _/ /____  ____"
echo -e " / _// / / __/ -_) __/  | |/ / _ '/ / / _  / _ '/ __/ _ \/ __/"
echo -e "/_/ /_/_/\__/\__/_/     |___/\_,_/_/_/\_,_/\_,_/\__/\___/_/   v0.2"
echo -e "By @Viktor Jaep and @SomewhereOverTheRainbow"
echo ""
echo -e "${CCyan}Filter Validator was designed to run through your Skynet filter lists to determine"
echo -e "if all IP addresses fall within their normal ranges. Should any entries not follow"
echo -e "standard IP rules, they will be identified below. NOTE: Having invalid IPs within"
echo -e "these filter sets will cause the Skynet firewall to malfunction due to regex issues"
echo -e "that are not filtering out bad IPs, causing a loss of blocked IPs and ranges to occur."
echo ""
echo -e "Please enter a valid filter list URL, or hit <ENTER> to use example below:"
echo -e "${CClear}Example 1: https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list"
echo -e "Example 2: https://raw.githubusercontent.com/jumpsmm7/GeneratedAdblock/master/filter.list"
echo ""
read -p 'URL: ' filterlist1
  if [ -z "$filterlist1" ]; then 
    RANDOM=$(awk 'BEGIN {srand(); print int(32768 * rand())}')
    R_NUM=$(( RANDOM % 3 ))
    if [ $R_NUM -eq 0 ]; then R_NUM=1; fi
    if [ $R_NUM -eq 1 ]; then filterlist="https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list"; fi
    if [ $R_NUM -eq 2 ]; then filterlist="https://raw.githubusercontent.com/jumpsmm7/GeneratedAdblock/master/filter.list"; fi
    if [ $R_NUM -eq 3 ]; then filterlist="https://raw.githubusercontent.com/jumpsmm7/GeneratedAdblock/master/filter.list"; fi
  else 
    filterlist=$filterlist1
  fi
echo ""
echo -e "${CGreen}Testing against: $filterlist${CClear}"
echo ""
printf "${CGreen}\r[Downloading Filter List]"

curl --silent --retry 3 --request GET --url $filterlist > /jffs/scripts/filter.txt

printf "\r[Downloading Filter List]...OK"
printf "\n[Checking Filter List Contents]"

LINES=$(cat /jffs/scripts/filter.txt | wc -l) >/dev/null 2>&1

if [ $LINES -eq 0 ]; then
  printf "${CRed}\r[Invalid Filter List...Exiting]"
  echo ""
  echo ""
  exit 0
else
  printf "${CGreen}\r[Checking Filter List Contents]...OK"
fi

echo -e "${CClear}\n"


listcount=0
while [ $listcount -ne $LINES ]; do
  listcount=$(($listcount+1))

  blacklisturl=$(cat /jffs/scripts/filter.txt | sed -n $listcount'p') 2>&1

  if [ -z $blacklisturl ]; then break; fi

  echo "Checking $blacklisturl"

  ipresults=$(curl --silent --retry 3 --request GET --url $blacklisturl | grep "^[^#;]" | grep "\s*$" | grep -E -v "(\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b)|(^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b)" | grep -E -v "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")

  if [ ! -z $ipresults ]; then
    echo -e "Invalid IPs:${CRed}"
    echo $ipresults
    echo -e "${CClear}"
  else
    echo -e "${CGreen}[Valid]${CClear}"
    echo ""
  fi

done

#cleanup
rm -f /jffs/scripts/filter.txt

#} #2>&1 | tee $LOG | logger -t $(basename $0)[$$]  # uncomment/comment to enable/disable debug mode
