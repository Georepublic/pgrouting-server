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
# Install and configure PostgreSQL and Software
# ------------------------------------------------------------------------------
#
# Installs and configures the following software
# - PostgreSQL Server
# - PostGIS
# - pgRouting
# - Wget, Unzip and OpenJDK
# - PostGIS and pgRouting templates
#
# Notes:
# ------
# - Run with "sudo"
# - Requires "multiverse" repository enabled
# - Written for Ubuntu 11.10
# 
# ------------------------------------------------------------------------------
# 

PROGNAME=$(basename $0)
DIRECTORY=$(cd `dirname $0` && pwd)

function error_exit
{

#	----------------------------------------------------------------
#	Function for exit due to fatal program error
#		Accepts 1 argument:
#			string containing descriptive error message
#	----------------------------------------------------------------

	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
	exit 1
}

printf "\n"
printf "#####################################################################\n"
printf "#    %-70s #\n" ""
printf "#    %-70s #\n" "p g R o u t i n g   S e r v e r"
printf "#    %-70s #\n" "Copyright(c) 2012 Georepublic"
printf "#    %-70s #\n" ""
printf "#    %-70s #\n" "Install and configure PostgreSQL and Software"
printf "#    %-70s #\n" ""
printf "#####################################################################\n"
printf "\n"

# ------------------------------------------------------------------------------
# Completly (!) uninstall PostgreSQL and pgRouting (also removes configuration)
# ------------------------------------------------------------------------------
#apt-get --assume-yes --purge remove postgresql* gaul-devel
#apt-get --assume-yes autoremove

printf "\n -> Adding packages ...\n" 
printf "=====================================================================\n"
apt-get --assume-yes install python-software-properties 
apt-get --assume-yes install wget unzip openjdk-6-jre

# ------------------------------------------------------------------------------
# Add Launchpad repository for pgRouting and Ubuntu-GIS
# ------------------------------------------------------------------------------

printf "\n -> Adding Launchpad repositories ...\n" 
printf "=====================================================================\n"
add-apt-repository ppa:ubuntugis/ubuntugis-unstable
add-apt-repository ppa:georepublic/pgrouting
#add-apt-repository ppa:georepublic/pgrouting-testing
apt-get -qq update

# ------------------------------------------------------------------------------
# Install packages
# ------------------------------------------------------------------------------

printf "\n -> Installing packages ...\n" 
printf "=====================================================================\n"
apt-get --assume-yes install postgresql \
		postgresql-contrib \
		postgresql-doc \
		libpq-dev
		
apt-get --assume-yes install gaul-devel \
		postgresql-9.1-pgrouting \
		postgresql-9.1-pgrouting-dd 
#		postgresql-9.1-pgrouting-tsp 

# ------------------------------------------------------------------------------
# Install Admin Pack (useful for pgAdmin3 for example)
# ------------------------------------------------------------------------------
# Source: http://library.linode.com/databases/postgresql/ubuntu-10.04-lucid

printf "\n -> Installing admin pack ...\n" 
printf "=====================================================================\n"
sudo -u postgres psql template1 < `pg_config --sharedir`/contrib/adminpack.sql

# -------------------------------------------- ----------------------------------
# Change database password for postgres user
# ------------------------------------------------------------------------------

printf "\n -> Changing postgres passphrase to 'postgres' ...\n" 
printf "=====================================================================\n"
sudo -u postgres psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'postgres';"

# ------------------------------------------------------------------------------
# Setup template containing PostGIS and/or pgRouting
# ------------------------------------------------------------------------------

printf "\n -> Installing templates ...\n" 
printf "=====================================================================\n"
bash $DIRECTORY/install_templates.sh

printf "\n"
printf "#####################################################################\n"
printf "\n"
printf "Done!\n\n\n"

