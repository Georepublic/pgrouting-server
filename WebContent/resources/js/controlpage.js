function controlService() {	
	this.profileUrl  = "/routing-service/web/v1.0/admin/profiles.json";
	this.resourceUrl = "/routing-service/web/v1.0/admin/resources.json";
	this.keyUrl      = "/routing-service/web/v1.0/admin/key.json";
	this.profileJSON = null;
};

controlService.prototype.resourceAjaxReq = function() {
	var _this = this;
	
	this.clearParams();
	
	$.ajax({
		   type       : "get",
		   url        : this.resourceUrl,
		   beforeSend : function(){ $("#loadingDialog").dialog("open");  },
		   complete   : function(){ $("#loadingDialog").dialog("close"); 
		   							_this.profileAjaxReq();  },
		   success    : function(data){ _this.setResources(data); 
		   	                            /*_this.profileAjaxReq();*/    },
		   error      : function(){ $("#loadingDialog").dialog("close");
		                            alert("json resource error:"); }
	   });	
};

controlService.prototype.keyAjaxReq = function() {

	$.ajax({
		   type       : "get",
		   url        : this.keyUrl,
		   success    : function(d){ $("#profile_key").val(d.data.key); },
		   beforeSend : function(){ $("#loader").show();  },
		   complete   : function(){ $("#loader").hide();  },
		   error      : function(){ $("#loader").hide();
		                            alert("key generation error:"); }
	   });
};

controlService.prototype.resetToDefault = function(_this) {
	//::::::::::::::::::::::::
	//: Resetting to Default
	//::::::::::::::::::::::::
	$("#generateBtn").attr("disabled","disabled");
	$("#deleteBtn").removeAttr("disabled");
	$("#refreshBtn").val("Refresh");
	
	$("#keyDiv").html('<select id="title" style="width:200px;"></select>');
	$("#title").change(function() {
		_this.setProfileVals($(this).attr('value'));
	});
	
};

controlService.prototype.profileAjaxReq = function() {
	
	var _this = this;
	
	this.resetToDefault(_this);
	
	//::::::::::::::::::::::::
	//: Actual Ajax Request
	//::::::::::::::::::::::::
	$.ajax({
		   type       : "get",
		   url        : this.profileUrl,
		   success    : function(data){ _this.setProfiles(data); },
		   beforeSend : function(){ $("#loadingDialog").dialog("open");  },
		   complete   : function(){ $("#loadingDialog").dialog("close"); },
		   error      : function(){ $("#loadingDialog").dialog("close");
		                            alert("json profile error:"); }
	   });	
};

controlService.prototype.setResources = function(json) {

	var opts="";
	
	if( json != null && json.status.success != false ) {
		for(var i=0; i<json.data.length;i++ ){
			if( json.data[i].enabled == true ) {
				opts+="<option value='"+json.data[i].id+"'>"+
				      json.data[i].title+"</option>";
			}
		}

		$("#resource").html("").html(opts);
	}
	else {
		alert( "emtpy JSON Resource Response" );
	}
};

controlService.prototype.setProfiles = function(json) {

	this.profileJSON = json;
	this.clearParams();

	var opts="";
	var resourceId = $("#resource").val();
	
	if( json != null && json.status.success != false ) {
		var first = true;
		
		for(var i=0; i<json.data.length;i++ ){
			if( json.data[i].profile.rid == resourceId ) {
				opts+="<option value='"+json.data[i].profile.title+"'>"+
				       json.data[i].profile.title+"</option>";
				if( first == true ) {
					first = false;
					this.setProfileVals(json.data[i].profile.title);
				}
			}
		}

		$("#title").html("").html(opts);
	}
	else {
		alert( "emtpy JSON Response" );
	}
};

controlService.prototype.clearParams = function() {
	//$("#title").val("");
	$("#profile_key").val("");
	$("#description").val("");
	$("#hosts").val("");
	$("#shortest_path").attr('checked',false);
	$("#driving_dist" ).attr('checked',false);	
	$("#restricted"   ).attr('checked',false);	
	$("#rev_cost"     ).attr('checked',false);	
	
	$("#motorway_ck").attr('checked',false);
	$("#motorway_sp").val("0");
	$("#motorway_sl").slider({value:1});
	
	$("#motorwaylnk_ck").attr('checked',false);
	$("#motorwaylnk_sp").val("0");
	$("#motorwaylnk_sl").slider({value:1});
	
	$("#trunkway_ck").attr('checked',false);
	$("#trunkway_sp").val("0");
	$("#trunkway_sl").slider({value:1});
	
	$("#trunkwaylnk_ck").attr('checked',false);
	$("#trunkwaylnk_sp").val("0");
	$("#trunkwaylnk_sl").val("0");
	
	$("#primary_ck").attr('checked',false);
	$("#primary_sp").val("0");
	$("#primary_sl").slider({value:1});
	
	$("#primarylnk_ck").attr('checked',false);
	$("#primarylnk_sp").val("0");
	$("#primarylnk_sl").slider({value:1});
	
	$("#secondary_ck").attr('checked',false);
	$("#secondary_sp").val("0");
	$("#secondary_sl").slider({value:1});
	
	$("#secondarylnk_ck").attr('checked',false);
	$("#secondarylnk_sp").val("0");
	$("#secondarylnk_sl").slider({value:1});
	
	$("#tertiary_ck").attr('checked',false);
	$("#tertiary_sp").val("0");
	$("#tertiary_sl").slider({value:1});
	
	$("#residential_ck").attr('checked',false);
	$("#residential_sp").val("0");
	$("#residential_sl").slider({value:1});
	
	$("#unclassified_ck").attr('checked',false);
	$("#unclassified_sp").val("0");
	$("#unclassified_sl").slider({value:1});
	
	$("#pedestrian_ck").attr('checked',false);
	$("#pedestrian_sp").val("0");
	$("#pedestrian_sl").slider({value:1});
	
	$("#cycleway_ck").attr('checked',false);
	$("#cycleway_sp").val("0");
	$("#cycleway_sl").slider({value:1});
};

controlService.prototype.setProfileVals = function( id ) {
	
	var json = this.profileJSON;
	this.clearParams();
	
	if( json != null && id != "-99" ) {
		for(var i=0;i<json.data.length;i++) {
			
			if( id == json.data[i].profile.title ) {				
				$("#profile_key").val(json.data[i].profile.key);
				$("#description").val(json.data[i].profile.description);
				$("#shortest_path").attr('checked',json.data[i].profile.pgr_sp);
				$("#driving_dist" ).attr('checked',json.data[i].profile.pgr_dd);
				$("#rev_cost" ).attr('checked',json.data[i].profile.reverse_cost);
				
				if(json.data[i].profile.public == true)
					$("#restricted").attr('checked',false);
				else
					$("#restricted").attr('checked',true);
				
				var config = json.data[i].configuration;
				
				for(var j=0;j<config.length;j++) {
					switch(config[j].cid) {
					case 11: 
						$("#motorway_ck").attr('checked',config[j].enabled);
						$("#motorway_sp").val(config[j].speed);
						$("#motorway_sl").slider({value:config[j].priority});
						break;
					case 12: 
						$("#motorwaylnk_ck").attr('checked',config[j].enabled);
						$("#motorwaylnk_sp").val(config[j].speed);
						$("#motorwaylnk_sl").slider({value:config[j].priority});
						break;
					case 13: 
						$("#trunkway_ck").attr('checked',config[j].enabled);
						$("#trunkway_sp").val(config[j].speed);
						$("#trunkway_sl").slider({value:config[j].priority});
						break;
					case 14: 
						$("#trunkwaylnk_ck").attr('checked',config[j].enabled);
						$("#trunkwaylnk_sp").val(config[j].speed);
						$("#trunkwaylnk_sl").slider({value:config[j].priority});
						break;
					case 15: 
						$("#primary_ck").attr('checked',config[j].enabled);
						$("#primary_sp").val(config[j].speed);
						$("#primary_sl").slider({value:config[j].priority});
						break;
					case 16: 
						$("#primarylnk_ck").attr('checked',config[j].enabled);
						$("#primarylnk_sp").val(config[j].speed);
						$("#primarylnk_sl").slider({value:config[j].priority});
						break;
					case 21: 
						$("#secondary_ck").attr('checked',config[j].enabled);
						$("#secondary_sp").val(config[j].speed);
						$("#secondary_sl").slider({value:config[j].priority});
						break;
					case 22: 
						$("#secondarylnk_ck").attr('checked',config[j].enabled);
						$("#secondarylnk_sp").val(config[j].speed);
						$("#secondarylnk_sl").slider({value:config[j].priority});
						break;
					case 31: 
						$("#tertiary_ck").attr('checked',config[j].enabled);
						$("#tertiary_sp").val(config[j].speed);
						$("#tertiary_sl").slider({value:config[j].priority});
						break;
					case 32: 
						$("#residential_ck").attr('checked',config[j].enabled);
						$("#residential_sp").val(config[j].speed);
						$("#residential_sl").slider({value:config[j].priority});
						break;
					case 42: 
						$("#unclassified_ck").attr('checked',config[j].enabled);
						$("#unclassified_sp").val(config[j].speed);
						$("#unclassified_sl").slider({value:config[j].priority});
						break;
					case 62: 
						$("#pedestrian_ck").attr('checked',config[j].enabled);
						$("#pedestrian_sp").val(config[j].speed);
						$("#pedestrian_sl").slider({value:config[j].priority});
						break;
					case 81: 
						$("#cycleway_ck").attr('checked',config[j].enabled);
						$("#cycleway_sp").val(config[j].speed);
						$("#cycleway_sl").slider({value:config[j].priority});
						break;
					}
				}
				
				var hosts = json.data[i].hosts;
				var h = "";
				
				for(var k=0;k<hosts.length;k++) {
					h += hosts[k]+'\n';
				}
				$("#hosts").val(h);
				
				break;
			}
		}		
	}
};

controlService.prototype.saveParams = function() {

	var key = "";
	var resourceId = $("#resource").val();
	var mPublic    = true;
	
	if( $("#profile_key").val() != "-99" )
		key = $("#profile_key").val();
	
	if( $("#restricted").prop("checked") == true )
		mPublic = false;
	
	var opts = '{ "profiles": {';	 
	opts+='"key":"'+key+'",';
	opts+='"title":"'+$("#title").val()+'",';
	opts+='"description":"'+$("#description").val()+'",';
	opts+='"reverse_cost":"'+$("#rev_cost").prop("checked")+'",';
	opts+='"public":"'+mPublic+'",';
	opts+='"pgr_dd":"'+$("#driving_dist").prop("checked")+'",';
	opts+='"pgr_sp":"'+$("#shortest_path").prop("checked")+'",';
	opts+='"enabled":"true",';
	opts+='"id": 0,';
	opts+='"rid":'+resourceId+'},"configuration":[';
	
	opts+='{"cid":11,"priority":'+ $("#motorway_sl").slider("value") +
		',"speed":'+$("#motorway_sp").val()+
		',"enabled":"'+$("#motorway_ck").prop("checked")+'"},';
	
	opts+='{"cid":12,"priority":'+ $("#motorwaylnk_sl").slider("value") +
		',"speed":'+$("#motorwaylnk_sp").val()+
		',"enabled":"'+$("#motorwaylnk_ck").prop("checked")+'"},';
	
	opts+='{"cid":13,"priority":'+ $("#trunkway_sl").slider("value") +
		',"speed":'+$("#trunkway_sp").val()+
		',"enabled":"'+$("#trunkway_ck").prop("checked")+'"},';
	
	opts+='{"cid":14,"priority":'+ $("#trunkwaylnk_sl").slider("value") +
		',"speed":'+$("#trunkwaylnk_sp").val()+
		',"enabled":"'+$("#trunkwaylnk_ck").prop("checked")+'"},';
	
	opts+='{"cid":15,"priority":'+ $("#primary_sl").slider("value") +
		',"speed":'+$("#primary_sp").val()+
		',"enabled":"'+$("#primary_ck").prop("checked")+'"},';
	
	opts+='{"cid":16,"priority":'+ $("#primarylnk_sl").slider("value") +
		',"speed":'+$("#primarylnk_sp").val()+
		',"enabled":"'+$("#primarylnk_ck").prop("checked")+'"},';
	
	opts+='{"cid":21,"priority":'+ $("#secondary_sl").slider("value") +
		',"speed":'+$("#secondary_sp").val()+
		',"enabled":"'+$("#secondary_ck").prop("checked")+'"},';
	
	opts+='{"cid":22,"priority":'+ $("#secondarylnk_sl").slider("value") +
		',"speed":'+$("#secondarylnk_sp").val()+
		',"enabled":"'+$("#secondarylnk_ck").prop("checked")+'"},';
	
	opts+='{"cid":31,"priority":'+ $("#tertiary_sl").slider("value") +
		',"speed":'+$("#tertiary_sp").val()+
		',"enabled":"'+$("#tertiary_ck").prop("checked")+'"},';
	
	opts+='{"cid":32,"priority":'+ $("#residential_sl").slider("value") +
		',"speed":'+$("#residential_sp").val()+
		',"enabled":"'+$("#residential_ck").prop("checked")+'"},';
	
	opts+='{"cid":42,"priority":'+ $("#unclassified_sl").slider("value") +
		',"speed":'+$("#unclassified_sp").val()+
		',"enabled":"'+$("#unclassified_ck").prop("checked")+'"},';
	
	opts+='{"cid":62,"priority":'+ $("#pedestrian_sl").slider("value") +
		',"speed":'+$("#pedestrian_sp").val()+
		',"enabled":"'+$("#pedestrian_ck").prop("checked")+'"},';
	
	opts+='{"cid":81,"priority":'+ $("#cycleway_sl").slider("value") +
		',"speed":'+$("#cycleway_sp").val()+
		',"enabled":"'+$("#cycleway_ck").prop("checked")+'"}';
	
	var mHosts = $("#hosts").val().split('\n');
	var nHosts = "";
	
	if( mHosts != null && mHosts.length > 0 ) {
		if( mHosts[0] != "" )
			nHosts +=  '"'+mHosts[0]+'"';
		
		for(var l=1;l<mHosts.length;l++ ) {
			if( mHosts[l] != "" )
				nHosts += ',"'+mHosts[l]+'"';
		}
	}

	opts+='],"hosts":['+nHosts+'] }';
	
	var _this = this;
	
	$.ajax({
		type       : "post",
		url        : this.profileUrl+"?json="+opts,
	  //data       : "json="+opts,
		async      : false,
		beforeSend : function(){ $("#saveDialog").dialog("open");  },
		complete   : function(){ $("#saveDialog").dialog("close"); 
		                         _this.profileAjaxReq();},
		error      : function(){ $("#saveDialog").dialog("close"); 
		                         alert("json save error:"); }
	});	
};

controlService.prototype.deleteParams = function(key) {

	if( key != "-99" ) {
		var d = "json={key:[\""+key+"\"]}";
		var mu= this.profileUrl+"?"+d;
		
		var _this = this;
		
		$.ajax({
			type       : "delete",
			url        : mu,
			async      : false,
			beforeSend : function(){ $("#deleteDialog").dialog("open");  },
			complete   : function(){ $("#deleteDialog").dialog("close"); 
			                         _this.profileAjaxReq();},
			error      : function(){ $("#deleteDialog").dialog("close");
			                         alert("json delete error:"); }
		});	
	}
};
