/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Helper - 360 view of a client: Detail of a Reserve
History      : CMRSC-3930
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      RSO			05/11/2020		initial version
********************************************************************************/
({
   /**
    *  @Description: Object Definition for Component Data
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   getComponentDataObject: function (component, helper, objComponentObject) {
        let obj = {
            self: this,
            strObjectType: objComponentObject.strObjectType,
            objClient: objComponentObject.objClient,
            objSellDoc: objComponentObject.objSellDoc,
            objAsocDoc: objComponentObject.objAsocDoc,
            objReserve: objComponentObject.objReserve,          // <Object>
            objProducts: objComponentObject.objProducts,        // map(String, List<>)
            boolHasChilds: objComponentObject.boolHasChilds,     // Boolean
            objDescription: objComponentObject.objDescription,  // Object
            objProductDescription: objComponentObject.objProductDescription,   // Object
            objShopThatSell: objComponentObject.objShopThatSell
        }
        
        obj.getAllProductsValues = function () {
            let prdValues = new Object();
            if(!$A.util.isEmpty(this.objProducts)) { 
                prdValues = Object.values(this.objProducts.mapProducts);
            }
            return prdValues;
        };
        obj.getAllProductsKeys = function () {
            let values = Object.values(this.objProducts.mapProducts);
            let keys = [];
            values.forEach( function (v) {
                keys.push(v.SOD_XS_Key);
            });
            return keys;
        };
        obj.getProductSelected = function () {
            let lstSelected = [];
            if(!$A.util.isEmpty(this.objProducts)) {
                this.objProducts.lstSelected.forEach( function (s) {
                    lstSelected.push(s);
                })
            }
            return lstSelected;
        };
        obj.isProductSelected = function (strName) {
            let result = false;
            if (this.objProducts.lstSelected.indexOf(strName) > -1) {
                result = true;
            }
            return true;
        };
        obj.saveProductSelection = function(lstDraftProduct) {
            lstDraftProduct.forEach( function(objDraftProduct) {
                if(!$A.util.isEmpty(objDraftProduct.SOD_XS_CantidadAfectada__c)) {
                    this.objProducts.mapProducts[objDraftProduct.SOD_XS_Key].SOD_XS_CantidadAfectada__c = objDraftProduct.SOD_XS_CantidadAfectada__c;
                    this.objProducts.lstSelected.push(objDraftProduct.SOD_XS_Key);
                }
                else {
                   this.removeProductSelection([objDraftProduct.SOD_XS_Key]);
                }
            }, this);
        };
        obj.removeProductSelection = function (lstProducts) {
            lstProducts.forEach( function(prdCode) {
                let prd = this.objProducts.mapProducts[prdCode];
                prd.SOD_XS_CantidadAfectada__c = null;
                const index = this.objProducts.lstSelected.indexOf(prdCode);
                if (index > -1) {
                    this.objProducts.lstSelected.splice(index, 1);

                }
            }, this);
        };
        obj.checkProductsRemoved = function (lstNewProductSelected) {
            let diff = [];
            let lstOldProductSelected = this.objProducts.lstSelected;
            lstOldProductSelected.forEach(function(prd) {
                if (!lstNewProductSelected.includes(prd)) {
                    diff.push(prd);
                }
            });
            return diff;
        };

        return obj;
    },

    /**
    *  @Description: Object Definition for handling Products data and selections
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   getErrorObject: function () {
        let obj = {
            messages: [],
            fieldNames: [],
            title: ''
        };

        obj.addError = function (strRowId, strField, strMessage) {
            this.messages.push(strMessage);
            if(this.fieldNames.indexOf(strField) < 0) {
                this.fieldNames.push(strField);
            }
            this.title = "El registro " + strRowId + " tiene " + this.messages.length + " errores"
        };
        obj.hasErrors = function () {
            let boolResult = false;
            if (this.messages.length > 0) {
                boolResult = true;
            }
            return boolResult;
        };

        return obj;
    },  

    /**
    *  @Description: handle the product selection to update the data entered by the user
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    validateProductSelection: function(lstDraftProduct, lstSelectedProducts, objComponentData, helper) {
        let objError = new Object();
        let mapErrors = new Map();
        let lstProductValidated = [];
        lstDraftProduct.forEach(function (draftProduct) {
            let prdError = helper.validateProduct(draftProduct, lstSelectedProducts, objComponentData);
            lstProductValidated.push(draftProduct.SOD_XS_Key);
            if(prdError.hasErrors()) {
                mapErrors[draftProduct.SOD_XS_Key] = prdError;
            }
        });
        lstSelectedProducts.forEach( function(strSelectedProduct) {
            if (lstProductValidated.indexOf(strSelectedProduct) < 0 && objComponentData.objProducts.lstSelected.indexOf(strSelectedProduct)) {
                let newDraftObj = {SOD_XS_Key: strSelectedProduct};
                let prdError = helper.validateProduct(newDraftObj, lstSelectedProducts, objComponentData);
                if(prdError.hasErrors()) {
                    mapErrors[newDraftObj.SOD_XS_Key] = prdError;
                }
            }
        });
        
        if(Object.keys(mapErrors).length > 0) {
            let lstMessages = [];
            let lstErrors = Object.values(mapErrors);
            lstErrors.forEach(function (error) {
                lstMessages.push(error.title);
            });

            objError = {
                rows:  mapErrors,
                table: {
                    title: $A.get("$Label.c.SOD_XS_V360RSV_ErrorTablaTitulo"),
                    messages: lstMessages
                }
            };
        }

        return objError;
    },

    /**
    *  @Description: validate product selection (drafts) to detect errors
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    validateProduct: function (objDraft, lstSelected, objComponentData) {
        let prd = objComponentData.objProducts.mapProducts[objDraft.SOD_XS_Key];
        let objError = this.getErrorObject();
        let boolIsEmpty = $A.util.isEmpty(objDraft.SOD_XS_CantidadAfectada__c);

        // si tiene un valor definido
        if(!boolIsEmpty) {
            if(objDraft.SOD_XS_CantidadAfectada__c < 1
                || objDraft.SOD_XS_CantidadAfectada__c > prd.SOD_XS_Cantidad__c
                || isNaN(objDraft.SOD_XS_CantidadAfectada__c)) {
                objError.addError(objDraft.SOD_XS_Key, 'SOD_XS_CantidadAfectada__c', $A.get("$Label.c.SOD_XS_V360RSV_ErrorTablaCantidad") + ' (' + prd.SOD_XS_Cantidad__c + ')');
            }        
            if(lstSelected.indexOf(objDraft.SOD_XS_Key) < 0) {
                objError.addError(objDraft.SOD_XS_Key, 'SOD_XS_CantidadAfectada__c', $A.get("$Label.c.SOD_XS_V360RSV_ErrorTablaCheck"));           
            }
        }
        // si no tiene valor definido
        else {
            if(lstSelected.indexOf(objDraft.SOD_XS_Key) > -1 && objComponentData.objProducts.lstSelected.indexOf(objDraft.SOD_XS_Key) < 0) {
                objError.addError(objDraft.SOD_XS_Key, 'SOD_XS_CantidadAfectada__c', $A.get("$Label.c.SOD_XS_V360RSV_ErrorTablaNulo"));
            }
        }
        return objError;
    },

    /**
    *  @Description: set the attributes in the Components
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   setComponentAttributes: function(component, event, objComponentObject) {
        this.doAlertReserveHasChilds(component, event, objComponentObject.boolHasChilds);
        component.find("accordion").set('v.activeSectionName', 'B'); 

        let lstProducts = objComponentObject.getAllProductsValues();
        let lstProductsSelected = objComponentObject.getProductSelected();

        let classColumns;
        if (objComponentObject.strObjectType.localeCompare('PRC') == 0) {
            classColumns = 'slds-size_4-of-12';
        }
        if (objComponentObject.strObjectType.localeCompare('PMT') == 0) {
            classColumns = 'slds-size_10-of-12';
        }

        component.set('v.objReserveComponent', objComponentObject);
        component.set('v.draftValues', []);
        component.set('v.errors', []);
        component.set('v.lstProductSelected', lstProductsSelected);
        component.set('v.objProductData', lstProducts);
        component.set('v.classColumns', classColumns);

    },

    /**
    *  @Description: set the attributes in the Components when errors were found
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   setErrorAttributes: function(component, event, error) {
        component.set('v.errors', error);
    },

    /**
    *  @Description: set the attributes in the Components when save changes
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   setSaveAttributes: function(component, event, objComponentObject) {
        component.set('v.draftValues', []);
        component.set('v.errors', []);
        component.set('v.objReserveComponent', objComponentObject);
        component.set("v.lstProductSelected", objComponentObject.getProductSelected());
        component.set("v.objProductData", objComponentObject.getAllProductsValues());
    },

    /**
    *  @Description: set the attributes in the Components when save changes
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   setDeselectionAttributes: function(component, event, objComponentObject) {
        component.set('v.objReserveComponent', objComponentObject);
        component.set("v.lstProductSelected", objComponentObject.getProductSelected());
        component.set("v.objProductData", objComponentObject.getAllProductsValues());
    },

    /**
    *  @Description: Show an Alert in case the reserve has Childs
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   doAlertReserveHasChilds: function(component, event, boolAlert) {
        let dur = "10000";
        let mod = "dismissible";
        let tit = "Alerta para el usuario"
        let mes = "";
        let typ = "";
        if(boolAlert == true) {
            mes = $A.get("$Label.c.SOD_XS_V360RSV_Detalle_AlertaReservaHija");
            typ = "success";
            this.showToast(dur, mod, tit, mes, typ);
        }
    },

    /**
    *  @Description: Show an Alert in case the reserve has Childs
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   showToast : function(dur, mod, tit, mes, typ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "duration": dur,
            "mode": mod,
            "title": tit,
            "message": mes,
            "type": typ
        });
        toastEvent.fire();
    },    

    /**
    *  @Description: Show details for product in the reserve
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        05/01/2021
    */
   showRowDetails : function(component, event, row) {
        let objComponentData = component.get("v.objReserveComponent");
        let objProduct =  {
            objClient: objComponentData.objClient,
            strReserveCode: objComponentData.objReserve.Name,
            strProductCode: row.SOD_XS_CodigoProducto__c,
            StrProductDecription: row.SOD_XS_DescripcionDelProducto__c
        };
        var compEvents = component.getEvent("ProductActionEventFired");// getting the Instance of event
        compEvents.setParams({ "productData" : objProduct });// setting the attribute of event
        compEvents.fire();// firing the event.
    }
})