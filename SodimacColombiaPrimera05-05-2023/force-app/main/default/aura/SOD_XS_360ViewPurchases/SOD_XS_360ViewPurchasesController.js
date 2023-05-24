/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/10/2020
Description  : Javascript Controller - 360 view of a client: Purcharses
History      : CMRSC-4310
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			05/10/2020		initial version
********************************************************************************/
({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    doInit : function(component, event, helper) {
        helper.getInitClass(component, event);
    },
    /**
    *  @Description: Dropdown menu action handler
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    handleSelect: function(component, event, helper) {        
        //Orchestrate the methods according to the selection from the dropdown menu
        switch(event.getParam('value')) {
            case "SearchByDoc": helper.selectedSearchByDoc(component); break;
            case "SearchByOrderNumber": helper.selectedSearchByOrderNumber(component); break;
            case "SearchByRsvNumber": helper.selectedSearchByRsvNumber(component); break;
            case "SearchByDateRange": helper.selectedSearchByDateRange(component); break;
        }
    },

    /**
    *  @Description: Shows the detail of the selected purchase
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    handleEvent: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var row = event.getParam("recordSelected");                 // getting the value of selected purchase  
        var mapPurchases = component.get('v.mapPurchasesResult');   // getting the map with all purchases
        var selectedPurchase = mapPurchases[row.id];                // getting the object related to selected purchase
        // check if the purchase object contains 1 reserve
        if (selectedPurchase.listReserves.length == 1) {
            let objClient = component.get("v.objSearchCriteria").client;
            let selectedReserves = helper.getSelectedReservations(selectedPurchase.listReserves, undefined);
            let objCaseData = helper.generateCaseDataObjectFromPurchase(selectedPurchase, selectedReserves, objClient);
            let objProductData = helper.generateObjectForProductDetail(objClient);
            
            component.set("v.objCaseData", objCaseData);
            component.set("v.objProductData", objProductData);
            component.set("v.orderNumber", row.objDocA_Name);
            component.set("v.headerIsOpen", false);
            component.set("v.detailRsvIsOpen", true);
            component.set("v.isFromHeader", false);
        } else {
            component.set("v.headerIsOpen", true);
            component.set("v.orderNumber", row.objDocA_Name);
            component.set("v.selectedPurchase", selectedPurchase);
            component.set("v.isFromHeader", true);
        }
        component.set('v.loaded', !component.get('v.loaded'));
    },

    /**
    *  @Description: Search for an order by the selected search type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    searchOrdersBy: function(component, event, helper) {
        component.set('v.showError', false);
        if (component.get('v.isDateRange')) {
            helper.setPageDataAsPerPagination(component);
            component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaRangoFecha"));
            component.set('v.accordionSectionMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaRangoFecha"));
        } else {
            helper.getSearchOrdersBy(component, event);
        }
    },
    /**
    *  @Description: Look for the next page in the purchase order pagination
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    onNext: function(component, event, helper) {
        let pageNumber = component.get("v.objSearchCriteria.pageNumber");
        component.set("v.objSearchCriteria.pageNumber", pageNumber + 1);
        helper.selectedSearchByPagination(component);
        helper.setPageDataAsPerPagination(component);
    },
    /**
    *  @Description: Look for the previous page in the purchase order pagination
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    onPrev: function(component, event, helper) {
        let pageNumber = component.get("v.objSearchCriteria.pageNumber");
        component.set("v.objSearchCriteria.pageNumber", pageNumber - 1);
        helper.selectedSearchByPagination(component);
        helper.setPageDataAsPerPagination(component);
    },
    /**
    *  @Description: Look for the first page in the purchase order pagination
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    onFirst: function(component, event, helper) {
        component.set("v.objSearchCriteria.pageNumber", 1);
        helper.selectedSearchByPagination(component);
        helper.setPageDataAsPerPagination(component);
    },
    /**
    *  @Description: Look for the last page in the purchase order page
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */ 
    onLast: function(component, event, helper) {
        component.set("v.objSearchCriteria.pageNumber", component.get("v.objSearchCriteria.numberOfPages"));
        helper.selectedSearchByPagination(component);
        helper.setPageDataAsPerPagination(component);
    },
    /**
    *  @Description: Call dateToUpdate function on onchange event on "Date To" field
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
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
    *  @Date:        05/10/2020
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
    *  @Date:        23/11/2020
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
    *  @Description: Shows the details of the selected reservations
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        25/11/2020
    */
    viewDetails : function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var selectedPurchase = component.get("v.selectedPurchase"); // getting the object related to selected purchase
        let objClient = component.get("v.objSearchCriteria").client;
        let selectedReserves = helper.getSelectedReservations(selectedPurchase.listReserves, component.get("v.selectedRsvs"));
        let objCaseData = helper.generateCaseDataObjectFromPurchase(selectedPurchase, selectedReserves, objClient);
        let objProductData = helper.generateObjectForProductDetail(objClient);

        component.set("v.objProductData", objProductData);
        component.set("v.objCaseData", objCaseData);
        component.set("v.headerIsOpen", false);
        component.set("v.detailRsvIsOpen", true);
        component.set('v.loaded', !component.get('v.loaded'));
    },
    
    /**
    *  @Description: Cancel the header view
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    cancelDialog : function(component, helper) {
        component.set("v.headerIsOpen", false);
    }
})