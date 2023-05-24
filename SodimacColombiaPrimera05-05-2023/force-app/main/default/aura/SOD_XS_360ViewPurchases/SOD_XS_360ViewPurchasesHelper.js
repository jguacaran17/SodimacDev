/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/10/2020
Description  : Javascript Helper - 360 view of a client: Purcharses
History      : CMRSC-4310
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva			ATO
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
	getInitClass: function(component, event, helper) {
        var columns = [];
        var columnsRsv = [];
        component.set('v.loaded', !component.get('v.loaded'));
        let init = component.get( "c.initClass" );
        init.setParams({
            rcdId : component.get("v.recordId")
        });
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {
                columns = response[0].labelsTable;
                columns.splice(response[0].rsvButton.order, 0, response[0].rsvButton);
                columnsRsv = response[0].rsvLabelsTable;
                response[0].searchCriteria.isDateRange = component.get('v.isDateRange');
                response[0].searchCriteria.isPurchaseOrders = component.get('v.isOrderNumber');
                response[0].searchCriteria.isSalesDocument = component.get('v.isDocNumber');
                response[0].searchCriteria.isReserve = component.get('v.isRsvNumber');
                component.set('v.objSearchCriteria', response[0].searchCriteria);
                component.set('v.columns', columns);
                component.set('v.columnsRsv', columnsRsv);
                component.set('v.data', window.jsFlattenEach(response[0].dataTable));
                component.set('v.mapPurchasesResult', response[0].mapPurchases);
                component.set('v.loaded', !component.get('v.loaded'));
                if (response[0].isError) {
                    component.set('v.showError', response[0].isError);
                    component.set('v.errorMessage', response[0].errorService.showMessage);
                    this.popEvent($A.get("$Label.c.SOD_XS_V360OCTituloVentanasEmergentes"), response[0].errorService.showMessage, "warning", 5000);
                }
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360OCTituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Get purchase orders by search type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
	getSearchOrdersBy: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        let init = component.get( "c.getPurchaseDataObject" );
        init.setParams({
            intPath : component.get('v.objSearchCriteria')
        });
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {
                let selectedPurchase = response[0];
                let objClient = component.get("v.objSearchCriteria").client;
                let selectedReserves = this.getSelectedReservations(selectedPurchase.listReserves, undefined);
                let objCaseData = this.generateCaseDataObjectFromPurchase(selectedPurchase, selectedReserves, objClient);
                let objProductData = this.generateObjectForProductDetail(objClient);
                
                component.set("v.objCaseData", objCaseData);
                component.set("v.objProductData", objProductData);
                component.set("v.orderNumber", selectedPurchase.objDocA.Name);
                component.set("v.headerIsOpen", false);
                component.set("v.detailRsvIsOpen", true);
                component.set("v.isFromHeader", false);
                component.set('v.loaded', !component.get('v.loaded'));
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360OCTituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Get purchase orders by pagination and date range
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    setPageDataAsPerPagination: function(component) {
        component.set('v.loaded', !component.get('v.loaded'));
        let obj = component.get( "c.getPageOrdersAsPerPagination" );
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
                component.set('v.objSearchCriteria.numberOfPages', response[0].searchCriteria.numberOfPages);
                component.set('v.objSearchCriteria.totalElements', response[0].searchCriteria.totalElements);
                component.set('v.data', window.jsFlattenEach(response[0].dataTable));
                component.set('v.mapPurchasesResult', response[0].mapPurchases);

                component.set('v.loaded', !component.get('v.loaded'));      
                if (response[0].isError) {
                    component.set('v.showError', response[0].isError);
                    component.set('v.errorMessage', response[0].errorService.showMessage);
                    this.popEvent($A.get("$Label.c.SOD_XS_V360OCTituloVentanasEmergentes"), response[0].errorService.showMessage, "warning", 5000);
                }
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
            this.popEvent($A.get("$Label.c.SOD_XS_V360OCTituloVentanasEmergentes"), error.message, "error", 5000);
            component.set('v.loaded', !component.get('v.loaded'));
        });
    },
    /**
    *  @Description: Promise to call APEX controller
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
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
    *  @Description: Start the variables for the search by document type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
	selectedSearchByDoc: function(component) {
        var obj = component.get('v.objSearchCriteria');
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isPurchaseOrders = false;
        obj.isSalesDocument = true;
        obj.isReserve = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.isOrderNumber', false);
        component.set('v.isRsvNumber', false);
        component.set('v.isDocNumber', true);
        component.set('v.isDateRange', false);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaTipoDocumento"));   
    },
    /**
    *  @Description: Start the variables for the search by purchase order number
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    selectedSearchByOrderNumber: function(component) {
        var obj = component.get('v.objSearchCriteria');
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isPurchaseOrders = true;
        obj.isSalesDocument = false;
        obj.isReserve = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.isOrderNumber', true);
        component.set('v.isRsvNumber', false);
        component.set('v.isDocNumber', false);
        component.set('v.isDateRange', false);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaNumeroOrdenesCompra"));        
    },
    /**
    *  @Description: Start the variables for the search by reservation number
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    selectedSearchByRsvNumber: function(component) {
        var obj = component.get('v.objSearchCriteria');
        obj.is360View = false;
        obj.isDateRange = false;
        obj.isPurchaseOrders = false;
        obj.isSalesDocument = false;
        obj.isReserve = true;
        component.set('v.objSearchCriteria', obj);
        component.set('v.isOrderNumber', false);
        component.set('v.isRsvNumber', true);
        component.set('v.isDocNumber', false);
        component.set('v.isDateRange', false);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaNumeroReserva"));
    },
    /**
    *  @Description: Start variables for search by date range
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
 	selectedSearchByDateRange: function(component) {
        var obj = component.get('v.objSearchCriteria');
        obj.is360View = true;
        obj.isDateRange = true;
        obj.isPurchaseOrders = false;
        obj.isSalesDocument = false;
        obj.isReserve = false;
        component.set('v.objSearchCriteria', obj);
        component.set('v.isOrderNumber', false);
        component.set('v.isRsvNumber', false);
        component.set('v.isDocNumber', false);
        component.set('v.isDateRange', true);
        component.set('v.activeSearchMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaRangoFecha"));
        component.set('v.accordionSectionMessage', $A.get("$Label.c.SOD_XS_V360OCEtiquetaRangoFecha"));
    },
    /**
    *  @Description: Start variables for pagination search
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
    */
    selectedSearchByPagination: function(component) {
        var obj = component.get('v.objSearchCriteria');
        obj.is360View = true;
        obj.isDateRange = component.get('v.isDateRange');
        obj.isPurchaseOrders = false;
        obj.isSalesDocument = false;
        obj.isReserve = false;
        component.set('v.objSearchCriteria', obj);
    },
    /**
    *  @Description: Get the reservations selected by the user
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/11/2020
    */
    getSelectedReservations : function(data, selectedRsvs) {
        var listSelected = [];
        if (selectedRsvs == undefined) {
            selectedRsvs = [];
            selectedRsvs = data;
        }
        for (var i = 0; i < data.length; i++) {
            var objSelected = {};
            if (selectedRsvs.includes(data[i])) {
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
    /**
    *  @Description: formats a date variable in the format dd-MM-yyyy
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
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
    *  @Date:        05/10/2020
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
    *  @Date:        05/10/2020
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
    *  @Date:        05/10/2020
    */
    dateValidation: function  (input) {
        let inputDate = input.get("v.value");
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
        var splitDate = [];
        splitDate = this.formatDate(inputDate).split('-');
        var auxDate = splitDate[2] + '-' + splitDate[1] + '-' + splitDate[0];
        var todayFormattedDate = yyyy + '-' + mm + '-' + dd;
        if (auxDate > todayFormattedDate) {
            input.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaMayorActual")}]);
        } else if ((yyyy - splitDate[2]) > 5) {
            input.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaInferior5Anhos")}]);
        } else {
            $A.util.removeClass(input, 'slds-has-error');
            input.set("v.errors", null);
        }
    },
    /**
    *  @Description: Validation rules for dates
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        05/10/2020
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
           inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaEnBlanco")}]);
		   buttonBsc.set('v.disabled',true);
           dateBlank = true;
        }
        if (inputDateTo == ''){
           inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaEnBlanco")}]);
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
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaMayorActual")}]);
                buttonBsc.set('v.disabled',true);
            } else if ((yyyy - splitDateFrom[2]) > 5) {
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaInferior5Anhos")}]);
                buttonBsc.set('v.disabled',true);
            } else {
                $A.util.removeClass(inputFrom, 'slds-has-error');
                inputFrom.set("v.errors", null);
            }
    
            // Date To
            if (auxDateTo > todayFormattedDate) {
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaMayorActual")}]);
                buttonBsc.set('v.disabled',true);
            } else if ((yyyy - splitDateTo[2]) > 5) {
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaInferior5Anhos")}]);
                buttonBsc.set('v.disabled',true);
            } else {
                $A.util.removeClass(inputTo, 'slds-has-error');
                inputTo.set("v.errors", null);
            }
            
            // DateFrom not > DateTo
            if (auxDateFrom > auxDateTo) {
                inputFrom.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaDesdeMayorHasta")}]);
                inputTo.set("v.errors", [{message: $A.get("$Label.c.SOD_XS_V360OCValidacionFechaDesdeMayorHasta")}]);
                buttonBsc.set('v.disabled',true);
            }
        }
    },
    /**
    *  @Description: Raise a Toast
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
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
    *  @Description: Generate the Object with data required for show the Detail
    *  @Autor:       Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2021
    */
    generateCaseDataObjectFromPurchase: function (paramPurchase, paramReserves, paramClient) {
        let objPurchase =  {
                strOrderNumber: paramPurchase.objDocA.Name,
                strObjectType: paramPurchase.strObjectType,
                objClient: paramClient,
                objSellDoc: paramPurchase.objDocV,
                objAsocDoc: paramPurchase.objDocA,
                objCase: paramPurchase.objCase,
                objShopThatSell: paramPurchase.objShopThatSell,
                lstReserves: paramReserves,
                mapProducts: paramPurchase.mapProducts
            };
        return objPurchase;
    },

    /**
    *  @Description: Generate the Object with data required for view Detail Product
    *  @Autor:       Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
   generateObjectForProductDetail: function (paramClient) {
        let objProduct =  {
                objClient: paramClient,
                strReserveCode: null,
                strProductCode: null,
                StrProductDecription: null
            };
        return objProduct;
    }
})