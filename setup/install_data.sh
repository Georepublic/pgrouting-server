#!/bin/bash
# ------------------------------------------------------------------------------
# p g R o u t i n g   S e r v e r
# ------------------------------------------------------------------------------
#
# Copyright (c) 2012, Georepublic. All rights reserved.
# 
# This file is part of pgRouting Server.
#
# pgRouting Server is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# pgRouting Server is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------------
# Setup and configure pgRouting Server Database
# ------------------------------------------------------------------------------
#
# Notes:
# ------
# - Written for Ubuntu 11.10
# - Imports one sample profile with sample configuration
# - (TBD) ...
# 
# ------------------------------------------------------------------------------
# 

printf "\n"
printf "#############################################################################\n"
printf "#    %-70s #\n" ""
printf "#    %-70s #\n" "p g R o u t i n g   S e r v e r"
printf "#    %-70s #\n" "Copyright(c) 2012 Georepublic"
printf "#    %-70s #\n" ""
printf "#    %-70s #\n" "Setup and configure pgRouting Server Database"
printf "#    %-70s #\n" ""
printf "#############################################################################\n"
printf "\n"

# Set default parameter arguments
interactive=0
database="routing"

DIRECTORY=$(cd `dirname $0` && pwd)

function usage
{
	printf "\n"
    printf "Usage: install_database.sh [[-d database ] [-i]] | [-h]\n"
	printf "\n\n"
}

# Read script modifiers
while [ "$1" != "" ]; do
    case $1 in
        -d | --database ) 		shift
        						database=$1
                        		;;
        -i | --interactive ) 	interactive=1
                        		;;
        -h | --help )   		usage
                        		exit
                        		;;
        * )             		usage
                        		exit 1
    esac
    shift
done

# Run interactive mode
if [ "$interactive" = "1" ]; then

    response=
    
	echo -n "Enter database name [$database] > "
    read response
    if [ -n "$response" ]; then
        database=$response
    fi
fi

# Validate database
dbexists=$(psql -U postgres -At -c "select count(*) from pg_database where datname = '$database';");
if [ $dbexists -eq 1 ]; then
	printf "\n"
	printf "Error: Database '$database' already exists!\n"
	printf "Run command 'dropdb -U postgres $database' before to drop the database.\n"
	printf "Exiting program.\n\n"
	exit 1
fi

# ------------------------------------------------------------------------------
# Install databases and tables
# ------------------------------------------------------------------------------

printf "%-25s %-50s\n" "Create database:" $database
sudo -u postgres createdb -E UTF8 -T template_routing $database

# Load tables and functions
printf "%-25s %-50s\n\n" "Load tables and functions ..."
sudo -u postgres psql --quiet -d $database -f $DIRECTORY/../src/sql/routing_service_wrapper.sqlschema_app.sql
sudo -u postgres psql --quiet -d $database -f $DIRECTORY/../src/sql/schema_app.sql
sudo -u postgres psql --quiet -d $database -c "CREATE SCHEMA data"

# Process road network data
printf "%-25s %-50s\n\n" "Setup osm2po ..."
mkdir -p /tmp/osm2po 
cd /tmp/osm2po
#wget -O osm2po.zip http://osm2po.de/download.php?dl=osm2po-4.2.30.zip
unzip -d /tmp/osm2po -o $DIRECTORY/osm2po.zip

printf "%-25s %-50s\n\n" "Download and process OSM data ..."
OSMSRC=http://download.geofabrik.de/osm/europe/germany/sachsen.osm.pbf
java -Xmx640m -jar osm2po-core-4.2.30-signed.jar prefix=buwa tileSize=10x10,0.5 cmd=tjsp $OSMSRC

printf "%-25s %-50s\n\n" "Import OSM road network data ..."
psql -U postgres -d routing -q -f /tmp/osm2po/buwa/buwa_2po_4pgr.sql
psql -U postgres -d routing -c "ALTER TABLE public.buwa_2po_4pgr SET SCHEMA data"
psql -U postgres -d routing -c "UPDATE public.geometry_columns SET f_table_schema='data' WHERE f_table_name='buwa_2po_4pgr'"

# Add sample profile view
printf "%-25s %-50s\n\n" "Add sample profile view ..."
sudo -u postgres psql --quiet -d $database -f $DIRECTORY/../src/sql/view_profile_1.sql

# Show database
printf "%-25s %-50s\n" "Available tables:"
query="SELECT table_schema, table_name FROM information_schema.tables WHERE table_schema IN ('data','app','public') ORDER BY table_schema, table_name;"
sudo -u postgres psql -t -d $database -c "$query"

# VACUUM database
printf "%-25s %-50s\n" "VACUUM database ..."
sudo -u postgres psql --quiet -d $database -c "VACUUM FULL;"

printf "\n"
printf "#############################################################################\n"
printf "\n"
printf "Done!\n\n\n"

