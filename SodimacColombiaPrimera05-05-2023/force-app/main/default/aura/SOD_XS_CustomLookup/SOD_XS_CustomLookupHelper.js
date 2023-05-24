/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 13/07/2020
Description  : Javascript Helper - Custom Lookup for all objects
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
    *  @Description: Get search result of apex controller
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    searchHelper : function(component,event,getInputkeyWord) {
      // call the apex class method
      var action = component.get("c.fetchLookUpValues");
      // set param to method
      action.setParams({
        'searchKeyWord': getInputkeyWord,
        'ObjectName' : component.get("v.objectAPIName")
      });
      // set a callBack
      action.setCallback(this, function(response) {
        $A.util.removeClass(component.find("mySpinner"), "slds-show");
        var state = response.getState();
        if (state === "SUCCESS") {
          var storeResponse = response.getReturnValue();
          // if storeResponse size is equal 0 ,display No Result Found... message on screen.
          if (storeResponse.length == 0) {
            component.set("v.Message", 'No Result Found...');
          } else {
            component.set("v.Message", '');
          }
          // set searchResult list with return value from server.
          component.set("v.listOfSearchRecords", storeResponse);
        }
      });
      // enqueue the Action
      $A.enqueueAction(action);
	},
})