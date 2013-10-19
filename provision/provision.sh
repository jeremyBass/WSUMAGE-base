# provision.sh
#
# This file is specified in Vagrantfile and is loaded by Vagrant as the primary
# provisioning script whenever the commands `vagrant up`, `vagrant provision`,
# or `vagrant reload` are used. It provides all of the default packages and
# configurations included with Varying Vagrant Vagrants. 
# It's worth noting that you dont' need the normal #!/bin/bash for this included file


## since we are generating from Mac or Windows this is needed 
apt-get install dos2unix


cd /srv/www/scripts/
find . -type f -exec dos2unix {} \; 


cd /srv/www/
. scripts/install-functions.sh

#so we would put this as a loop over and detact if keeped this way
cd /srv/www/
. scripts/magento/functions.sh

. scripts/system/ticktick.sh
DATA=`cat scripts/installer_settings.json`
tickParse "$DATA"

bs_mode=``bs_mode``
echo $bs_mode

tickticklist=(
    "bs_mode"
    "bs_MAGEversion"
    "bs_dbhost"
    "bs_dbname"
    "bs_dbuser"
    "bs_dbpass"
    "bs_url"
    "bs_adminuser"
    "bs_adminpass"
    "bs_adminfname"
    "bs_adminlname"
    "bs_adminemail"
)
for r in $tickticklist
do
    a=$r
    eval tmp = ``${!r}``
    eval $a=$tmp
    echo $a
done
echo $bs_mode
echo $bs_dbhost

#i=0
#for setting in ``$DATA.items()``; do
#    echo $setting
#    ${!DATA[$i]} = $setting
#    echo $setting
#    echo ${!DATA[$i]}
#    $i+=1
#done
#echo $bs_mode
#cd /srv/www/scripts/system/
#. JSON.sh 
#json_parse < ../installer_settings.json




if [[ has_network ]]
then
    apt-get install pv

    cd /srv/www/
    . scripts/main-install.sh

    #check and install wp
    cd /srv/www/
    . scripts/db-install.sh   

    #check and install wp
    cd /srv/www/
    #. scripts/wp-install.sh   

    #check and install magento
    cd /srv/www/
    . scripts/magento/mage-install.sh      

else
	echo -e "\nNo network available, skipping network installations"
fi
# Add any custom domains to the virtual machine's hosts file so that it
# is self aware. Enter domains space delimited as shown with the default.
DOMAINS='local.mage.dev local.wordpress.dev local.wordpress-trunk.dev src.wordpress-develop.dev build.wordpress-develop.dev'
if ! grep -q "$DOMAINS" /etc/hosts
then echo "127.0.0.1 $DOMAINS" >> /etc/hosts
fi


echo "-----------------------------"
if [[ has_network ]]
then
	echo "External network connection established, packages up to date."
    echo
    echo "-------------------------"
    echo
    echo "System creds"
    echo
    echo "-------------------------"
    echo
    echo "Database Host (usually localhost): $bs_bs_dbhost"
    echo
    echo "Database Name: $bs_dbname"
    echo
    echo "Database User: $bs_dbuser"
    echo
    echo "Database Password: $bs_dbpass"
    echo
    echo "Store URL: $bs_url"
    echo
    echo "Admin Username: $bs_adminuser"
    echo
    echo "Admin Password: $bs_adminpass"
    echo
    echo "Admin First Name: $bs_adminfname"
    echo
    echo "Admin Last Name: $bs_adminlname"
    echo
    echo "Admin Email Address: $bs_adminemail"
    echo
    echo "For further setup instructions, visit http://$vvv_ip"
else
	echo "No external network available. Package installation and maintenance skipped."
fi
