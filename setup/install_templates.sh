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
# Setup template containing PostGIS and/or pgRouting
# ------------------------------------------------------------------------------
#
# To create a GIS database as non-superuser run: 
#
# 	"createdb -h hostname -W -T template_postgis mydb
#
# Source: http://geospatial.nomad-labs.com/2006/12/24/postgis-template-database/
#
# Notes:
# ------
# - Requires "libpq-dev" package
# - Written for Ubuntu 11.10
# 
# ------------------------------------------------------------------------------
# 

if [ -e `pg_config --sharedir` ]
then
	echo "PostGIS installed in" `pg_config --sharedir`
	POSTGIS_SQL_PATH=`pg_config --sharedir`/contrib
else
  # Fallback for PostgreSQL 9.1
	POSTGIS_SQL_PATH=/usr/share/postgresql/9.1/contrib
	echo "PostGIS path set as $POSTGIS_SQL_PATH"
fi

ROUTING_SQL_PATH=/usr/share/postlbs

# Create "template_postgis"
# -------------------------
if  sudo -u postgres psql --list | grep -q template_postgis ;
then
	echo "PostGIS template already exists!"
else
	echo "Create PostGIS template ..."
	sudo -u postgres createdb -E UTF8 -T template0 template_postgis

	sudo -u postgres psql --quiet -d template_postgis -f $POSTGIS_SQL_PATH/postgis-1.5/postgis.sql
	sudo -u postgres psql --quiet -d template_postgis -f $POSTGIS_SQL_PATH/postgis-1.5/spatial_ref_sys.sql
	sudo -u postgres psql --quiet -d template_postgis -f $POSTGIS_SQL_PATH/postgis_comments.sql

	sudo -u postgres psql --quiet -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
	sudo -u postgres psql --quiet -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
	sudo -u postgres psql --quiet -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

	sudo -u postgres psql --quiet -d template_postgis -c "VACUUM FULL;"
	sudo -u postgres psql --quiet -d template_postgis -c "VACUUM FREEZE;"

	sudo -u postgres psql --quiet -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';"
	sudo -u postgres psql --quiet -d postgres -c "UPDATE pg_database SET datallowconn='false' WHERE datname='template_postgis';"
	echo "... template_postgis created."
fi

# Create "template_routing"
# -------------------------
if  sudo -u postgres psql --list | grep -q template_routing ;
then
	echo "pgRouting template already exists!"
else
	echo "Create pgRouting template ..."
	sudo -u postgres createdb -E UTF8 -T template_postgis template_routing

	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_core.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_core_wrappers.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_topology.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_tsp.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_tsp_wrappers.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_dd.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/routing_dd_wrappers.sql
	sudo -u postgres psql --quiet -d template_routing -f $ROUTING_SQL_PATH/matching.sql

	sudo -u postgres psql --quiet -d template_routing -c "VACUUM FULL;"
	sudo -u postgres psql --quiet -d template_routing -c "VACUUM FREEZE;"

	sudo -u postgres psql --quiet -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_routing';"
	sudo -u postgres psql --quiet -d postgres -c "UPDATE pg_database SET datallowconn='false' WHERE datname='template_routing';"
	echo "... template_routing created."
fi


