/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 27/10/2020
Description  : Javascript Helper - Generic data table for complex object structures.
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/10/2020		initial version
********************************************************************************/
({
	/**
	*  @Description: Fires the event to show the order header
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        27/10/2020
	*/
	showRowDetails : function(component, event, row) {
		var compEvents = component.getEvent("headerActionEventFired");// getting the Instance of event
        compEvents.setParams({ "recordSelected" : row });// setting the attribute of event
        compEvents.fire();// firing the event.
  },
	/**
	*  @Description: Fires the event to show the Project
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        31/03/2021
	*/
	showProjectDetail : function(component, event, row) {		
		var compEvents = component.getEvent("headerActionEventFired");// getting the Instance of event
        compEvents.setParams({ "recordSelected" : row, "isProject" : true });// setting the attribute of event
        compEvents.fire();// firing the event.
  },
	/**
	*  @Description: Fires the event to show the Sub Project
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        31/03/2021
	*/
	showSubProjectDetail : function(component, event, row) {
		var compEvents = component.getEvent("headerActionEventFired");// getting the Instance of event
        compEvents.setParams({ "recordSelected" : row, "isProject" : false  });// setting the attribute of event
        compEvents.fire();// firing the event.
  }
})