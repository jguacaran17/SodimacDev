/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 13/07/2020
Description  : Javascript Controller - Child component to display the lookup search results.
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			13/07/2020		initial version
********************************************************************************/
({
    /**
    *  @Description: Get the selected record from list
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    selectRecord : function(component, event, helper){      
      // get the selected record from list  
      var getSelectRecord = component.get("v.oRecord");
      // call the event   
      var compEvent = component.getEvent("oSelectedRecordEvent");
      // set the Selected sObject Record to the event attribute.  
      compEvent.setParams({"recordByEvent" : getSelectRecord });  
      // fire the event  
      compEvent.fire();
    },
})