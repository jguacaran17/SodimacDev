/*******************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/03/2021
Description  : Lightning component - 360 view: Case Creation For Special Services
History      : CMRSC-4891
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      RSO			18/03/2021		initial version
********************************************************************************/

({
    /**
     *  @Description: Object Definition for handling Component Data
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        18/03/2021
     */
    setComponentDataObject: function(component, helper, caseData) {
        let CCResponsable = $A.util.isEmpty(caseData.objShopThatSell) ? 
                                            null : caseData.objShopThatSell.SOD_XS_CentroDeCosto__c;
        let obj = {
            self: this,
            strOrderNumber: caseData.strOrderNumber,
            strObjectType: caseData.strObjectType,
            objClient: caseData.objClient,
            objSellDoc: caseData.objSellDoc,
            objAsocDoc: caseData.objAsocDoc,
            objShopThatSell:caseData.objShopThatSell,
            objCCResponsable: $A.util.isEmpty(caseData.objShopThatSell) ? null : caseData.objShopThatSell,
            objCase: caseData.objCase,
            lstReserves: new Array(),
            strCCReserve: CCResponsable,
            strAsesor: null,
            strCaseRecordTypeSelected: null,
            boolRecordCompleted: false,
            boolFieldSelectionVisibility: false,
            boolRecordTypeConsultaSelected: false
        }
        
        // constructor del objeto: se registran sólo las reservas seleccionadas y sus productos
        for (let idx in caseData.lstSubProjects) {
            if ( caseData.lstSubProjects[idx].selected) {
                let lstProd;
                if(!$A.util.isEmpty(caseData.mapProducts)) {
                    lstProd = caseData.mapProducts[caseData.lstSubProjects[idx].reserve.Name];
                }
                let rsv = helper.getReserveDataObject(component, helper, caseData.lstSubProjects[idx].reserve, lstProd);
                obj.lstReserves.push(rsv);

                // calculamos el asesor que estara registrado en el caso (el último subproyecto define el asesor)
                if (!$A.util.isEmpty(rsv.objReserve.SOD_XS_CreadorOrden__c)) {
                    obj.strAsesor = rsv.objReserve.SOD_XS_CreadorOrden__c.toUpperCase();
                }
            }
        }

        // set the objet
        return obj;
   },

   /**
    *  @Description: Object Definition for handling Reserves
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   getReserveDataObject: function(component, helper, rsvData, prdData) {
        let obj = {
            objReserve: rsvData,
            lstProducts: new Array()
        }

        // init the object
        if(!$A.util.isEmpty(prdData)) {
            prdData.forEach( function(prd) {
                // Si tiene SOD_XS_CantidadAfectada__c, lo agregagamos como producto seleccionado
                if(!$A.util.isEmpty(prd.SOD_XS_CantidadAfectada__c)) {
                    obj.lstProducts.push(prd);
                }
            });
        }
        return obj;
    },

    /**
     *  @Description: Object Definition for handling Reserves
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        18/03/2021
     */
    getDescriptionDataObject: function(component, helper, objDescription, objColumns, objRecordTypes, objLabel) {
        let obj = {
             descCase: objDescription.Case,
             descDocV: objDescription.SOD_XS_DocumentoDeVenta__c,
             descDocA: objDescription.SOD_XS_DocumentoAsociado__c,
             descReserve: objDescription.SOD_XS_SubproyectoDelCaso__c,
             descProduct: objColumns,
             objCase: objLabel["Case"],
             objDocV: objLabel["SOD_XS_DocumentoDeVenta__c"],
             objDocA: objLabel["SOD_XS_DocumentoAsociado__c"],
             objReserve: objLabel["SOD_XS_SubproyectoDelCaso__c"],
             objProduct: objLabel["SOD_XS_ProductoDelCaso__c"],
             descCaseRecordType: new Map(),
             lstRecordType: new Array()
        }

         //se asignan los valores al mapa de RecordTypes
         for(let idx in objRecordTypes) {
            obj.descCaseRecordType.set(objRecordTypes[idx], idx);
            obj.lstRecordType.push(objRecordTypes[idx]);
        }

        //se asigna el valor que corresponde al valor API para Forma de Pago
        let objComponentData = component.get('v.objCaseDataComponent');
        let strPayment = null;
        if(!$A.util.isEmpty(objComponentData.objCase.SOD_XS_FormadePago__c)) {
            for (let i = 0; i < obj.descCase.SOD_XS_FormadePago__c.picklistOptions.length; i++) {
                if (obj.descCase.SOD_XS_FormadePago__c.picklistOptions[i].label.toUpperCase().localeCompare(objComponentData.objCase.SOD_XS_FormadePago__c.toUpperCase()) == 0) {
                    strPayment = obj.descCase.SOD_XS_FormadePago__c.picklistOptions[i].value;
                    break;
                }
            }
            objComponentData.objCase.SOD_XS_FormadePago__c = strPayment;
            component.set('v.objCaseDataComponent', objComponentData);
        }

        return obj;
     },

    /**
    *  @Description: Initialize the attributes of the Component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    setDataComponentAttributes: function(component, event, objComponentData) {
        component.set('v.objCaseDataComponent', objComponentData);
    },

    /**
    *  @Description: Initialize the attributes of the Component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   setReadyComponentAttributes: function(component, event) {
        let objComponentData = component.get('v.objCaseDataComponent');
        objComponentData.boolRecordCompleted = false;
        objComponentData.boolRecordTypeConsultaSelected = false;
        objComponentData.boolFieldSelectionVisibility = false;
        let stopSpinner = true;
        component.set('v.stopSpinner', stopSpinner);
        component.set('v.objCaseDataComponent', objComponentData);
        component.set('v.caseConfirmationVisibility', false);
        component.set('v.caseContentVisibility', true);
    },

    /**
    *  @Description: Initialize the attributes of the Component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
     setErrorComponentAttributes: function(component, event, msg) {
        let stopSpinner = true;
        component.set('v.stopSpinner', stopSpinner);
        component.set('v.caseConfirmationVisibility', false);
        component.set('v.caseContentVisibility', false);
        component.set('v.caseErrorVisibility', true);
        component.find('OppMessage').setError(msg);
    },

    /**
    *  @Description: set the attributes when the user selects the Record Fields
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    setRecordTypeSelectedAttributes : function (component, event, selection) {
       let objComponentData = component.get('v.objCaseDataComponent');
       let objDescriptionComponent = component.get("v.objDescriptionComponent");
       let stopSpinner = true;
       objComponentData.strCaseRecordTypeSelected = selection;
       if(selection) {
           objComponentData.objCase.RecordTypeId = objDescriptionComponent.descCaseRecordType.get(selection);
           stopSpinner = false;
           objComponentData.boolRecordCompleted = false;
           objComponentData.boolFieldSelectionVisibility = true;
           objComponentData.boolRecordTypeConsultaSelected = false;
            if (selection == $A.get("$Label.c.SOD_XS_V360CASE_ResumenCasoConsulta") 
                || selection == $A.get("$Label.c.SOD_XS_V360CASE_ResumenCasoFelicitacion") ) {
               objComponentData.boolRecordTypeConsultaSelected = true;
           }
       }
       else  {
            stopSpinner = true;
            objComponentData.boolRecordCompleted = false;
            objComponentData.boolRecordTypeConsultaSelected = false;
            objComponentData.boolFieldSelectionVisibility = false;
       }
       component.set('v.objCaseDataComponent', objComponentData);
       component.set('v.stopSpinner', stopSpinner);
   },

    /**
    *  @Description: set the attributes when the form is loaded
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    setFieldFormLoadedtAttributes : function (component, event) {
        // set attributes
        let stopSpinner = true;
        component.set('v.stopSpinner', stopSpinner);
    },

    /**
    *  @Description: set the attributes when the form is loaded
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
     setErrorFormLoadedtAttributes : function (component, event) {
        let objComponentData = component.get('v.objCaseDataComponent');
        if(!$A.util.isEmpty(objComponentData.objCCResponsable) ) {
            component.find("errorCCField").set("v.value", objComponentData.objCCResponsable.Id);
        }
        if( !$A.util.isEmpty(objComponentData.objShopThatSell) ) {
            component.find("errorShopField").set("v.value", objComponentData.objShopThatSell.Id);
        }
        if( !$A.util.isEmpty(objComponentData.objCase.SOD_XS_FormadePago__c) ) {
            component.find("errorPayField").set("v.value", objComponentData.objCase.SOD_XS_FormadePago__c);
        }
        
        // set attributes
        let stopSpinner = true;
        component.set('v.stopSpinner', stopSpinner);
    },

    /**
    *  @Description: set the attributes when the record is completed
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    setFieldSelectedAttributes : function (component, event, data) {
        let objComponentData = component.get('v.objCaseDataComponent');
        let stopSpinner;
        // set data
        objComponentData.objCase.SOD_XS_Area__c = data['SOD_XS_Area__c'];
        objComponentData.objCase.SOD_XS_Motivo__c = data['SOD_XS_Motivo__c'];
        objComponentData.objCase.SOD_XS_Submotivo__c = data['SOD_XS_Submotivo__c'];
        objComponentData.objCase.Origin = data['Origin'];
        objComponentData.objCase.Description = data['Description'];
        //get the data from SF if CC is not defined
        if ($A.util.isEmpty(objComponentData.objCCResponsable)) {
            this.getCostCenterById(component, event, data['SOD_XS_CentroCostoResponsable__c']);
            // set attributes
            objComponentData.boolRecordCompleted = false;
            objComponentData.boolFieldSelectionVisibility = true;
            
        }
        else {
            // set attributes
            objComponentData.boolRecordCompleted = true;
            objComponentData.boolFieldSelectionVisibility = false;
            stopSpinner = true;
        }

        component.set('v.objCaseDataComponent', objComponentData);
        component.set('v.stopSpinner', stopSpinner);
    },

    /**
    *  @Description: set the attributes when the record is completed
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
     setErrorSelectedAttributes : function (component, event, data) {
        let objComponentData = component.get('v.objCaseDataComponent');
        //set error msg
        component.find('OppMessage').setError("");
        // set data
        objComponentData.objCCResponsable = { id: data['SOD_XS_CentroCostoResponsable__c'] };
        objComponentData.objShopThatSell = { id: data['SOD_XS_TiendaVende__c'] };
        objComponentData.objCase.SOD_XS_FormadePago__c = data['SOD_XS_FormadePago__c'];
        objComponentData.objCase.SOD_XS_DatosParaLaDevolucion__c = data['SOD_XS_DatosParaLaDevolucion__c'];
        objComponentData.objCase.SOD_XS_ReferenciaDePago__c = data['SOD_XS_ReferenciaDePago__c'];
        objComponentData.objCase.SOD_XS_Monto__c = data['SOD_XS_Monto__c'];
        objComponentData.objCase.SOD_XS_FechaDeCompra__c = data['SOD_XS_FechaDeCompra__c'];
        objComponentData.objCase.SOD_XS_FechaDeCompraHasta__c = data['SOD_XS_FechaDeCompraHasta__c'];
        objComponentData.objCase.SOD_XS_FechaDelIncidente__c = data['SOD_XS_FechaDelIncidente__c'];

        component.set('v.objCaseDataComponent', objComponentData);
    },

    /**
    *  @Description: Set the attributes of the Component for Case Creation
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   setCaseProcessingComponentAttributes: function(component, event) {
        let stopSpinner = false;
        component.set('v.stopSpinner', stopSpinner);
    },

    /**
    *  @Description: Show the case record detail page
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   setCaseCreationComponentAttributes: function(component, event) {
        let stopSpinner = true;
        component.set("v.componentVisibility", false);
        component.set('v.parentComponentVisibility', false);
        component.set('v.caseConfirmationVisibility', false);
        component.set('v.caseContentVisibility', false);
        component.set('v.caseErrorVisibility', false);
        component.set('v.stopSpinner', stopSpinner);
    },


    /**
    *  @Description: Cancel attributes to hide the componente and show the parent component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   setCancelComponentAttributes: function(component, event) {
        component.set("v.componentVisibility", false);
        component.set('v.parentComponentVisibility', true);
    },

    /**
    *  @Description: Show the case record detail page
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   showMessageForEditCreation: function(component, event) {
        let tit = $A.get("$Label.c.SOD_XS_V360CASE_MensajeErrorTitulo");
        let msg = $A.get("$Label.c.SOD_XS_V360CASE_MensajeExitoso");
        let type = "success";
        this.fireAlertComponentError(component, event, tit, msg, type);
    },
  
    /**
    *  @Description: Determine if a Confirmation Dialog box must be shown
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   	isConfirmationNeeded: function(component, event, objComponentData) {
       	let result = false;
        let strBody = "";
        
        // if the type is diferent from "Consulta"
        if (!objComponentData.boolRecordTypeConsultaSelected) {
            // Search for a Reserve without Product Selected
            for (let idx in objComponentData.lstReserves) {
                if (objComponentData.lstReserves[idx].lstProducts.length == 0) {
                    strBody = strBody + objComponentData.lstReserves[idx].objReserve.Name + "<br/>";
                    result = true;
                }
            }
            component.set('v.strReservesWithoutProducts', strBody);
        }
        return result;
    },

    /**
    *  @Description: Initialize the description of objects related to case creation
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   setObjectDescription: function(component, event, helper)  {
        // get the methods on the apex controller
        let cmpDescription = component.get( "c.getDescriptionForCaseCreation" );
        let cmpRecordTypes = component.get( "c.getCaseRecordType" );
        let cmpColumnProds = component.get( "c.getProductColumnsForResume" );
        let cmpObjectDescs = component.get( "c.getDescriptionObjectsForCase" );

        // set the promise including the async call to both methods
        Promise.all([this.serverSideCall(component, cmpDescription), 
                     this.serverSideCall(component, cmpRecordTypes), 
                     this.serverSideCall(component, cmpColumnProds),
                     this.serverSideCall(component, cmpObjectDescs)])
        .then(
            $A.getCallback( function (result) {
                let resDescription = JSON.parse(result[0]);
                let resRecordTypes = result[1];
                let resColumnProds = result[2];
                let resObjectDescs = result[3];

                let objDescriptionComponent = helper.getDescriptionDataObject(component, 
                                                                              helper, 
                                                                              resDescription, 
                                                                              resColumnProds, 
                                                                              resRecordTypes,
                                                                              resObjectDescs);
                component.set("v.objDescriptionComponent",objDescriptionComponent);

                // set the component data and fire the component is ready
                helper.setReadyComponentAttributes(component, event);
            })
        )
        .catch(error => {
            console.error(error.toString());
            let errorObject = JSON.parse(error.message);
            helper.fireAlertComponentError(component, event, errorObject.name, errorObject.message + " (Codigo: " + errorObject.code + ")", "error");
            helper.setReadyComponentAttributes(component, event);
        });
    },

    /**
    *  @Description: Initialize the description of objects related to case creation
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   processCaseData: function(component, event, helper)  {
        // get the methods on the apex controller
        let processCaseData = component.get( "c.processCaseData" );
        processCaseData.setParams( { jsonData : JSON.stringify(component.get('v.objCaseDataComponent')) } );

        // set the promise including the async call to both methods
        Promise.all([this.serverSideCall(component, processCaseData)])
        .then(
            $A.getCallback( function (result) {

                //let resId = JSON.parse(result[0]);
                let resId = result[0];

                helper.showMessageForEditCreation(component, event);
                helper.setCaseCreationComponentAttributes(component, event);
                helper.showCaseViewPage(component, event, resId);
            })
        )
        .catch(error => {
            console.error(error.toString());
            let errorObject = JSON.parse(error.message);
            if (errorObject.message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                helper.setErrorComponentAttributes(component, event, errorObject.message);
            }
            else {
                helper.setReadyComponentAttributes(component, event);
                helper.fireAlertComponentError(component, event, errorObject.name, errorObject.message + " (Codigo: " + errorObject.code + ")", "error");
            }
        });
    },

    /**
    *  @Description: Initialize the description of objects related to case creation
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
     getCostCenterById: function(component, event, strId)  {
        // get the methods on the apex controller
        let getCC = component.get( "c.getCostCenterById" );
        getCC.setParams( { paramId : strId } );

        // set the promise including the async call to both methods
        Promise.all([this.serverSideCall(component, getCC)])
        .then(
            $A.getCallback( function (result) {
                let objComponentData = component.get('v.objCaseDataComponent');
                objComponentData.objCCResponsable = result[0];

                // set attributes
                objComponentData.boolRecordCompleted = true;
                objComponentData.boolFieldSelectionVisibility = false;
                let stopSpinner = true;

                component.set('v.objCaseDataComponent', objComponentData);
                component.set('v.stopSpinner', stopSpinner);
            })
        )
        .catch(error => {
            console.error(error.toString());
            let errorObject = JSON.parse(error.message);
            helper.fireAlertComponentError(component, event, errorObject.name, errorObject.message + " (Codigo: " + errorObject.code + ")", "error");
            helper.setReadyComponentAttributes(component, event);
        });
    },

    /**
    *  @Description: Promise to call APEX controller
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   serverSideCall: function (component, action) {
        return new Promise(
            $A.getCallback( (resolve, reject) => {
                action.setCallback(this, response => {
                    var state = response.getState();               
                    if (state === "SUCCESS") {
                        resolve(response.getReturnValue());
                    } else {
                        reject(new Error(response.getError()[0].message));
                    }
                });
            $A.enqueueAction(action);
            })
        );
    },

    /**
    *  @Description: Show an Alert in case an error when calling the server
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
   showCaseViewPage: function(component, event, recordId) {
        let urlRedirect = $A.get("e.force:navigateToURL");
        urlRedirect.setParams({ url: "/lightning/r/Case/" + recordId + "/view" });
        urlRedirect.fire();
        $A.get('e.force:refreshView').fire();
   },

    /**
    *  @Description: Show an Alert in case an error when calling the server
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   showCaseEditPage: function(component, event, recordId) {
        let urlRedirect = $A.get("e.force:navigateToURL");
        urlRedirect.setParams({ url: "/lightning/r/Case/" + recordId + "/view" });
        urlRedirect.fire();
        $A.get('e.force:refreshView').fire();

        let editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
   },

    /**
    *  @Description: Show an Alert in case an error when calling the server
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   fireAlertComponentError: function(component, event, title, msg, type) {
        let dur = "10000";
        let mod = "dismissible";
        let tit = title;
        let mes = msg; 
        let typ = type;

        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "duration": dur,
            "mode": mod,
            "title": tit,
            "message": mes,
            "type": typ
        });
        toastEvent.fire();
    }

})