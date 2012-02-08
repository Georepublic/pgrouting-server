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

/**
 * @author mbasa
 *
 */
public class ProfileProperties {

	private String key = null;
	private int    id;
	private int    rid;
	private boolean pPublic = true;
	private boolean pEnabled= true;
	private boolean reverse_cost = true;
	private boolean pgr_sp  = true;
	private boolean pgr_dd  = true;
	private String hosts[]  = null;
	
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public boolean ispPublic() {
		return pPublic;
	}
	public void setpPublic(boolean pPublic) {
		this.pPublic = pPublic;
	}
	public boolean ispEnabled() {
		return pEnabled;
	}
	public void setpEnabled(boolean pEnanled) {
		this.pEnabled = pEnanled;
	}
	public String[] getHosts() {
		return hosts;
	}
	public void setHosts(String[] hosts) {
		this.hosts = hosts;
	}
	public boolean isReverse_cost() {
		return reverse_cost;
	}
	public void setReverse_cost(boolean reverse_cost) {
		this.reverse_cost = reverse_cost;
	}
	public boolean isPgr_sp() {
		return pgr_sp;
	}
	public void setPgr_sp(boolean pgr_sp) {
		this.pgr_sp = pgr_sp;
	}
	public boolean isPgr_dd() {
		return pgr_dd;
	}
	public void setPgr_dd(boolean pgr_dd) {
		this.pgr_dd = pgr_dd;
	}
	public int getRid() {
		return rid;
	}
	public void setRid(int rid) {
		this.rid = rid;
	}
	
	
}
