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
package org.georepublic.services.rest.application;

import javax.ws.rs.core.Application;

import org.georepublic.properties.*;
import org.georepublic.services.rest.application.v1_0.*;

import java.util.*;

public class RouteApplication extends Application {

	@Override
	public Set<Class<?>> getClasses() {
		Set<Class<?>> classes = new HashSet<Class<?>>();
		classes.add(RouteRestService.class);

		//::::::::::::::::::::::::::::::::
		//:: Setting the Property classes
		//::::::::::::::::::::::::::::::::
		DBProperties.setProperties();
		RouteProperties.setProperties();
		AdminProperties.setProperties();
		
		return classes;
	}
}
