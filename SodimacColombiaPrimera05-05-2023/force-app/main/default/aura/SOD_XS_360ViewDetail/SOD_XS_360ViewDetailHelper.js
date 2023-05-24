/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Helper - 360 view of a client: Reserves
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
     *  @Description: Object Definition for handling Reserves
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setComponentDataObject: function(component, helper, dataObject) {
        let obj = {
            self: this,
            strObjectType: dataObject.strObjectType,
            objClient: dataObject.objClient,
            objSellDoc: dataObject.objSellDoc,
            objAsocDoc: dataObject.objAsocDoc,
            objShopThatSell: dataObject.objShopThatSell,
            mapReserves: new Map(),             // <String, Object>
            objReserveDescription: null,               // <Object>
            mapProductReserveDescription: null,        // <String, Object>
            objDocumentDescription: null,
            objProductDocumentDescription: null,
            boolLoadedComponent: false,

            // function: set the reserve description to the object
            setReserveDescription: function(rspReserve) {
                this.objReserveDescription = rspReserve; 
            },

            // function: set the product description to the object (Purchase ORders)
            setProductDescription: function(rspDescription) {
                this.mapProductReserveDescription = new Map();
                for (let rsvName in this.mapReserves) {
                    let prdDescription = JSON.parse(JSON.stringify(rspDescription));
                    let rsvCurrencyIso = this.getReserveCurrencyIso(rsvName);
                    for (let key in prdDescription) {
                        prdDescription[key].initialWidth = 70;
                        if (prdDescription[key].fieldName == 'SOD_XS_DescripcionDelProducto__c'){
                            prdDescription[key].initialWidth = 200;
                        }else if (prdDescription[key].fieldName == 'SOD_XS_Estado__c'){
                            prdDescription[key].initialWidth = 90;
                        }else if (prdDescription[key].fieldName == 'SOD_XS_CodigoDespacho__c' ||  
                                  prdDescription[key].fieldName == 'SOD_XS_CodigoOrigen__c'){
                            prdDescription[key].initialWidth = 150;

                        }


                        if(prdDescription[key].fieldName == 'SOD_XS_CantidadAfectada__c') {
                            prdDescription[key].editable = true;
                        }
                        if(prdDescription[key].type == 'currency') {
                            prdDescription[key].typeAttributes = { 
                                currencyCode: rsvCurrencyIso
                            };
                        }
                        prdDescription[key].wrapText = true;
                    }
                    this.mapProductReserveDescription[rsvName] = prdDescription;
                }
            },

            // function: set the product description to the object
            setDocumentDescription: function (rspDocument) {
                this.objDocumentDescription = rspDocument;
            },

            // function: set the product description to the object (Payment Vouchers)
            setProductForDocumentDescription: function (rspProductForReserves) {
                let prdDescription = JSON.parse(JSON.stringify(rspProductForReserves));
                for (let key in prdDescription) {
                    if(prdDescription[key].fieldName == 'SOD_XS_CantidadAfectada__c') {
                        prdDescription[key].editable = true;
                    }
                    if(prdDescription[key].type == 'currency') {
                        prdDescription[key].typeAttributes = { 
                            currencyCode: this.objSellDoc.CurrencyIsoCode
                        };
                    }
                }
                this.objProductDocumentDescription = prdDescription;
            },

            // function: set the visibility the component
            setLoadedComponent: function() {
                this.boolLoadedComponent = true; 
            },

            // function: return the list of the reserve numbers
            getListOfReserves: function () {
                return Object.keys(this.mapReserves);
            },

            // function: get the currency iso code related to the reserve
            getReserveCurrencyIso: function (rsvName) {
                let strCurrencyIso = this.mapReserves[rsvName].objReserve.CurrencyIsoCode;
                if($A.util.isEmpty(strCurrencyIso)) {
                    strCurrencyIso = this.objClient.CurrencyIsoCode;
                }
                return strCurrencyIso;
            },
             
            // function: return the reserve object related to the reserve number 
            getReserveData: function (strReserveNumber) {
                return this.mapReserves[strReserveNumber].objReserve;
            },

            //function: get the component object related to the reserve number
            getPurchaseObjectData: function (strReserveNumber) {
                if($A.util.isEmpty(this.mapReserves[strReserveNumber].objReserveDescription)) {
                    // if objecttype is PurchaseOrder
                    if (this.strObjectType.localeCompare("PRC") == 0) {
                        this.mapReserves[strReserveNumber].objDescription = this.objReserveDescription;
                    }
                    // if objecttype is PaymentVoucher
                    if (this.strObjectType.localeCompare("PMT") == 0) {
                        this.mapReserves[strReserveNumber].objDescription = this.objDocumentDescription;
                    }
                }
                if($A.util.isEmpty(this.mapReserves[strReserveNumber].objProductDescription)) {
                    // if objecttype is PurchaseOrder
                    if (this.strObjectType.localeCompare("PRC") == 0) {
                        this.mapReserves[strReserveNumber].objProductDescription = this.mapProductReserveDescription[strReserveNumber];
                    }
                    // if objecttype is PaymentVoucher
                    if (this.strObjectType.localeCompare("PMT") == 0) {
                        this.mapReserves[strReserveNumber].objProductDescription = this.objProductDocumentDescription;
                    }
                    
                }
                this.mapReserves[strReserveNumber].strObjectType = this.strObjectType;
                this.mapReserves[strReserveNumber].objClient = this.objClient;
                this.mapReserves[strReserveNumber].objSellDoc = this.objSellDoc;
                this.mapReserves[strReserveNumber].objAsocDoc = this.objAsocDoc;
                this.mapReserves[strReserveNumber].objShopThatSell = this.objShopThatSell;
                return this.mapReserves[strReserveNumber];
            }
 
         };
 
         // constructor del objeto
         let objReserve; 
         let lstMother = [];  
         let rsvData = dataObject.lstReserves;
         rsvData.forEach( function (r) {
             if ( r.selected) {
                 objReserve = helper.getPurchaseObject(component, helper, r.reserve)
                 obj.mapReserves[r.reserve.Name] = objReserve;
             }
             if(!$A.util.isEmpty(r.reserve.SOD_XS_CodigoReservaMadre__c)){
                 lstMother.push(r.reserve.SOD_XS_CodigoReservaMadre__c);
             }
         });
 
         lstMother.forEach ( function (m) {
             if(Object.keys(obj.mapReserves).indexOf(m) > -1) {
                 obj.mapReserves[m].boolHasChilds = true;
             }
         });
 
         let lstReserve = Object.keys(obj.mapReserves);
         let prdMap = dataObject.mapProducts;
         for(let i = 0; i < lstReserve.length; i++)  {
             let rsvName = lstReserve[i];
             if(!$A.util.isEmpty(prdMap)) {
                 let p = prdMap[rsvName];
                 let objProduct = helper.getProductDataObject(component, helper, p);
                 obj.mapReserves[rsvName].objProducts = objProduct;
             }
         } 
 
         // set the objet
         return obj;
    },
 
    /**
     *  @Description: Object Definition for handling Products
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    getPurchaseObject: function(component, helper, rsv) {
         let obj = {
             self: this,
             strObjectType: null,
             objClient: null,
             objSellDoc: null,
             objAsocDoc: null,
             objShopThatSell: null,
             objReserve: null,               // <Object>
             objProducts: null,              // <Object>
             boolHasChilds: false,         // Boolean
             objDescription: null,          // Object
             objProductDescription: null   // Object

         }
 
         // constructor del objeto
         obj.objReserve = rsv;
         return obj;
     },
 
    /**
     *  @Description: Object Definition for handling Products
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    getProductDataObject: function(component, helper, prdData) {
         let obj = {
             self: this,
             mapProducts: new Map(),        // <String, Object>
             lstSelected: []                // <List>
         }
 
         // init the object
         let idx = 1;
         if(!$A.util.isEmpty(prdData)) {
             prdData.forEach( function(prd) {
                 prd.SOD_XS_Key = prd.SOD_XS_CodigoProducto__c + '_' + idx;
                 obj.mapProducts[prd.SOD_XS_Key] = prd;
                 if(!$A.util.isEmpty(prd.SOD_XS_CantidadAfectada__c)) {
                     obj.lstSelected.push(prd.SOD_XS_Key);
                 }
                 idx++;
             });
     
         }
         return obj;
     },

    /**
     *  @Description: Object Definition for Labels used in all components
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        01/02/2021
     */
    getLabelObject: function(component, helper, objComponentData) {
        let obj = {
            // labels for panel component
            panel: {
                title: null
            },
            // labels for detail component
            detail: {
                header: null,
                button_back: null,
                button_next: null
            },
            // labels for content component
            content: {
                accordeon_products: null,
                accordeon_detail: null,
                products_detail: null
            },
            // labels for reserve component
            reserve: {
                detail_data: null,
                detail_address: null
            },
            document: {
                detail_data: null
            }
        }

        // init the object
        if(objComponentData.strObjectType.localeCompare("PRC") == 0) {
            obj.panel.title = $A.get("$Label.c.SOD_XS_V360RSV_Panel_Encabezado");
            obj.detail.header = $A.get("$Label.c.SOD_XS_V360OCEncabezadoCabeceraReservas");
            obj.content.accordeon_products = $A.get("$Label.c.SOD_XS_V360RSV_DetalleAcordeonProductos");
            obj.content.accordeon_detail = $A.get("$Label.c.SOD_XS_V360RSV_DetalleAcordeonDetalle");
            obj.content.products_detail = $A.get("$Label.c.SOD_XS_V360RSV_DetalleProductos");
            obj.reserve.detail_data = $A.get("$Label.c.SOD_XS_V360RSV_DetalleReservaDatos");
            obj.reserve.detail_address = $A.get("$Label.c.SOD_XS_V360RSV_DetalleReservaDireccion");
        }
        if(objComponentData.strObjectType.localeCompare("PMT") == 0) {
            obj.panel.title = $A.get("$Label.c.SOD_XS_V360DOC_Panel_Encabezado");
            obj.detail.header = $A.get("$Label.c.SOD_XS_V360OCEncabezadoCabeceraDocumentos");
            obj.content.accordeon_products = $A.get("$Label.c.SOD_XS_V360DOC_DetalleAcordeonProductos");
            obj.content.accordeon_detail = $A.get("$Label.c.SOD_XS_V360DOC_DetalleAcordeonDetalle");
            obj.content.products_detail = $A.get("$Label.c.SOD_XS_V360DOC_DetalleProductos");
            obj.document.detail_data = $A.get("$Label.c.SOD_XS_V360RSV_DetalleDocumentosDatos");
        }
        obj.detail.button_back = $A.get("$Label.c.SOD_XS_V360RSV_BotonVolver");
        obj.detail.button_next = $A.get("$Label.c.SOD_XS_V360RSV_BotonCasos");
        return obj;
    },
 
     /**
     *  @Description: Initialize the attributes of the Component
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        01/02/2021
     */
    setLabelsComponentAttributes: function(component, event, labelObject) {
        component.set('v.labelComponent', labelObject);
    },

     /**
     *  @Description: Initialize the attributes of the Component
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setDataComponentAttributes: function(component, event, objComponentData) {
        component.set('v.caseComponentVisibility', false);
        component.set('v.purchaseDataComponent', objComponentData);
    },
 
     /**
     *  @Description: set the attributes when the component is ready
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setReadyComponentAttributes : function (component, event, objComponentData) {
         objComponentData.setLoadedComponent();
         this.setDataComponentAttributes(component, event, objComponentData);
     },
 
     /**
     *  @Description: set the attributes when the user cancel the component
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setCancelButtonAttributes : function (component, event) {
         component.set('v.caseComponentVisibility', false);
         component.set("v.detailRsvIsOpen", false);
         let isFromHeader = component.get("v.isFromHeader");
         if (isFromHeader) {
             component.set("v.headerIsOpen", true);
         }
     },
 
     /**
     *  @Description: Set the attributes of the Component for Case Creation Component
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        09/12/2020
     */
    setCaseCreationComponentAttributes: function(component, event, helper) {
         component.set("v.detailRsvIsOpen", false);
         component.set("v.caseVisibility", true);
     },

    
     /**
     *  @Description: Set the attributes of the Component after the user selects a Product
     *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
     *  @Date:        05/01/2021
     */
     setProductVisibilityAttributes: function(component, event) {
        component.set("v.detailRsvIsOpen", false);
        component.set("v.productVisibility", true);  
     },
     
 
     /**
     *  @Description: Initialize the attributes of the Component
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setPanelComponentAttributes: function(component, event, objComponentData) {
         component.set('v.lstReserveNumbers', objComponentData.getListOfReserves());
     },
 
     /**
     *  @Description: Set the attributes of the Component after the user selects a Reserve
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setDetailComponentAttributes: function(component, event, objComponentData) {
         let strSelectedReserveNumber =  event.getParam('reserveNumber');
         let objPurchaseObjectData = objComponentData.getPurchaseObjectData(strSelectedReserveNumber);
         this.setDataComponentAttributes(component, event, objComponentData);
 
         if(!$A.util.isEmpty(objPurchaseObjectData)) {
             
             component.set('v.objPurchaseData', objPurchaseObjectData);
         }
         
     },
 
    /**
    *  @Description: Set the attributes of the Component after the user selects a Product
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        05/01/2021
    */
    setProductComponentAttributes: function(component, event) {
        let objProductData =  event.getParam('productData');
        component.set('v.productDataObject',objProductData);

        this.setProductVisibilityAttributes(component, event);
    },

     /**
     *  @Description: Initialize the description object for Reserve and Products
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
     */
    setObjectDescription: function(component, event, helper)  {
         // get the methods on the apex controller
         let cmpReserve = component.get( "c.getDescriptionForReserve" );
         let cmpProductForReserve = component.get( "c.getColumnsForProductsPurchaseOrders" );
         let btnViewDetails = component.get( "c.setPrdButton" );
         let cmpSellDocument = component.get( "c.getDescriptionForSellDocument" );
         let cmpProductForDocument = component.get( "c.getColumnsForProductsPaymentVouchers" );
         
         // set the promise including the async call to both methods
         Promise.all([this.serverSideCall(component, cmpReserve), 
                      this.serverSideCall(component, cmpProductForReserve), 
                      this.serverSideCall(component, btnViewDetails),
                      this.serverSideCall(component, cmpSellDocument),
                      this.serverSideCall(component, cmpProductForDocument)])
         .then(
             $A.getCallback( function (result) {
                 let rspReserve = result[0];
                 let rspProductForReserves = result[1];
                 let rspViewDetail = result[2];
                 let rspSellDocument = result[3];
                 let rspProductForDocument = result[4];
 
                 //get the component object reference
                 let objComponentData = component.get("v.purchaseDataComponent");
 
                 //set the reserve description to the component object
                 objComponentData.setReserveDescription(JSON.parse(rspReserve));
                 rspProductForReserves.splice(0,0, rspViewDetail);
                 objComponentData.setProductDescription(rspProductForReserves);
                 objComponentData.setDocumentDescription(JSON.parse(rspSellDocument));
                 objComponentData.setProductForDocumentDescription(rspProductForDocument);

                 helper.setDataComponentAttributes(component, event, objComponentData);
 
                 // set the component data and fire the component is ready
                 helper.setReadyComponentAttributes(component, event, objComponentData);
                 helper.setPanelComponentAttributes(component, event, objComponentData);
             })
         )
         .catch(error => {
             console.error(error.toString());
             let errorObject = JSON.parse(error.message);
             helper.fireAlertComponentError(component, event, errorObject.name, errorObject.message + " (Codigo: " + errorObject.code + ")", "error");
         
             let objComponentData = component.get("v.purchaseDataComponent");
             objComponentData.setLoadedComponent();
             helper.setDataComponentAttributes(component, event, objComponentData);
             helper.setCancelButtonAttributes(component, event);
         });
     },
 
     /**
     *  @Description: Show an Alert in case an error when calling the server
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        05/11/2020
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
     },
 
     /**
     *  @Description: Promise to call APEX controller
     *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
     *  @Date:        03/08/2020
     */
    serverSideCall: function (component, action) {
         return new Promise((resolve, reject) => {
             action.setCallback(this, response => {
                 var state = response.getState();                
                 if (state === "SUCCESS") {
                     resolve(response.getReturnValue());
                 } else {
                     reject(new Error(response.getError()[0].message));
                 }
             });
             $A.enqueueAction(action);
         });
     }
 
 })