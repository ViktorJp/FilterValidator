#!/bin/sh

# -------------------------------------------------------------------------------------------------------------------------
# About Filter Validator v0.7 - by Viktor Jaep & SomewhereOverTheRainbow 2023
# -------------------------------------------------------------------------------------------------------------------------
# Filter Validator tests the IPv4 addresses (and IPv6 if present) on a given filter list that are to be used with the
# Skynet Firewall on Asus-Merlin Firmware in order to block incoming/outgoing IPs. This script arose out of the need to
# determine exactly which blacklist URL contained an invalid IP that was causing our Skynet firewalls (prior to v7.3.6)
# fail importing the correct IP sets due to an invalid IP somewhere on these lists.

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

#Display title and instructions
clear
echo -e "${CYellow}"
echo -e "   _____ ____            _   __     ___    __     __          "
echo -e "  / __(_) / /____ ____  | | / /__ _/ (_)__/ /__ _/ /____  ____"
echo -e " / _// / / __/ -_) __/  | |/ / _ '/ / / _  / _ '/ __/ _ \/ __/"
echo -e "/_/ /_/_/\__/\__/_/     |___/\_,_/_/_/\_,_/\_,_/\__/\___/_/   v0.7"
echo -e "        By @Viktor Jaep and @SomewhereOverTheRainbow"
echo ""
echo -e "${CCyan}Filter Validator was designed to run through your Skynet filter lists to"
echo -e "determine if all IP addresses fall within their normal ranges. Should any"
echo -e "entries not follow standard IP rules, they will be identified below. ${CRed}NOTE:"
echo -e "Having invalid IPs within these filter sets will cause the Skynet firewall"
echo -e "(prior to v7.3.6) to malfunction due to regex issues that fail to filter"
echo -e "out bad IPs, causing a loss of blocked IPs and ranges."
echo ""
echo -e "${CCyan}Please enter a valid filter list URL, or hit <ENTER> to use example below:"
echo -e "${CClear}Example 1: https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list"
echo -e "Example 2: https://raw.githubusercontent.com/jumpsmm7/GeneratedAdblock/master/filter.list"
echo ""
read -p 'URL: ' filterlist1

  #Pre-processing START
  read up rest </proc/uptime; init_start="${up%.*}${up#*.}"

  #Read in the specific URL, or randomly choose between 2 preconfigured URLs
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

#Show which filter is being used
echo ""
echo -e "${CGreen}Testing against: $filterlist${CClear}"
echo ""
printf "${CGreen}\r[Downloading Filter List]"

#Download the filter list containing blacklist URLs
curl --silent --retry 3 --request GET --url $filterlist > /jffs/scripts/filter.txt

printf "\r[Downloading Filter List]...OK"
printf "\n[Checking Filter List Contents]"

#Determine the number of lines in the filter list
LINES=$(sed -n '$=' /jffs/scripts/filter.txt) >/dev/null 2>&1

#If there's no lines, exit, else continue
if [ -z "$LINES" ]; then
  printf "${CRed}\r[Invalid Filter List...Exiting]"
  echo ""
  echo ""
  exit 0
else
  printf "${CGreen}\r[Checking Filter List Contents]...OK"
fi

#Pre-processing END
read up rest </proc/uptime; init_end="${up%.*}${up#*.}"

#Pre-processing RUNTIME
init_runtime="$((10*(init_end-init_start)))"

echo -e "\n${CClear}[Pre-processing Runtime]: $init_runtime ms or $(printf $init_runtime | awk 'NF{print $1/1000}' OFMT="%.3f") sec${CClear}"
echo ""
echo -e "--------------------------------------------------------------------------"
echo ""

#Loop through the rows of the filter list
blvalid=0
blprobs=0
for listcount in $(sed -n '=' /jffs/scripts/filter.txt | awk '{printf "%s ", $1}'); do

  #Operations START
  read up rest </proc/uptime; start="${up%.*}${up#*.}"

  #Grab the next URL in the filter list
  blacklisturl=$(grep -vE '^[[:space:]]*#' /jffs/scripts/filter.txt | sed -n $listcount'p') 2>&1

  #If there's a blank line by chance, continue
  if [ -z $blacklisturl ]; then continue; fi

  echo "Checking $blacklisturl"

  #Grab the contents of the URL and store in fltcontents.txt
  curl --location --silent --retry 3 --request GET --url $blacklisturl > /jffs/scripts/fltcontents.txt

  #Filter and determine the number of entries in the specific URL filter list
  BLLINES=$(grep -cvE '^[[:space:]]*#' /jffs/scripts/fltcontents.txt) >/dev/null 2>&1

  #Determine if there are any invalid entries in the list
  ipresults=$(awk '!/^((((25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])\.){3}(25[0-5]|(2[0-4]|1[0-9]|[1-9]|)[0-9])(\/(1?[0-9]|2?[0-9]|3?[0-2]))?))|((([0-9A-f]{0,4}:){1,7}[0-9A-f]{0,4}:?(\/(1?[0-2][0-8]|[0-9][0-9]))?))$/{if($1 !~ /^[[:space:]]*#/)print $1}' /jffs/scripts/fltcontents.txt)

  #Display valid or invalid results
  if [ ! -z $ipresults ]; then
    echo -e "Invalid IPs:${CRed}"
    echo $ipresults
    echo -e "${CClear}"
    blprobs=$(($blprobs+1))
  else
    echo -en "${CGreen}[Valid]${CClear} [Entries: $BLLINES] "
    blvalid=$(($blvalid+1))
    blitems=$(($blitems+$BLLINES))
  fi

  #cleanup
  rm -f /jffs/scripts/fltcontents.txt

  #Operations END
  read up rest </proc/uptime; end="${up%.*}${up#*.}"
  printf "[Processing Time: $((10*(end-start))) ms or $(printf $((10*(end-start))) | awk 'NF{print $1/1000}' OFMT="%.3f") sec]\n"
  echo ""

  #Operational RUNTIME
  [ -z "$final_runtime" ] && final_runtime="$((10*(end-start)))" || final_runtime="$((final_runtime+(10*(end-start))))"
  unset start end

done

#Total RUNTIME
runtime="$((final_runtime+init_runtime))"

#Display a summary
echo -e "--------------------------------------------------------------------------"
echo -e "${CGreen}[Valid List Entries]: $blvalid"
echo -e "${CRed}[Invalid List Entries]: $blprobs${CClear}"
echo -e "[Total Items Checked]: $blitems"
echo -e "[Total Processing Runtime]: $runtime ms or $(printf $runtime | awk 'NF{print $1/1000}' OFMT="%.3f") sec"

echo ""

#cleanup
rm -f /jffs/scripts/filter.txt

#} #2>&1 | tee $LOG | logger -t $(basename $0)[$$]  # uncomment/comment to enable/disable debug mode
