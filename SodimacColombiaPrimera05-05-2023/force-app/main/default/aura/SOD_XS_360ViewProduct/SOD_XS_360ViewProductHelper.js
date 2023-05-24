/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/12/2020
Description  : Javascript Helper - 360 view of a Product
History      : CMRSC-3932
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Eilhert Andrade A.			EAA
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      EAA			17/12/2020		initial version
********************************************************************************/
({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        17/12/2020
    */
    getInitClass: function(component, event, helper) {
            let action = component.get( "c.initClass" );
            action.setParams({
                reserveNumber : component.get("v.reserveNumber"),
                sku  : component.get("v.sku"),
                countryCode : component.get("v.countryCode")
            });

            Promise.all([this.serverSideCall(component, action)])
            .then(
                $A.getCallback(response => {

                    component.set('v.columns', response[0].prdLabelsTable);           
                    component.set('v.data', window.jsFlattenEach(JSON.parse(response[0].dataJson).ArrayOfSkuReserveEvents));
                })
            )
            .catch(error => {
                console.log("Error: " + error.message);
            });
        },

    /**
    *  @Description: Promise to call APEX controller
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        21/12/2020
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
    *  @Description: Handle the visibility of components
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        05/01/2021
    */
    setComponentVisivility: function (component, event) {
            component.set("v.productVisibility", false);
            component.set("v.detailRsvIsOpen", true);  
    }
})