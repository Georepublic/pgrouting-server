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
package org.georepublic.services.rest.application.v1_0;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;

import org.georepublic.db.*;
import org.georepublic.properties.*;

import org.apache.wink.json4j.*;

/**
 * @author mbasa
 *
 */

@Path("/v1.0")
public class RouteRestService {
	
	@GET
	public String emptyRequest() {
		return "A Profile Key is needed: Contact your Administrator";
	}
	
	@Path("/{key}/route.{output}")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String shortestPathRequest(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@PathParam("key") String key,
			@PathParam("output") String output,
			@QueryParam("json") String json ) {
		
		String retval = new String();
		DBProc dbProc = new DBProc();

		ProfileProperties prop = dbProc.verifyProfileKey(key);
		
		if( prop == null) {
			return "Profile Key "+key+" was not Verified";
		}

		if( !prop.ispEnabled() ) {
			return "Profile Key "+key+" is not Enabled";
		}
		
		if( !prop.isPgr_sp() ) {
			return "ShortestPath Searches for this Profile is not enabled";
		}
		
		if( !prop.ispPublic() ) {
			if( !checkHostInfo(request.getRemoteHost(),prop.getHosts()) ) {
				if(!checkHostInfo(request.getRemoteAddr(),prop.getHosts()) )
					return "Not authorized to use this Service[ "+
						request.getRemoteAddr() +","+
						request.getRemoteHost() +" ]";
			}
		}
		
		if( output.compareToIgnoreCase("json") != 0 && 
			output.compareToIgnoreCase("geojson") != 0 ) {
			return "Ouput "+output+" not handled";
		}
		
		if( json == null ) {
			return "No JSON Request Parameter";
		}
		
		try {
			JSONObject jo = new JSONObject(json);
			String proj   = jo.getString("projection");
			String source = jo.getJSONArray("points").getString(0);
			String target = jo.getJSONArray("points").getString(1);
			
			int epsg = Integer.parseInt(proj.split(":")[1]);
			
			if(epsg != RouteProperties.getSrid()) {
				source = dbProc.transformPoint(source, epsg);
				target = dbProc.transformPoint(target, epsg);
			}
			
			retval = dbProc.findShortestPath(prop.getId(),
					source, target,prop.isReverse_cost());
		}
		catch( Exception ex ) {
			retval = "Error has occured";
			ex.printStackTrace();
		}
		return retval;
	}

	@Path("/{key}/catch.{output}")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String drivingDistanceRequest(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@PathParam("key") String key,
			@PathParam("output") String output,
			@QueryParam("json") String json ) {
		
		String retval = new String();
		DBProc dbProc = new DBProc();

		ProfileProperties prop = dbProc.verifyProfileKey(key);
		
		if( prop == null) {
			return "Profile Key "+key+" was not Verified";
		}

		if( !prop.ispEnabled() ) {
			return "Profile Key "+key+" is not Enabled";
		}
		
		if( !prop.isPgr_dd() ) {
			return "DrivingDistance Searches for this Profile is not enabled";
		}
		
		if( !prop.ispPublic() ) {
			if( !checkHostInfo(request.getRemoteHost(),prop.getHosts()) ) {
				if(!checkHostInfo(request.getRemoteAddr(),prop.getHosts()) )
					return "Not authorized to use this Service[ "+
						request.getRemoteAddr() +","+
						request.getRemoteHost() +" ]";
			}
		}
		
		if( output.compareToIgnoreCase("json") != 0 && 
			output.compareToIgnoreCase("geojson") != 0 ) {
			return "Ouput "+output+" not handled";
		}
		
		if( json == null ) {
			return "No JSON Request Parameter";
		}
		
		try {
			JSONObject jo = new JSONObject(json);
			String proj   = jo.getString("projection");
			String source = jo.getString("point");
			String mode   = jo.getString("mode");
			double dist   = jo.getDouble("distance");
			
			int epsg = Integer.parseInt(proj.split(":")[1]);
			
			if(epsg != RouteProperties.getSrid()) {
				source = dbProc.transformPoint(source, epsg);
			}
			
			String tmp = source.toUpperCase().replace("POINT(", "");
			String xy[]= tmp.replace(")", "").split(" ");

			retval = dbProc.findDrivingDistance(
					prop.getId(),
					Double.parseDouble(xy[0]), 
					Double.parseDouble(xy[1]), dist, mode,
					prop.isReverse_cost() );
		}
		catch( Exception ex ) {
			retval = "Error has occured";
			ex.printStackTrace();
		}
		return retval;
	}

	//::::::::::::::::::::::::::::::::::
	//:  Admin REST Requests
	//::::::::::::::::::::::::::::::::::
	@Path("/admin/key.json")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String generateKey(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		 
		DBProc dbProc = new DBProc();
		 
		return dbProc.generateKey();
	}
	
	@Path("/admin/classes.json")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String getDefaultClasses(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		 
		DBProc dbProc = new DBProc();
		 
		return dbProc.getDefaultClasses();
	}
	
	@Path("/admin/resources.json")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String getAllResources(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		 
		DBProc dbProc = new DBProc();
		 
		return dbProc.getAllResources();
	}
	
	@Path("/admin/profiles.json")
	@Produces(MediaType.APPLICATION_JSON)
	@GET
	public String getProfiles(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@QueryParam("json") String json ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		 
		DBProc dbProc = new DBProc();
		String retval = new String();
		
		if( json == null || json.length() < 5) {
			retval = dbProc.getProfiles(null);
		}
		else {
			String key = new String();
			try {
				JSONObject jo  = new JSONObject(json);
				JSONArray keys = jo.getJSONArray("key");
				
				if( keys != null ) {
					StringBuffer sb = new StringBuffer();
					sb.append("'").append(keys.getString(0)).append("'");
					
					for(int i=1;i<keys.length();i++)
						sb.append(",'").append(keys.getString(1)).append("'");
					
					key = sb.toString();
				}
				retval = dbProc.getProfiles(key);
			}
			catch(Exception e) {
				e.printStackTrace();
				
				try {
					JSONObject jo     = new JSONObject();
					JSONArray  data   = new JSONArray();
					JSONObject status = new JSONObject();
					
					status.put("code"   , new Integer(404));
					status.put("success", false);
					status.put("message","JSON parse error");
					
					jo.put("data"  , data);
					jo.put("status", status);
					
					retval = jo.toString();
				}
				catch( Exception exception ) {;}
			}
		}		 
		return retval;
	}
	
	@Path("/admin/profiles.json")
	@Produces(MediaType.APPLICATION_JSON)
	@POST
	public String insertProfiles(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@QueryParam("json") String json ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		
		if(json == null || json.length() < 10 ) {
			try {
				JSONObject jo     = new JSONObject();
				JSONObject status = new JSONObject();
				
				status.put("code"   , new Integer(404));
				status.put("success", false);
				status.put("message","JSON parse error");
				
				jo.put("status", status);
				
				return( jo.toString() );
			}
			catch( Exception exception ) {;}
		}
		DBProc dbProc = new DBProc();
		return dbProc.insertProfile(json);
	}
	
	@Path("/admin/profiles.json")
	@Produces(MediaType.APPLICATION_JSON)
	@PUT
	public String updateProfiles(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@QueryParam("json") String json ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		
		if(json == null || json.length() < 10 ) {
			try {
				JSONObject jo     = new JSONObject();
				JSONObject status = new JSONObject();
				
				status.put("code"   , new Integer(404));
				status.put("success", false);
				status.put("message","JSON parse error");
				
				jo.put("status", status);
				
				return( jo.toString() );
			}
			catch( Exception exception ) {;}
		}
		DBProc dbProc = new DBProc();
		return dbProc.insertProfile(json);
	}
	
	@Path("/admin/profiles.json")
	@Produces(MediaType.APPLICATION_JSON)
	@DELETE
	public String deleteProfiles(
			@Context HttpServletRequest request,
			@Context HttpServletResponse response,
			@QueryParam("json") String json ) {
		
		if( !checkHostInfo(request.getRemoteHost(),
				AdminProperties.getHttp_allowed()) ) {
			if(!checkHostInfo(request.getRemoteAddr(),
					AdminProperties.getHttp_allowed()) )
				return "Not authorized to use this Service[ "+
					request.getRemoteAddr() +","+
					request.getRemoteHost() +" ]";
		}
		
		if(json == null || json.length() < 5 ) {
			try {
				JSONObject jo     = new JSONObject();
				JSONObject status = new JSONObject();
				
				status.put("code"   , new Integer(404));
				status.put("success", false);
				status.put("message","JSON parse error");
				
				jo.put("status", status);
				
				return( jo.toString() );
			}
			catch( Exception exception ) {;}
		}
		DBProc dbProc = new DBProc();
		return dbProc.deleteProfiles(json);
	}
	
	//::::::::::::::::::::::::::::::::::::
	//: Admin Utils to Check Remote Host
	//::::::::::::::::::::::::::::::::::::
	
	public boolean checkHostInfo( String host, String lookUp[]) {		
		boolean found = false;
		
		for(int i=0;i<lookUp.length;i++) {
			if(host.compareTo(lookUp[i]) == 0){
				found = true;
				break;
			}
		}		
		
		return found;		
	}
}
