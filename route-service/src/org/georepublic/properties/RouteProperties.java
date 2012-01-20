package org.georepublic.properties;

import java.util.ResourceBundle;

public class RouteProperties {

	static int srid;
	static double bbox_sp;
	static double bbox_dd;
	static String table;
	static String directed = "true";
	static String reverse_cost = "true";
	
	public static void setProperties(){
		
		ResourceBundle resb = 
				ResourceBundle.getBundle("properties.routing");
		
		RouteProperties.setSrid(Integer.parseInt(resb.getString("GEO.SRID")));		
		RouteProperties.setTable(resb.getString("GEO.TABLE"));
		
		//RouteProperties.setDirected(resb.getString("GEO.DIRECTED"));
		//RouteProperties.setReverse_cost(resb.getString("GEO.REVERSE_COST"));
		
		RouteProperties.setBbox_sp(Double.parseDouble(
				resb.getString("GEO.BBOX_SP")));
		RouteProperties.setBbox_dd(Double.parseDouble(
				resb.getString("GEO.BBOX_DD")));
	}
	
	public static int getSrid() {
		return srid;
	}
	public static void setSrid(int srid) {
		RouteProperties.srid = srid;
	}
	public static String getTable() {
		return table;
	}
	public static void setTable(String table) {
		RouteProperties.table = table;
	}
	public static String getDirected() {
		return directed;
	}
	public static void setDirected(String directed) {
		RouteProperties.directed = directed;
	}
	public static String getReverse_cost() {
		return reverse_cost;
	}
	public static void setReverse_cost(String reverse_cost) {
		RouteProperties.reverse_cost = reverse_cost;
	}

	public static double getBbox_sp() {
		return bbox_sp;
	}

	public static void setBbox_sp(double bbox_sp) {
		RouteProperties.bbox_sp = bbox_sp;
	}

	public static double getBbox_dd() {
		return bbox_dd;
	}

	public static void setBbox_dd(double bbox_dd) {
		RouteProperties.bbox_dd = bbox_dd;
	}
	
}
