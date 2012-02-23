--******************************************************************
--* Output Type
--******************************************************************
CREATE TYPE geom_service AS
(
  id    integer,
  gid   integer,
  class text,
  name  text,
  cost  numeric,
  the_geom geometry
);
--******************************************************************
--* This function finds nearest link to a given node
--*
--* point   : text representation of point in WKT format
--* distance: search for a link within this distance
--* col     : columname, either source or target
--* tbl     : table name
--*
--* return value: source id of link
--******************************************************************

CREATE OR REPLACE FUNCTION find_nearest_link_within_distance(point varchar, 
	distance double precision, col varchar, tbl varchar)
	RETURNS INT AS
$$
DECLARE
    row record;
    x float8;
    y float8;
    
    srid integer;
    
BEGIN

    FOR row IN EXECUTE 'select getsrid(the_geom) as srid from ' || tbl || 
         ' where gid = (select min(gid) from '||tbl||')' LOOP
    END LOOP;
	srid:= row.srid;
    
    -- Getting x and y of the point
    
    FOR row in EXECUTE 'select x(GeometryFromText(''' || point || 
         ''', ' || srid || ')) as x' LOOP
    END LOOP;
	x:=row.x;

    FOR row in EXECUTE 'select y(GeometryFromText(''' || point ||
         ''', ' || srid || ')) as y' LOOP
    END LOOP;
	y:=row.y;

    -- Searching for a link within the distance

    FOR row in EXECUTE 'select '||col||' as source, distance(the_geom, GeometryFromText('''||
                point||''', '||srid||')) as dist from '||tbl||
			    ' where setsrid(''BOX3D('||x-distance||' '||y-distance||
			    ', '||x+distance||' '||y+distance||')''::BOX3D, '||srid||
			    ')&&the_geom order by dist asc limit 1'
    LOOP
    END LOOP;

    IF row.source IS NULL THEN
	    --RAISE EXCEPTION 'Data cannot be matched';
	    RETURN NULL;
    END IF;

    RETURN row.source;

END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;


--******************************************************************
--* This function finds nearest link to a given node
--*
--* x       : x coordinate of the point
--* y       : y coordinate of the point
--* distance: search for a link within this distance
--* col     : columname, either source or target
--* tbl     : table name
--*
--* return value: source id of link
--******************************************************************

CREATE OR REPLACE FUNCTION find_nearest_link_within_distance_xy(
    x double precision, y double precision, 
    distance double precision, col varchar, tbl varchar)
	RETURNS INT AS
$$
DECLARE
    row record;        
    srid integer;    
BEGIN

    FOR row IN EXECUTE 'select getsrid(the_geom) as srid from '||tbl||
        ' where gid = (select min(gid) from '||tbl||')' LOOP
    END LOOP;
	srid:= row.srid;
    
    -- Searching for a link within the distance

    FOR row in EXECUTE 
         'select '||col||' as source, distance(the_geom, GeometryFromText(''POINT('||
         x||' '||y||')'', '||srid||')) as dist from '||tbl||
		 ' where setsrid(''BOX3D('||x-distance||' '||y-distance||', '||
		 x+distance||' '||y+distance||')''::BOX3D, '||srid||
		 ')&&the_geom order by dist asc limit 1'
    LOOP
    END LOOP;

    IF row.source IS NULL THEN
	    --RAISE EXCEPTION 'Data cannot be matched';
	    RETURN NULL;
    END IF;

    RETURN row.source;

END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;

--**********************************************************************
--* A* function for directed graphs.
--* Compute the shortest path using edges table, and return
--*  the result as a set of (gid integer, the_geom geometry) records.
--* Also data clipping added to improve function performance.
--* Cost column name can be specified (last parameter)
--*
--**********************************************************************

CREATE OR REPLACE FUNCTION astar_sp_service(
       varchar,int4, int4, float8, varchar, boolean, boolean) 
       RETURNS SETOF GEOM_SERVICE AS
$$
DECLARE 
    geom_table ALIAS FOR $1;
	sourceid ALIAS FOR $2;
	targetid ALIAS FOR $3;
	delta ALIAS FOR $4;
	cost_column ALIAS FOR $5;
	dir ALIAS FOR $6;
	rc ALIAS FOR $7;

	rec record;
	r record;
    path_result record;
    v_id integer;
    e_id integer;
    geom geom_service;
	
	srid integer;

	source_x float8;
	source_y float8;
	target_x float8;
	target_y float8;
	
	ll_x float8;
	ll_y float8;
	ur_x float8;
	ur_y float8;
	
	query text;

	id integer;
BEGIN
	
	id :=0;
	FOR rec IN EXECUTE
	    'select srid(the_geom) from ' ||
	    quote_ident(geom_table) || ' limit 1'
	LOOP
	END LOOP;
	srid := rec.srid;
	
	FOR rec IN EXECUTE 
            'select x(startpoint(the_geom)) as source_x from ' || 
            quote_ident(geom_table) || ' where source = ' || 
            sourceid || ' or target='||sourceid||' limit 1'
        LOOP
	END LOOP;
	source_x := rec.source_x;
	
	FOR rec IN EXECUTE 
            'select y(startpoint(the_geom)) as source_y from ' || 
            quote_ident(geom_table) || ' where source = ' || 
            sourceid ||  ' or target='||sourceid||' limit 1'
        LOOP
	END LOOP;

	source_y := rec.source_y;

	FOR rec IN EXECUTE 
            'select x(startpoint(the_geom)) as target_x from ' ||
            quote_ident(geom_table) || ' where source = ' || 
            targetid ||  ' or target='||targetid||' limit 1'
        LOOP
	END LOOP;

	target_x := rec.target_x;
	
	FOR rec IN EXECUTE 
            'select y(startpoint(the_geom)) as target_y from ' || 
            quote_ident(geom_table) || ' where source = ' || 
            targetid ||  ' or target='||targetid||' limit 1'
        LOOP
	END LOOP;
	target_y := rec.target_y;


	FOR rec IN EXECUTE 'SELECT CASE WHEN '||source_x||'<'||target_x||
           ' THEN '||source_x||' ELSE '||target_x||
           ' END as ll_x, CASE WHEN '||source_x||'>'||target_x||
           ' THEN '||source_x||' ELSE '||target_x||' END as ur_x'
        LOOP
	END LOOP;

	ll_x := rec.ll_x;
	ur_x := rec.ur_x;

	FOR rec IN EXECUTE 'SELECT CASE WHEN '||source_y||'<'||
            target_y||' THEN '||source_y||' ELSE '||
            target_y||' END as ll_y, CASE WHEN '||
            source_y||'>'||target_y||' THEN '||
            source_y||' ELSE '||target_y||' END as ur_y'
        LOOP
	END LOOP;

	ll_y := rec.ll_y;
	ur_y := rec.ur_y;

	query := 'SELECT gid,class,name,shortest_path_astar.cost,the_geom FROM ' || 
          'shortest_path_astar(''SELECT gid as id, source::integer, ' || 
          'target::integer, '||cost_column||'::double precision as cost, ' || 
          'x1::double precision, y1::double precision, x2::double ' ||
          'precision, y2::double precision ';
	
	IF rc THEN query := query || ' , reverse_cost ';
	END IF;
	  
	query := query || 'FROM ' || quote_ident(geom_table) || 
	      ' where setSRID(''''BOX3D('||
          ll_x-delta||' '||ll_y-delta||','||ur_x+delta||' '||
          ur_y+delta||')''''::BOX3D, ' || srid || ') && the_geom'', ' || 
          quote_literal(sourceid) || ' , ' || 
          quote_literal(targetid) || ' , '''||text(dir)||''', '''||
          text(rc)||''' ),' || 
          quote_ident(geom_table) || ' where edge_id = gid ';
	
	FOR path_result IN EXECUTE query
        LOOP
         geom.gid      := path_result.gid;
         geom.class    := path_result.class;
         geom.name     := path_result.name;
         geom.cost     := path_result.cost;
         geom.the_geom := path_result.the_geom;
		 id            := id+1;
		 geom.id       := id;
                 
         RETURN NEXT geom;

        END LOOP;
    RETURN;
END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT; 


--******************************************************************
--* This function finds the shortest path using Dijkstra
--*
--* startpt : start point in text WKT format
--* endpt   : end   point in text WKT format
--* delta   : clip distance to improve performance
--* tbl     : table name
--* dir     : directed search
--* rc      : has reverse cost
--*
--* return value: source id of link
--******************************************************************

CREATE OR REPLACE FUNCTION find_astar_sp(
    startpt varchar, endpt varchar, 
    delta double precision, tbl varchar,dir boolean,rc boolean)
 RETURNS SETOF GEOM_SERVICE AS
$$
DECLARE
    start_source integer;
    end_source   integer;
BEGIN

    select find_nearest_link_within_distance(startpt,delta,'source',tbl) 
    	into start_source;
    	
    select find_nearest_link_within_distance(endpt,delta,'target',tbl) 
    	into end_source;
    	
    RETURN QUERY select * from astar_sp_service(
       tbl,start_source,end_source,delta,'cost',dir,rc)
    
    RETURN;

END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;

--******************************************************************
--* This function is automates the creating of road profile  
--* views based on the profile id, and the insertion of the view
--* into geometry_column.
--******************************************************************

CREATE OR REPLACE FUNCTION create_profile_view(pid integer,road_table varchar) 
RETURNS integer AS 
$$	
DECLARE
	tabName text;
	rTab    text;
	rSchema text;
	cView   text;
	cAlter  text;
	srid    integer;
	tGeom   text;
	row     record;
BEGIN
	tabName := 'road_profile_' || pid;
	
	rTab    := split_part(road_table,'.',2);
	rSchema := split_part(road_table,'.',1);
	
	IF rTab IS NULL THEN 
	  	rSchema := 'public';
		rTab    := road_table;
	END IF;
	
	FOR row IN EXECUTE 'select srid,f_geometry_column from geometry_columns ' || 
    	'where f_table_name ='''|| rTab ||''' and f_table_schema =''' || 
    	rSchema || '''' LOOP
    END LOOP;
	srid:= row.srid; 
	tGeom:= row.f_geometry_column;
	
	cView := 'create or replace view public.'|| tabName || ' AS ' ||
		'SELECT osm.id AS gid, cls.title AS class, ' || 
		'round(osm.km * 1000::double precision) AS length, '||
		'round(10 * osm.km / cls.speed::double precision * 3600::double precision)/10 AS duration,'||
		'osm.osm_name AS name, CASE WHEN osm.cost < 1000000::double precision '||
		'THEN cls.priority * osm.km / cls.speed::double precision * 3600::double precision ' ||
		'ELSE 1000000::double precision END AS cost,' ||
		'CASE WHEN osm.reverse_cost < 1000000::double precision ' || 
		'THEN cls.priority * osm.km / cls.speed::double precision * 3600::double precision '||
		'ELSE 1000000::double precision '||
		'END AS reverse_cost, osm.source, osm.target, osm.x1, ' || 
		'osm.y1, osm.x2, osm.y2, osm.'||tGeom||' AS the_geom, cls.pid ' ||
		'FROM '|| road_table ||' osm ' ||
		'LEFT JOIN ( SELECT a.priority, a.speed, b.defaultspeed, a.enabled AS '|| 
		'cfg_enabled, b.enabled AS cls_enabled, a.pid, a.cid AS class, b.tag, b.title
           FROM app.configuration a
      LEFT JOIN app.classes b ON b.clazz = a.cid
     WHERE a.pid = '||pid||') cls ON osm.clazz = cls.class
  WHERE cls.cls_enabled AND cls.cfg_enabled';
		
    cAlter := 'ALTER TABLE '||tabName||' OWNER TO postgres';
    
    EXECUTE cView;
    EXECUTE cAlter;
	
    EXECUTE 'delete from geometry_columns where f_table_name=''' ||tabName||
   		''' and f_table_schema =''public'' ';
    
    EXECUTE 'insert into geometry_columns values ('' '',''public'',''' ||
    	tabName||''',''the_geom'',2,'||srid||',''MULTILINESTRING'')';
    
	RETURN 1;
END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;
	
--******************************************************************
--* This function is automates the delete of road profile  
--* views based on the profile id, and the deletion of the view
--* into geometry_column.
--******************************************************************

CREATE OR REPLACE FUNCTION drop_profile_view(pid integer) 
RETURNS integer AS 
$$	
DECLARE
	tabName text;
BEGIN
	tabName := 'road_profile_' || pid;
	
	EXECUTE 'delete from geometry_columns where f_table_name=''' ||tabName||
   		''' and f_table_schema =''public'' ';
    
   	EXECUTE 'drop view public.'|| tabName;
   	
   	RETURN 1;
END;
$$
LANGUAGE 'plpgsql' VOLATILE STRICT;


--******************************************************************
--* This function is the same as driving_distance fucntion of 
--* pgRouting_dd except for the added bbox parmeter used in
--* computing the BBOX that will be independent of cost
--******************************************************************

CREATE OR REPLACE FUNCTION driving_distance_service(
	table_name varchar, x double precision, y double precision,
    distance double precision, cost varchar, reverse_cost varchar, 
    directed boolean, has_reverse_cost boolean,bbox double precision)
       RETURNS SETOF GEOMS AS
$$
DECLARE
     q text;
     srid integer;
     r record;
     geom geoms;
BEGIN
     
     FOR r IN EXECUTE 'SELECT srid FROM geometry_columns WHERE f_table_name = '''||table_name||'''' LOOP
     END LOOP;
     
     srid := r.srid;
     
     -- RAISE NOTICE 'SRID: %', srid;

     q := 'SELECT gid, the_geom FROM points_as_polygon(''SELECT a.vertex_id::integer AS id, b.x1::double precision AS x, b.y1::double precision AS y'||
     ' FROM driving_distance(''''''''SELECT gid AS id,source::integer,target::integer, '||cost||'::double precision AS cost, '||
     reverse_cost||'::double precision as reverse_cost FROM '||
     table_name||' WHERE setsrid(''''''''''''''''BOX3D('||
     x-bbox||' '||y-bbox||', '||x+bbox||' '||y+bbox||')''''''''''''''''::BOX3D, '||srid||') && the_geom  '''''''', (SELECT id FROM find_node_by_nearest_link_within_distance(''''''''POINT('||x||' '||y||')'''''''','||distance/10||','''''''''||table_name||''''''''')),'||
     distance||',true,true) a, (SELECT * FROM '||table_name||' WHERE setsrid(''''''''BOX3D('||
     x-bbox||' '||y-bbox||', '||x+bbox||' '||y+bbox||')''''''''::BOX3D, '||srid||')&&the_geom) b WHERE a.vertex_id = b.source'')';

     -- RAISE NOTICE 'Query: %', q;
     
     FOR r IN EXECUTE q LOOP     
        geom.gid := r.gid;
        geom.the_geom := r.the_geom;
        RETURN NEXT geom;
     END LOOP;
     
     RETURN;

END;
$$

LANGUAGE 'plpgsql' VOLATILE STRICT;
