# FilterValidator v0.2
Asus-Merlin Skynet Firewall Filter Validator

Filter Validator tests the IPv4 addresses (and IPv6 if present) on a given filter list that are to be used with the Skynet Firewall on Asus-Merlin Firmware in order to block incoming/outgoing IPs. This script arose out of the need to determine exactly which blacklist URL contained an invalid IP that was causing our Skynet firewalls to fail importing the correct IP sets due to an invalid IP somewhere on these lists.

-------------------------------------------------------------------------------------------------------------------------
Usage Guide
-------------------------------------------------------------------------------------------------------------------------
Execute the script as such:  sh filtervalidator.sh

Upon execution, it will ask for a valid URL to the specified filter list to be tested.  For example, here is a valid filter list URL that will be used if you press enter: https://raw.githubusercontent.com/ViktorJp/Skynet/main/filter.list

NOTE: Should any list come back with any invalid IP entries (marked in Red), it would be advisable to #COMMENT out the offending entry in your filter list in order to get Skynet back in working condition, or get in touch with the entity that takes care of the list in order to correct their mistake.
