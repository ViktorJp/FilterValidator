# FilterValidator v0.7
Asus-Merlin Skynet Firewall Filter Validator

Filter Validator tests the IPv4 addresses (and IPv6 if present) on a given filter list that are to be used with the Skynet Firewall running on Asus-Merlin Firmware in order to block incoming/outgoing IPs. This script arose out of the need to determine exactly which blacklist URL contained an invalid IP that was causing our Skynet firewalls to fail importing the correct IP sets due to an invalid IP somewhere on these lists.

EDIT: As of March 10, 2023 -- Skynet v7.3.6 now has the necessary regex fixes included to filter out invalid addresses that were breaking the script, wholly inspired by Filter Validator, with many thanks to @SomeWhereOverTheRainBow for his excellent contributions making both scripts even better! Filter Validator may still play a role to determine if blacklist operators are continuing to maintain IP address data integrity, but also giving you a sense on how many entries are in your filter lists. Skynet has a hard limit of 500,000 entries at this point, and Filter Validator may tell you if you're getting too close. Last, other blacklists may stop being supported, or even disappear -- and while Skynet wouldn't give you any indication of this happening, Filter Validator will.

-------------------------------------------------------------------------------------------------------------------------
Usage Guide
-------------------------------------------------------------------------------------------------------------------------
Execute the script as such: sh /jffs/scripts/filtervalidator.sh

Upon execution, it will ask for a valid URL to the specified filter list to be tested. For example, here is are a few valid filter list URLs that will be used if you press enter:

https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list
https://raw.githubusercontent.com/jumpsmm7/GeneratedAdblock/master/filter.list

NOTE: Should any list come back with any invalid IP entries (marked in Red), it would be advisable to remove or #COMMENT out the offending entry in your filter list in order to get Skynet back in working condition, or get in touch with the entity that takes care of the list in order to correct their mistake.
