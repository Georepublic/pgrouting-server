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
