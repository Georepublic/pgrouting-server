-- View: road_profile_1

-- DROP VIEW road_profile_1;

CREATE OR REPLACE VIEW road_profile_1 AS 
 SELECT osm.id AS gid, cls.title AS class, round(osm.km * 1000::double precision) AS length, osm.osm_name AS name,
        round(10 * osm.km / cls.speed::double precision * 3600::double precision)/10 AS duration, 
        CASE
            WHEN osm.cost < 1000000::double precision THEN cls.priority * osm.km / cls.speed::double precision * 3600::double precision
            ELSE 1000000::double precision
        END AS cost, 
        CASE
            WHEN osm.reverse_cost < 1000000::double precision THEN cls.priority * osm.km / cls.speed::double precision * 3600::double precision
            ELSE 1000000::double precision
        END AS reverse_cost, osm.source, osm.target, osm.x1, osm.y1, osm.x2, osm.y2, osm.geom_way AS the_geom, cls.pid
   FROM data.buwa_2po_4pgr osm
   LEFT JOIN ( SELECT a.priority, a.speed, b.defaultspeed, a.enabled AS cfg_enabled, b.enabled AS cls_enabled, a.pid, a.cid AS class, b.tag, b.title
           FROM app.configuration a
      LEFT JOIN app.classes b ON b.clazz = a.cid
     WHERE a.pid = 1) cls ON osm.clazz = cls.class
  WHERE cls.cls_enabled AND cls.cfg_enabled LIMIT 3;

ALTER TABLE road_profile_1 OWNER TO postgres;

