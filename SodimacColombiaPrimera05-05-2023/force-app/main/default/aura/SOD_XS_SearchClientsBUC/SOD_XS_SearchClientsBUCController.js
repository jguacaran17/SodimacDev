/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Javascript Controller - Customer search(BUC)
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			08/07/2020		initial version
********************************************************************************/
({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    doInit : function(component, event, helper) {
        helper.getInitClass(component, event);
    },
    /**
    *  @Description: Search by document number
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    searchCustomerByDocNumber: function (component, event, helper) {
        var input = component.find("accDocNumber");
        var isValid = false;
        let docType = component.find("accDocType").get("v.value");
        isValid = window.jsValidateDocument(docType, input);
        if (isValid) {
            helper.getClient(component, event, helper);
        }
    },
    /**
    *  @Description: Gets the DeveloperName of the selected record type
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    onChangeRcdType: function (component, event, helper) {
        helper.getRcdType(component, event, helper);
    },
    /**
    *  @Description: Redirects to the creation of a case(Case: Felicitación)
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    createCaseFLC: function (component, event, helper) {
        helper.getCase(component, event, component.get("v.rcdNameCaseFLC"));
  	},
    /**
    *  @Description: Redirects to the creation of a case(Case: Consulta)
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    createCaseCNS: function (component, event, helper) {
        helper.getCase(component, event, component.get("v.rcdNameCaseCNS"));
  	},
    /**
    *  @Description: Clean the variables
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    clrAll : function(component, helper) {
        $A.get('e.force:refreshView').fire();
    },
    /**
    *  @Description: Cancel the search operation
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    cancelDialog : function(component, helper) {
        component.set("v.isOpen", false);
        var urlEvent = $A.get("e.force:navigateToURL");
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response) {                 
                urlEvent.setParams({
                    "url": '/lightning/o/Account'
                });
            } else {
                $A.get('e.force:refreshView').fire();
                urlEvent.setParams({
                    "url": '/lightning/o/Account/home'
                });
            }
            urlEvent.fire();
        })
        .catch(function(error) {
            console.log(error);
        });        
    }    
})