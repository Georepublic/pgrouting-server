/**
 * 
 */
package org.georepublic.properties;

import java.util.ResourceBundle;

/**
 * @author mbasa
 *
 */
public class AdminProperties {
	private static String http_allowed[] = null;

public static void setProperties(){
		
		ResourceBundle resb = 
				ResourceBundle.getBundle("properties.administration");

		AdminProperties.setHttp_allowed(
				resb.getString("http.allowed").split(","));
	}

	public static String[] getHttp_allowed() {
		return http_allowed;
	}

	public static void setHttp_allowed(String[] http_allowed) {
		AdminProperties.http_allowed = http_allowed;
	}
	
}
