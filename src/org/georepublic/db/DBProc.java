/* 
 * pgRouting Server
 * Copyright 2012, Georepublic. All rights reserved.
 *
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.	
 */
package org.georepublic.db;

import java.sql.*;
import java.util.*;

import org.apache.wink.json4j.*;
import org.georepublic.properties.*;

/**
 * @author mbasa
 *
 */
public class DBProc {

	DBConn dbConn = null;

	
	public DBProc() {		
		this.dbConn = new DBConn();
	}

	/**
	 * @param key
	 * @return
	 * Verifying Key is in the Profile Table
	 */
	public ProfileProperties verifyProfileKey(String key) {
		
		String sql = "select * from app.profiles"+ 
				" where key='"+key+"'";

		ProfileProperties retVal = null;
		
		 
		if( dbConn != null ) {
			try {
				Connection conn = dbConn.getConnection();
				Statement stmt  = conn.createStatement();
				
				ResultSet rs = stmt.executeQuery(sql);
				
				if( rs.next() ) {
					retVal = new ProfileProperties();
					retVal.setKey(key);
					retVal.setId(rs.getInt("id"));
					retVal.setRid(rs.getInt("rid"));
					retVal.setpPublic(rs.getBoolean("public"));
					retVal.setpEnabled(rs.getBoolean("enabled"));
					retVal.setReverse_cost(rs.getBoolean("reverse_cost"));
					retVal.setPgr_dd(rs.getBoolean("pgr_dd"));
					retVal.setPgr_sp(rs.getBoolean("pgr_sp"));

					Statement s = conn.createStatement();
					ResultSet r = s.executeQuery("select host from app.hosts "+
							"where id="+retVal.getId());
					
					List<String> hosts = new ArrayList<String>();
					
					while(r.next())
						hosts.add(r.getString("host"));
					
					String[] h = (String[])hosts.toArray(new String[0]);
					
					retVal.setHosts(h);
					r.close();
					s.close();
				}
				
				rs.close();
				stmt.close();
				conn.close();
			}
			catch( Exception e ) {
				e.printStackTrace();
			}
		}
		return retVal;
	}
	
	
	
	public String transformPoint(String wktPoint,int epsg) {
		String retVal   = null;
		StringBuffer sb = new StringBuffer();
		
		sb.append("select st_astext(st_transform(");
		sb.append("st_geomfromtext('").append(wktPoint).append("',");
		sb.append(epsg).append("),").append(RouteProperties.getSrid());
		sb.append(")) as wkt");
		
		try {
			Connection conn = dbConn.getConnection();
			Statement  stmt = conn.createStatement();
			ResultSet  rs   = stmt.executeQuery(sb.toString());
			
			if( rs.next() ) 
				retVal = rs.getString("wkt");
			
			rs.close();
			stmt.close();
			conn.close();
		}
		catch( Exception e ) {
			e.printStackTrace();
		}
		return retVal;
	}

	public String findDrivingDistance(int id,double x,double y,double distance,
			String mode, boolean is_reverse_cost) {
		
		String rTable = "road_profile_"+id;
		
		StringBuffer sb = new StringBuffer();
		
		JSONObject jobj   = new JSONObject();
		JSONObject jstat  = new JSONObject();
		JSONArray  jfeats = new JSONArray();
		
		int sCode       = 200;
		String sMessage = "Command completed successfully";
		
		String cost = "'cost'";
		String reverse_cost = "'reverse_cost'";
		
		if( mode.compareToIgnoreCase("length") == 0) {
			cost = "length";         //"'st_length(the_geom)'";
			reverse_cost = "length"; //"'st_length(the_geom)'";
		}
		
		sb.append("select st_asgeojson(the_geom) as the_geom ");
		sb.append("from driving_distance_service('");
		sb.append( rTable ).append("',");
		sb.append(x).append(",").append(y).append(",");
		sb.append(distance).append(",");
		sb.append(cost).append(",").append(reverse_cost).append(",");
		sb.append(RouteProperties.getDirected()).append(",");
		sb.append( is_reverse_cost ).append(",");
		sb.append(RouteProperties.getBbox_dd()).append(")");

		if( dbConn != null ) {
			try {				
				Connection conn = dbConn.getConnection();
				Statement stmt  = conn.createStatement();
				
				ResultSet rs = stmt.executeQuery(sb.toString());

				if( rs.next() ) {
					JSONObject jfeat = new JSONObject();
					JSONObject jcrs  = new JSONObject();
					JSONObject jcprop= new JSONObject();
					JSONObject jprop = new JSONObject();
					JSONObject jgeom = new JSONObject(rs.getString("the_geom"));
					
					jcprop.put("code", RouteProperties.getSrid() );
					jcrs.put("type", "EPSG");
					jcrs.put("properties", jcprop);
					
					jprop.put("id", new Integer(1));
					
					jfeat.put("crs", jcrs);
					jfeat.put("geometry", jgeom);
					jfeat.put("type", "Feature");
					jfeat.put("properties", jprop);
					jfeats.add(jfeat);
				}
				
				rs.close();
				stmt.close();
				conn.close();
			}
			catch( Exception ex ) {
				sCode = 400;
				sMessage = "Database Query Error";
				ex.printStackTrace();
			}
		}
		else {
			sCode = 400;
			sMessage = "Database Connection Error";
		}

		try {
			jstat.put("code", new Integer(sCode));
			jstat.put("success", true);
			jstat.put("message",sMessage);

			jobj.put("type", "FeatureCollection");
			jobj.put("features", jfeats);
			jobj.put("status",jstat);			 
		}
		catch( Exception e ) {
			;
		}
		
		return jobj.toString();
	}
	
	/**
	 * @param source
	 * @param target
	 * @return String
	 * Finding Shortest Path based on entered WKT points.
	 * Returns a JSON String that contains the path. 
	 */
	public String findShortestPath(int id,String source,String target,
			boolean reverse_cost ) {
		
		String rTable = "road_profile_"+id;
		
		StringBuffer sb = new StringBuffer();
		
		JSONObject jobj   = new JSONObject();
		JSONObject jstat  = new JSONObject();
		JSONArray  jfeats = new JSONArray();
		
		int sCode       = 200;
		String sMessage = "Command completed successfully";
		
		double len = 0d;
		
		sb.append("select gid,class,name,cost,");
		sb.append("st_length(the_geom::geography) as length,");
		sb.append("st_asgeojson(st_linemerge(the_geom)) as the_geom ");
		sb.append("from find_astar_sp('").append(source).append("','");
		sb.append(target).append("',").append(RouteProperties.getBbox_sp());
		sb.append(",'").append( rTable );
		sb.append("',").append(RouteProperties.getDirected());
		sb.append(",").append( reverse_cost ).append(")");
				
		if( dbConn != null ) {
			try {				
				Connection conn = dbConn.getConnection();
				Statement stmt  = conn.createStatement();
				
				ResultSet rs = stmt.executeQuery(sb.toString());

				while( rs.next() ) {
					JSONObject jfeat = new JSONObject();
					JSONObject jcrs  = new JSONObject();
					JSONObject jcprop= new JSONObject();
					JSONObject jprop = new JSONObject();
					JSONObject jgeom = new JSONObject(rs.getString("the_geom"));
					
					jcprop.put("code", RouteProperties.getSrid() );
					jcrs.put("type", "EPSG");
					jcrs.put("properties", jcprop);
					
					jprop.put("id", rs.getDouble("gid"));
					jprop.put("length", rs.getDouble("length"));
					jprop.put("class", rs.getString("class"));
					jprop.put("name", rs.getString("name"));
					jprop.put("cost", rs.getDouble("cost"));
					
					jfeat.put("crs", jcrs);
					jfeat.put("geometry", jgeom);
					jfeat.put("type", "Feature");
					jfeat.put("properties", jprop);
					jfeats.add(jfeat);

					len += rs.getBigDecimal("length").doubleValue();
				}

				rs.close();
				stmt.close();
				conn.close();
			}
			catch(Exception ex) {
				sCode = 400;
				sMessage = "Database Query Error";
				ex.printStackTrace();
			}
		}
		else {
			sCode = 400;
			sMessage = "Database Connection Error";
		}

		try {
			jstat.put("code", new Integer(sCode));
			jstat.put("success", true);
			jstat.put("message",sMessage);

			jobj.put("type", "FeatureCollection");
			jobj.put("features", jfeats);
			jobj.put("total", new Double(len));
			jobj.put("status",jstat);			 
		}
		catch( Exception e ) {
			;
		}
		
		return jobj.toString();
	}

	public String generateKey() {
		
		String sql  = "select md5(text(now())) as key";
		String rval = new String();
		
		JSONObject jo     = new JSONObject();
		JSONObject data   = new JSONObject();
		JSONObject status = new JSONObject();
		
		try {
			Connection conn = dbConn.getConnection();
			Statement stmt  = conn.createStatement();
			ResultSet rs    = stmt.executeQuery(sql);
			
			if( rs.next() ) {
				
				data.put("key", rs.getString("key"));
				
				status.put("code"   , new Integer(201));
				status.put("success", true);
				status.put("message","completed successfully");
				
				jo.put("data"  , data);
				jo.put("status", status);
				
				rval = jo.toString();
			}
			else {
				data.put("key", "");
				
				status.put("code"   , new Integer(404));
				status.put("success", false);
				status.put("message","error occured");
				
				jo.put("data"  , data);
				jo.put("status", status);
				
				rval = jo.toString();				
			}
			rs.close();
			stmt.close();
			conn.close();
		}
		catch(Exception ex) {
			ex.printStackTrace();
		}
		
		return rval;
	}
	
	public String getDefaultClasses() {
		
		String sql = "select id,clazz,tag,title,defaultspeed from "+
				"app.classes order by id;";
		String rval = new String();
		
		JSONObject jo     = new JSONObject();
		JSONArray  data   = new JSONArray();
		JSONObject status = new JSONObject();
		
		try {
			DBConn dbConn = new DBConn();
			Connection conn = dbConn.getConnection();
			Statement stmt  = conn.createStatement();
			ResultSet rs    = stmt.executeQuery(sql);
			
			while( rs.next() ) {
				JSONObject rec = new JSONObject();
				rec.put("id", rs.getInt("id"));
				rec.put("clazz", rs.getInt("clazz"));
				rec.put("tag",rs.getString("tag"));
				rec.put("title", rs.getString("title"));
				rec.put("defaultspeed",rs.getInt("defaultspeed"));
				
				data.add(rec);
			}
			
			status.put("code"   , new Integer(201));
			status.put("success", true);
			status.put("message","completed successfully");
			
			jo.put("data"  , data);
			jo.put("status", status);
			
			rval = jo.toString();
		}
		catch( Exception ex ) {
			ex.printStackTrace();
		}
		
		return rval;
	}
	
	public String getAllResources() {
		
		String sql  = "select id,title,description,resource,enabled "+
				      "from app.resources order by id";
		String rval = new String();
		
		JSONObject jo     = new JSONObject();
		JSONArray  data   = new JSONArray();
		JSONObject status = new JSONObject();
		
		try {
			DBConn dbConn = new DBConn();
			Connection conn = dbConn.getConnection();
			Statement stmt  = conn.createStatement();
			ResultSet rs    = stmt.executeQuery(sql);
			
			while( rs.next() ) {
				JSONObject rec = new JSONObject();
				rec.put("id"         , rs.getInt("id"));
				rec.put("title"      , rs.getString("title"));
				rec.put("description", rs.getString("description"));
				rec.put("resource"   , rs.getString("resource"));
				rec.put("enabled"    , rs.getBoolean("enabled"));
				
				data.add(rec);
			}
			
			status.put("code"   , new Integer(201));
			status.put("success", true);
			status.put("message","completed successfully");
			
			jo.put("data"  , data);
			jo.put("status", status);
			
			rval = jo.toString();
		}
		catch( Exception ex ) {
			ex.printStackTrace();
		}
		
		return rval;
	}
	
	public String getProfiles( String mKey ) {
		
		StringBuffer sb = new StringBuffer();
		sb.append("select id,key,title,description,reverse_cost,");
		sb.append("public,enabled,pgr_sp,pgr_dd,rid from app.profiles ");
		
		if( mKey != null ) {
			sb.append("where key in (").append(mKey).append(") ");			
		}
		
		sb.append("order by id");
		
		String sql  = sb.toString();
		String rval = new String();

		JSONObject jo     = new JSONObject();
		JSONArray  data   = new JSONArray();
		JSONObject status = new JSONObject();
		
		try {
			DBConn dbConn = new DBConn();
			Connection conn = dbConn.getConnection();
			Statement stmt  = conn.createStatement();
			ResultSet rs    = stmt.executeQuery(sql);
			
			while( rs.next() ) {
				JSONObject rec = new JSONObject();
				JSONObject profile = new JSONObject();
				JSONArray  config  = new JSONArray();
				JSONArray  hosts   = new JSONArray();
				
				profile.put("id"          , rs.getInt("id"));
				profile.put("rid"         , rs.getInt("rid"));
				profile.put("key"         , rs.getString("key"));
				profile.put("title"       , rs.getString("title"));
				profile.put("description" , rs.getString("description"));
				profile.put("reverse_cost", rs.getBoolean("reverse_cost"));
				profile.put("public"      , rs.getBoolean("public"));
				profile.put("enabled"     , rs.getBoolean("enabled"));
				profile.put("pgr_sp"      , rs.getBoolean("pgr_sp"));
				profile.put("pgr_dd"      , rs.getBoolean("pgr_dd"));
				
				sql = "select cid,speed,enabled,priority "+
				    "from app.configuration "+
					"where pid="+ rs.getInt("id"); 
				Statement stmt2 = conn.createStatement();
				ResultSet rs2   = stmt2.executeQuery(sql);
				
				while(rs2.next()) {
					JSONObject c = new JSONObject();
					c.put("cid",     rs2.getInt("cid"));
					c.put("speed",   rs2.getInt("speed"));
					c.put("enabled", rs2.getBoolean("enabled"));
					c.put("priority",rs2.getDouble("priority"));
					
					config.add(c);
				}
				
				sql = "select host from app.hosts where id="+rs.getInt("id");
				Statement stmt3 = conn.createStatement();
				ResultSet rs3   = stmt3.executeQuery(sql);
				
				while( rs3.next() ) {
					hosts.add(rs3.getString("host"));
				}
								
				rec.put("hosts", hosts);
				rec.put("configuration", config);
				rec.put("profile", profile);
				
				data.add(rec);
				
				rs2.close();
				rs3.close();
				stmt2.close();
				stmt3.close();
			}
			
			status.put("code"   , new Integer(201));
			status.put("success", true);
			status.put("message","completed successfully");
			
			jo.put("data"  , data);
			jo.put("status", status);
			
			rval = jo.toString();
			
			rs.close();
			stmt.close();
			conn.close();
		}
		catch( Exception ex ) {
			ex.printStackTrace();
			
			try {
				status.put("code"   , new Integer(404));
				status.put("success", false);
				status.put("message","database access error");
				
				jo.put("data"  , data);
				jo.put("status", status);
				
				rval = jo.toString();
			}
			catch( Exception exception ) {;}
		}
		
		return rval;
	}
	
	public void deleteProfilesByKey( String key ) {
	
		String json = "{\"key\":[\""+key+"\"]}";
		this.deleteProfiles(json);
		
	}
	
	public String deleteProfiles(String inJson) {
		String retval = new String();
		boolean retbool;
		int retcode;
		
		try {
			JSONObject jo  = new JSONObject(inJson);
			JSONArray keys = jo.getJSONArray("key");
			
			Connection conn = dbConn.getConnection();
			PreparedStatement pstmt = conn.prepareStatement(
					"delete from app.profiles where key = ?");
			PreparedStatement pstmt2 = conn.prepareStatement(
					"delete from app.configuration where pid = ?");
			PreparedStatement pstmt3 = conn.prepareStatement(
					"select drop_profile_view(?)");
			PreparedStatement keyStmt = conn.prepareStatement(
					"select id from app.profiles where key = ?");
			
			for(int i=0;i<keys.size();i++){
				
				keyStmt.setString(1,keys.getString(i));
				ResultSet rs = keyStmt.executeQuery();
				
				if( rs.next() ) {
					int id = rs.getInt("id");
					pstmt2.setInt(1, id);
					pstmt2.execute();
					pstmt3.setInt(1, id);
					pstmt3.execute();
				}
				pstmt.setString(1, keys.getString(i));
				pstmt.execute();
				
				rs.close();
			}
			
			retval = "Sucessfully completed";
			retcode= 201;
			retbool= true;
			
			pstmt.close();
			conn.close();
		}
		catch( JSONException jex ) {
			retval = "JSON Exception Error";
			retcode= 404;
			retbool= false;
			jex.printStackTrace();
		}
		catch( Exception e ) {
			retval = "Database Exception Error";
			retcode= 404;
			retbool= false;
			e.printStackTrace();
		}
		
		JSONObject robj = new JSONObject();
		JSONObject rstat= new JSONObject();
		try {
			rstat.put("code"   , retcode);
			rstat.put("success", retbool );
			rstat.put("message", retval);
			
			robj.put("status", rstat);
		}
		catch(Exception exception) {;}
		
		return robj.toString();
	}
	
	public String insertProfile(String inJson) {
		String retval = new String();
		boolean retbool;
		int retcode;
		
		try {
			JSONObject inJo  = new JSONObject(inJson);
			JSONObject inPr  = inJo.getJSONObject("profiles");
			JSONArray inConf = inJo.getJSONArray("configuration");
			JSONArray inHost = inJo.getJSONArray("hosts");
			
			Connection conn = dbConn.getConnection();
			
			String key = inPr.getString("key");
			
			if( key == null || key.length() < 2) { 
				JSONObject kjo = new JSONObject(this.generateKey());
				key = kjo.getJSONObject("data").getString("key");
			}
			else {
				this.deleteProfilesByKey(key);
			}
			
			StringBuffer sb = new StringBuffer();
			sb.append("insert into app.profiles ");
			sb.append("(id,key,title,description,reverse_cost,rid,public,");
			sb.append("enabled,pgr_sp,pgr_dd) values ");
			sb.append("(?,?,?,?,?,?,?,?,?,?)");
			
			int recId = 1;
			
			Statement stmt  = conn.createStatement();
			ResultSet rs    = stmt.executeQuery(
					"select nextval('app.profiles_id_seq') as id");
			
			while( rs.next() )
				recId = rs.getInt("id");
			
			PreparedStatement pstmt = conn.prepareStatement(sb.toString());
			pstmt.setInt    (1, recId);
			pstmt.setString (2, key);
			pstmt.setString (3, inPr.getString("title"));
			pstmt.setString (4, inPr.getString("description"));
			pstmt.setBoolean(5, inPr.getBoolean("reverse_cost"));
			pstmt.setInt    (6, inPr.getInt("rid"));
			pstmt.setBoolean(7, inPr.getBoolean("public"));
			pstmt.setBoolean(8, inPr.getBoolean("enabled"));
			pstmt.setBoolean(9, inPr.getBoolean("pgr_sp"));
			pstmt.setBoolean(10,inPr.getBoolean("pgr_dd"));
			pstmt.execute();
			
			PreparedStatement pstmt2 = conn.prepareStatement(
					"insert into app.hosts(id,host) values (?,?)");
			
			for(int j=0;j<inHost.size();j++) {
				pstmt2.setInt(1, recId);
				pstmt2.setString(2, inHost.getString(j));
				pstmt2.execute();
			}
			
			PreparedStatement pstmt3 = conn.prepareStatement(
					"insert into app.configuration "+
					"(pid,cid,speed,enabled,priority) "+
					"values (?,?,?,?,?)" );
			
			for(int k=0;k<inConf.size();k++) {
				JSONObject conf = inConf.getJSONObject(k);
				pstmt3.setInt(1, recId);
				pstmt3.setInt(2, conf.getInt("cid"));
				pstmt3.setInt(3, conf.getInt("speed"));
				pstmt3.setBoolean(4, conf.getBoolean("enabled"));
				pstmt3.setDouble( 5, conf.getDouble("priority"));
				pstmt3.execute();
			}
			
			PreparedStatement pstmt4 = conn.prepareStatement(
					"select create_profile_view(?,?)" );
			pstmt4.setInt   (1, recId);
			pstmt4.setString(2, RouteProperties.getTable());
			pstmt4.execute();
			
			retval = "Sucessfully completed";
			retcode= 201;
			retbool= true;
			
			rs.close();
			stmt.close();
			pstmt.close();
			pstmt2.close();
			pstmt3.close();
			pstmt4.close();
			conn.close();
		}
		catch( JSONException je ) {
			retval = "JSON Exception Error";
			retcode= 404;
			retbool= false;
			je.printStackTrace();
		}
		catch( Exception e ) {
			retval = "Database Exception Error";
			retcode= 404;
			retbool= false;
			e.printStackTrace();
		}
		
		JSONObject robj = new JSONObject();
		JSONObject rstat= new JSONObject();
		try {
			rstat.put("code"   , retcode);
			rstat.put("success", retbool );
			rstat.put("message", retval);
			
			robj.put("status", rstat);
		}
		catch(Exception exception) {;}
		
		return robj.toString();
	}
}
