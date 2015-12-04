#!/bin/bash
#
# A simple script to clone MySQL databases (locally).
#
# Usage:
#   mysql-clone-database.sh user password database newdatabase
# Or if you don't want to write the password on the command line:"
#   mysql-delete-all-tables.sh user database newdatabase
#
# Author: Ali Moreno <http://alimoreno.me> on 2015-12-03.

# Blank line before any output
echo ""


# Checking parameters
if [ $# -lt 3 ] || [ $# -gt 4 ] ; then

    if [ $# -lt 3 ] ; then
        echo "Missing parameters!"
    else
        echo "Too many parameters!"
    fi

    echo ""
    echo "Usage:"
    echo "  mysql-clone-database.sh user password database newdatabase"
    echo ""
    echo "Or if you don't want to write the password on the command line:"
    echo "  mysql-delete-all-tables.sh user database newdatabase"
    echo ""
    exit 1
fi


# Assigning parameters to variables
if [ $# -eq 4 ] ; then
    password=$2
    database=$3
    newdatabase=$4
else
    echo "Please enter the password for the user" $1 "on the database" $2":"
    read password
    database=$2
    newdatabase=$3
fi


# Cloning the database
if ! mysql -u$1 -p$password -e "use \`$newdatabase\`;" ; then
    echo ""
    echo "... Creating the database $newdatabase"
    echo "CREATE DATABASE \`$newdatabase\`;" | mysql -u$1 -p$password
    echo "... Cloning the database $database into $newdatabase"
    mysqldump -u$1 -p$password $database | mysql -u$1 -p$password $newdatabase
    echo ""
else
    echo "The database $newdatabase exist!"
    echo ""
    while true; do
        read -r -p "Do you want to replace it with a clon of "$database" anyway? [y/n]:" ynanswer
        case $ynanswer in
            [Yy]* ) echo ""
                    echo "... Deleting the existing $newdatabase"
                    mysql -u$1 -p$password -e "DROP DATABASE \`$newdatabase\`;"
                    echo "... Creating a new and empty $newdatabase"
                    mysql -u$1 -p$password -e "CREATE DATABASE \`$newdatabase\`;"
                    echo "... Cloning the database $database into $newdatabase"
                    mysqldump -u$1 -p$password $database | mysql -u$1 -p$password $newdatabase
                    echo ""
                    break ;;
            [Nn]* ) echo ""
                    echo "... Aborting"
                    echo ""
                    exit 1 ;;
            * ) echo ""
                echo "Please answer Yes (y) or No (n)."
                echo "" ;;
        esac
    done
fi


# Final message and empty line before return the shell
echo "Database $database cloned on $newdatabase."
echo ""