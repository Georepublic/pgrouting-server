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
package org.georepublic.properties;

import java.util.ResourceBundle;

/**
 * @author mbasa
 *
 */
public class AdminProperties {
	private static String http_allowed[] = null;
	private static String http_admin_url = null;

public static void setProperties(){
		
		ResourceBundle resb = 
				ResourceBundle.getBundle("properties.administration");

		AdminProperties.setHttp_allowed(
				resb.getString("http.allowed").split(","));
		
		AdminProperties.setHttp_admin_url(
				resb.getString("http.admin_url") );
	}

	public static String[] getHttp_allowed() {
		return http_allowed;
	}

	public static void setHttp_allowed(String[] http_allowed) {
		AdminProperties.http_allowed = http_allowed;
	}

	public static String getHttp_admin_url() {
		return http_admin_url;
	}

	public static void setHttp_admin_url(String http_admin_url) {
		AdminProperties.http_admin_url = http_admin_url;
	}
	
}
