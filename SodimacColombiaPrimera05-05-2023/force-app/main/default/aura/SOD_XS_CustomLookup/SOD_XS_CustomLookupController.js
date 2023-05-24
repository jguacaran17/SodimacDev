/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 13/07/2020
Description  : Javascript Controller - Custom Lookup for all objects
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
    *  @Description: Get Default 5 Records order by createdDate DESC  
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    onfocus : function(component,event,helper){
      $A.util.addClass(component.find("mySpinner"), "slds-show");
      var forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, 'slds-is-open');
      $A.util.removeClass(forOpen, 'slds-is-close');
      // Get Default 5 Records order by createdDate DESC  
      var getInputkeyWord = '';
      helper.searchHelper(component,event,getInputkeyWord);
    },
    /**
    *  @Description: Set list of records
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    onblur : function(component,event,helper){       
      component.set("v.listOfSearchRecords", null );
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, 'slds-is-close');
      $A.util.removeClass(forclose, 'slds-is-open');
    },
    /**
    *  @Description: Get search by keyword
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    keyPressController : function(component, event, helper) {
      // get the search Input keyword   
      var getInputkeyWord = component.get("v.SearchKeyWord");
      // check if getInputKeyWord size id more then 0 then open the lookup result List and 
      // call the helper 
      // else close the lookup result List part.   
      if( getInputkeyWord.length > 0 ){
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        helper.searchHelper(component,event,getInputkeyWord);
      }
      else{  
        component.set("v.listOfSearchRecords", null ); 
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
      }
    },
    /**
    *  @Description: Function to clear the Record Selection 
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */
    clear :function(component,event,heplper){
      var pillTarget = component.find("lookup-pill");
      var lookUpTarget = component.find("lookupField"); 
        
      $A.util.addClass(pillTarget, 'slds-hide');
      $A.util.removeClass(pillTarget, 'slds-show');
        
      $A.util.addClass(lookUpTarget, 'slds-show');
      $A.util.removeClass(lookUpTarget, 'slds-hide');
      
      component.set("v.SearchKeyWord",null);
      component.set("v.listOfSearchRecords", null );
      component.set("v.selectedRecord", {} );   
    },
    /**
    *  @Description: This function is called when the end User Select any record from the result list.   
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        13/07/2020
    */  
    handleComponentEvent : function(component, event, helper) {
      // get the selected Account record from the COMPONENT event 	 
      var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
       
      var forclose = component.find("lookup-pill");
      $A.util.addClass(forclose, 'slds-show');
      $A.util.removeClass(forclose, 'slds-hide');
  
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, 'slds-is-close');
      $A.util.removeClass(forclose, 'slds-is-open');
        
      var lookUpTarget = component.find("lookupField");
      $A.util.addClass(lookUpTarget, 'slds-hide');
      $A.util.removeClass(lookUpTarget, 'slds-show');  
      
    },
})