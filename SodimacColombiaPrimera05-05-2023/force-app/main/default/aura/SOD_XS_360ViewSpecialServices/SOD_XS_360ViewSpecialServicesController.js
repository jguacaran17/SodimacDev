/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 15/03/2021
Description  : Javascript Controller - 360 view of a client: Special Services
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			15/03/2021		initial version
********************************************************************************/
({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    doInit : function(component, event, helper) {
        helper.getInitClass(component, event);
    },
    /**
    *  @Description: Dropdown menu action handler
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    handleSelect: function(component, event, helper) {        
    //Orchestrate the methods according to the selection from the dropdown menu
        switch(event.getParam('value')) {
            case "SearchByDoc": helper.selectedSearchByDoc(component); break;
            case "SearchByProjectNumber": helper.selectedSearchByProjectNumber(component); break;
            case "SearchBySubProjectNumber": helper.selectedSearchBySubProjectNumber(component); break;
            case "SearchByDateRange": helper.selectedSearchByDateRange(component); break;
        }
    },
    /**
    *  @Description: Shows the detail of the selected Project or SubProject
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        31/03/2021
    */
    handleEvent: function(component, event, helper) {
        try {
            component.set('v.loaded', !component.get('v.loaded'));
            let objCaseData;
            let client = component.get('v.objSearchCriteria').client;
            let row = event.getParam("recordSelected"); // getting the value of selected
            let isProject = event.getParam("isProject"); // getting check to verify if it is a project or not
            let mapPurchases = component.get('v.mapPurchasesResult'); // getting the map with all purchases
            let prjId = row.id.includes('-SPJ-') ? row.id.split('-SPJ-')[0] : row.id; // Id format for a Project with Subproject "1-SPJ-8989" / Id format for a Project without Subproject "1"
            let sPrjId = row.id.includes('-SPJ-') ? row.id.split('-SPJ-')[1] : undefined;
            objCaseData = helper.generateCaseDataObjectFromPurchase(client, mapPurchases[prjId], sPrjId);
            component.set('v.objCaseData', objCaseData);
            component.set('v.isProject', isProject);
            component.set('v.detailIsOpen', true);
            component.set('v.loaded', !component.get('v.loaded'));
        }
        catch(err) {
            console.log('err: ' + err);
        }
    },
    /**
    *  @Description: Search for an order by the selected search type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    searchOrdersBy: function(component, event, helper) {
        component.set('v.showError', false);
        if (component.get('v.objSearchCriteria').isSubProject) {
            helper.getSearchOrdersBy(component, event);
        } else {
            helper.setPageData(component);
        }
    },
    /**
    *  @Description: Call dateToUpdate function on onchange event on "Date To" field
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */    
    dateToUpdate : function(component, event, helper) {
        var inputFrom = component.find("scDateFrom");
        var inputTo = component.find("scDateTo");
        var btnBuscar = component.find("scBuscar");
        helper.dateValidationTwoDate(inputFrom, inputTo, btnBuscar);
    },
    /**
    *  @Description: Call dateFromUpdate function on onchange event on "Date From" field
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */    
    dateFromUpdate : function(component, event, helper) {
        var inputFrom = component.find("scDateFrom");
        var inputTo = component.find("scDateTo");
        var btnBuscar = component.find("scBuscar");
        helper.dateValidationTwoDate(inputFrom, inputTo, btnBuscar);
    },
    /**
    *  @Description: Call onChangeSalesDocumentType function on onchange event on "Sales Document Type" field
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */    
    onChangeSalesDocumentType : function(component, event, helper) {
        var docType = component.get("v.objSearchCriteria.salesDocumentFilter.salesDocumentType");
        var cnt = component.get("v.objSearchCriteria.client.SOD_XS_Country__r.SOD_XS_Codigo__c");
        var helpText = cnt == 'CO' && (docType == 'BOLETA' || docType == 'TIRILLA') 
                        ? $A.get("$Label.c.SOD_XS_V360OCTxtAyudaDocumentoVenta")
                        : '';
        //Set the pattern by country
        component.set('v.documentPattern', helper.documentPattern(cnt));
        //Set the placeholder by country
        component.set('v.documentPlaceHolder', helper.documentPlaceHolder(cnt));
        //Set the help text by country
        component.set('v.documentFieldLevelHelp', helpText);
    },
    /**
    *  @Description: Cancel the header view
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    cancelDialog : function(component, helper) {
        component.set("v.headerIsOpen", false);
    }
})