/**
 * 
 */
package org.georepublic.properties;

/**
 * @author mbasa
 *
 */
public class ProfileProperties {

	private String key = null;
	private int    id;
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
	
	
}
