/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 15/03/2021
Description  : Javascript Helper - 360 view of a client: Purcharses
History      : CMRSC-4310
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva			ATO
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
    getInitClass: function(component, event, helper) {
        var dataTable = [];
        var columns = [];
        var actions = [];
        component.set('v.loaded', !component.get('v.loaded'));
        let init = component.get( "c.initClass" );
        init.setParams({
            rcdId : component.get("v.recordId")
        });
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {
                actions = response[0].detailActions;
                component.set('v.rowActions', actions.typeAttributes.rowActions);
                var rowActions = this.getRowActions.bind(this, component);
                dataTable = response[0].dataTable;
                columns = response[0].labelsTable;
                actions.typeAttributes.rowActions = rowActions;
                columns.splice(actions.order, 0, actions);
                component.set('v.objSearchCriteria', response[0].searchCriteria);
                component.set('v.columns', columns);
                component.set('v.data', window.jsFlattenEach(dataTable));
                component.set('v.mapPurchasesResult', response[0].mapPurchases);
                component.set('v.loaded', !component.get('v.loaded'));
                if (response[0].isError) {
                    component.set('v.showError', response[0].isError);
                    component.set('v.errorMessage', response[0].errorService.showMessage);
                    this.popEvent($A.get("$Label.c.SOD_XS_V360_SPS_TituloVentanasEmergentes"), response[0].errorService.showMessage, "warning", 5000);
                }
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360_SPS_TituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Promise to call APEX controller
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    serverSideCall: function (component, action) {
        return new Promise((resolve, reject) => {
            action.setCallback(this, response => {
                var state = response.getState();                
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    console.log("Error : " + JSON.stringify(response.getError()[0].message));
                    reject(new Error(response.getError()[0].message));
                }
            });
            $A.enqueueAction(action);
       });
    },
    /**
    *  @Description: Get purchase orders by search type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    getSearchOrdersBy: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var obj = component.get('v.objSearchCriteria');
        let init = component.get( "c.getPurchaseDataObject" );
        init.setParams({
            intPath : obj
        });
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {
                let selectedPurchase = response[0];
                let sPrjId = component.get('v.objSearchCriteria').subProjectNumber;
                let client = component.get('v.objSearchCriteria').client;
                let isProject = component.get('v.objSearchCriteria').isProject;
                let objCaseData = this.generateCaseDataObjectFromPurchase(client, selectedPurchase, sPrjId);
                component.set('v.objCaseData', objCaseData);
                component.set('v.isProject', isProject);
                component.set('v.detailIsOpen', true);
                component.set('v.loaded', !component.get('v.loaded'));
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360_SPS_TituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Get purchase orders of Special Services
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    setPageData: function(component) {        
        component.set('v.loaded', !component.get('v.loaded'));
        let obj = component.get( "c.getPageData" );
        let objCrt = component.get("v.objSearchCriteria");
        if (objCrt.isDateRange) {
            objCrt.purchaseDateFilter.dateFrom = this.formatDate(objCrt.purchaseDateFilter.dateFrom);
            objCrt.purchaseDateFilter.dateTo = this.formatDate(objCrt.purchaseDateFilter.dateTo);
        }
        obj.setParams({
            intPath : objCrt
        });
        Promise.all([this.serverSideCall(component, obj)])
        .then(
            $A.getCallback(response => {
                if (response[0].isError) {
                    component.set('v.showError', response[0].isError);
                    component.set('v.errorMessage', response[0].errorService.showMessage);
                    this.popEvent($A.get("$Label.c.SOD_XS_V360_SPS_TituloVentanasEmergentes"), response[0].errorService.showMessage, "warning", 5000);
                    component.set('v.loaded', !component.get('v.loaded'));
                    return;
                }
                var dataTable = [];
                dataTable = response[0].dataTable;
                component.set('v.data', window.jsFlattenEach(dataTable));
                component.set('v.mapPurchasesResult', response[0].mapPurchases);

                objCrt.totalElements = dataTable.length;
                component.set('v.objSearchCriteria', objCrt);
                component.set('v.loaded', !component.get('v.loaded'));
                component.set('v.activeDataTable', true);
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360_SPS_TituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Start the variables for the search by document type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    selectedSearchByDoc: function(component) {
        let elements = component.get('v.data').splice(1);
        component.set('v.data', elements);
        var obj = component.get('v.objSearchCriteria');
        obj.totalElements = 0;
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isProject = false;
        obj.isSalesDocument = true;
        obj.isSubProject = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaTipoDocumento"));
        component.set('v.accordionSectionMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaTipoDocumento"));
    },
    /**
    *  @Description: Start the variables for the search by Project Number
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    selectedSearchByProjectNumber: function(component) {
        let elements = component.get('v.data').splice(1);
        component.set('v.data', elements);
        var obj = component.get('v.objSearchCriteria');
        obj.totalElements = 0;
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isProject = true;
        obj.isSalesDocument = false;
        obj.isSubProject = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaNumeroProyecto"));
        component.set('v.accordionSectionMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaNumeroProyecto"));
    },
    /**
    *  @Description: Start the variables for the search by Sub Project Number
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    selectedSearchBySubProjectNumber: function(component) {
        let elements = component.get('v.data').splice(1);
        component.set('v.data', elements);
        var obj = component.get('v.objSearchCriteria');
        obj.totalElements = 0;
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isProject = false;
        obj.isSalesDocument = false;
        obj.isSubProject = true;
        component.set('v.objSearchCriteria', obj);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaNumeroSubProyecto"));
    },
    /**
    *  @Description: Start variables for search by Date Range
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    selectedSearchByDateRange: function(component) {
        let elements = component.get('v.data').splice(1);
        component.set('v.data', elements);
        var obj = component.get('v.objSearchCriteria');
        obj.totalElements = 0;
        obj.is360View = true;
        obj.isDateRange = true;
        obj.isProject = false;
        obj.isSalesDocument = false;
        obj.isSubProject = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaRangoFecha"));
        component.set('v.accordionSectionMessage', $A.get("$Label.c.SOD_XS_V360_SPS_EtiquetaRangoFecha"));
    },
    /**
    *  @Description: formats a date variable in the format dd-MM-yyyy
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    formatDate: function  (input) {
        var datePart = input.match(/\d+/g);
        var year;
        var day;
        if (datePart[0].length == 4 && datePart[2].length == 2) {
            year = datePart[0];
            day = datePart[2];
        } else if (datePart[0].length == 2 && datePart[2].length == 4) {
            year = datePart[2];
            day = datePart[0];
        }
        var month = datePart[1];
        return day + '-' + month + '-' + year;
    },
    /**
    *  @Description: Pattern for the types of documents by countries
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    documentPattern: function  (input) {
        var objMap = new Map();
        objMap['CL'] = '[0-9]{1,30}';
        objMap['PE'] = '[0-9]{1,30}';
        objMap['CO'] = '[a-zA-Z0-9_]{1,3}(-)[a-zA-Z0-9_]{1,3}(-)[a-zA-Z0-9_]{1,5}(-)[a-zA-Z0-9_]{8}';
        return objMap[input];
    },
    /**
    *  @Description: PlaceHolder for the types of documents by countries
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    documentPlaceHolder: function  (input) {
        var objMap = new Map();
        objMap['CL'] = '';
        objMap['PE'] = '';
        objMap['CO'] = 'Ejemplo: 99-02-8043-20200517';
        return objMap[input];
    },
    /**
    *  @Description: Validation rules for dates
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    dateValidationTwoDate: function  (inputFrom, inputTo, buttonBsc) {
        let inputDateFrom = inputFrom.get("v.value");
        let inputDateTo = inputTo.get("v.value");
                
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }

        var todayFormattedDate = yyyy + '-' + mm + '-' + dd;
        buttonBsc.set('v.disabled',false);

        var dateBlank = false;
        if (inputDateFrom == ''){
           inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaEnBlanco")}]);
           buttonBsc.set('v.disabled',true);
           dateBlank = true;
        }
        if (inputDateTo == ''){
           inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaEnBlanco")}]);
           buttonBsc.set('v.disabled',true);
           dateBlank = true;
        }
        
        if (!dateBlank){

            var splitDateFrom = [];
            splitDateFrom = this.formatDate(inputDateFrom).split('-');
            var auxDateFrom = splitDateFrom[2] + '-' + splitDateFrom[1] + '-' + splitDateFrom[0];
            
            var splitDateTo = [];
            splitDateTo = this.formatDate(inputDateTo).split('-');
            var auxDateTo = splitDateTo[2] + '-' + splitDateTo[1] + '-' + splitDateTo[0];
            
            // date From
            if (auxDateFrom > todayFormattedDate) {
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaMayorActual")}]);
                buttonBsc.set('v.disabled',true);
            } else if (((yyyy - splitDateFrom[2]) >= 2 && mm >= splitDateFrom[1] && dd > splitDateFrom[0]) || ((yyyy - splitDateFrom[2]) >= 2 && mm > splitDateFrom[1])
                       || ((yyyy - splitDateFrom[2]) > 2 )) {
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaInferior")}]);
                buttonBsc.set('v.disabled',true);
            } else {
                $A.util.removeClass(inputFrom, 'slds-has-error');
                inputFrom.set("v.errors", null);
            }
    
            // Date To
            if (auxDateTo > todayFormattedDate) {
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaMayorActual")}]);
                buttonBsc.set('v.disabled',true);
            } else if (((yyyy - splitDateTo[2]) >= 2 && mm >= splitDateTo[1] && dd > splitDateTo[0]) || ((yyyy - splitDateTo[2]) >= 2 && mm > splitDateTo[1])
                       || ((yyyy - splitDateTo[2]) > 2 )) {
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaInferior")}]);
                buttonBsc.set('v.disabled',true);
            } else {
                $A.util.removeClass(inputTo, 'slds-has-error');
                inputTo.set("v.errors", null);
            }
            
            // DateFrom not > DateTo
            if (auxDateFrom > auxDateTo) {
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaDesdeMayorHasta")}]);
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360_SPS_ValidacionFechaDesdeMayorHasta")}]);
                buttonBsc.set('v.disabled',true);
            }
        }
    },
    /**
    *  @Description: Raise a Toast
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    popEvent: function (ttl, msg, type, time) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: ttl,
            message: msg,
            type: type,
            duration: time  
        });
        toastEvent.fire();
    },
    /**
    *  @Description: Get the actions per row for the data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        22/03/2021
    */
    getRowActions: function (component, row, doneCallback) {
        var actions = [];
        var act = component.get('v.rowActions');
        var actOne = act.find( ({ name }) => name === 'view_projectDetail' )
        var actTwo = act.find( ({ name }) => name === 'view_subProjectDetail' );
        if (!isNaN(row.objSubP_Name)) {
            actOne.disabled = 'true';
        } else {
            actTwo.disabled = 'true';
        }
        actions.push(actOne);
        actions.push(actTwo);
        // simulate a trip to the server
        setTimeout($A.getCallback(function () {
            doneCallback(actions);
        }), 200);
    },
    /**
    *  @Description: Generate the Object with data required for show the Detail
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        31/03/2021
    */
    generateCaseDataObjectFromPurchase: function (client, paramPurchase, sPrjId) {
        let objPurchase;
        if (sPrjId === undefined) {
            let dummySuproject = {
                Name: paramPurchase.objDocA.Name
            };
            let listDummySubproject = new Array(dummySuproject);
            objPurchase = {
                strOrderNumber: paramPurchase.objDocA.Name,
                strObjectType: paramPurchase.strObjectType,
                objClient: client,
                objSellDoc: null,
                objAsocDoc: paramPurchase.objDocA,
                objCase: paramPurchase.objCase,
                objShopThatSell: null,
                lstSubProjects: this.getSelectedObject(listDummySubproject, undefined), // Dummy object for projects
                mapProducts: null,
                isProject: true
            };
        } else {
            let listSubP = paramPurchase.mapObjSubP[paramPurchase.objDocA.Name];
            let objSubP = [];
            let docV = $A.util.isEmpty(paramPurchase.mapObjDocV[sPrjId]) || typeof paramPurchase.mapObjDocV[sPrjId].Name === 'undefined' ?
                        null : paramPurchase.mapObjDocV[sPrjId];
            let shopThatSell = $A.util.isEmpty(docV) ? 
                                    null : paramPurchase.mapObjShopThatSell[docV.SOD_XS_IdExterno__c];
            objSubP.push(listSubP.find( ({ Name }) => Name === sPrjId ));
            objPurchase = {
                strOrderNumber: paramPurchase.objDocA.Name,
                strObjectType: paramPurchase.strObjectType,
                objClient: client,
                objSellDoc: docV,
                objAsocDoc: paramPurchase.objDocA,
                objCase: paramPurchase.objCase,
                objShopThatSell: shopThatSell,
                lstSubProjects: this.getSelectedObject(listSubP, objSubP),
                mapProducts: paramPurchase.mapProducts,
                isProject: false
            };
        }
        return objPurchase;
    },
    /**
    *  @Description: Get the Subproject selected by the user
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/11/2020
    */
    getSelectedObject : function(data, selected) {
        var listSelected = [];
        if (selected == undefined) {
            selected = [];
            selected = data;
        }
        for (var i = 0; i < data.length; i++) {
            var objSelected = {};
            if (selected.includes(data[i])) {
                objSelected.selected = true;
                objSelected.reserve = data[i];
            } else {
                objSelected.selected = false;
                objSelected.reserve = data[i];
            }
            listSelected.push(objSelected);
        }
        return listSelected;
    },
})