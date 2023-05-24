/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Javascript Helper - Customer search(BUC)
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
    getInitClass: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        let init = component.get( "c.initClass" );
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {                
                component.set('v.ObjectType', JSON.parse(response[0].accLabels));
                component.set('v.docTypeObj', response[0].docType);
                component.set('v.lstOfRecordType', response[0].rcdTypeValues);
                component.set('v.sldRcdPais', response[0].dftCnt);
                component.set('v.rcdNameCaseFLC', response[0].rcdTypeCaseFLC);
                component.set('v.rcdNameCaseCNS', response[0].rcdTypeCaseCNS);
                component.set('v.loaded', !component.get('v.loaded'));
        	})
        )
        .catch(error => {
            var errors = JSON.parse(error.message);
            this.popEvent(errors.name, errors.message, "error", parseInt($A.get("$Label.c.SOD_XS_DuracionBUCYSFDC")));
            console.log("Error: " + errors.message);
            component.set('v.loaded', !component.get('v.loaded'));
        });
   },
   /**
   *  @Description: Search the customer in the BUC and then in Salesforce
   *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
   *  @Date:        03/08/2020
   */
   getClient: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        let Client = component.get( "c.searchClientBUC" );
        Client.setParams({
            docType : component.get("v.accRcd.SOD_XS_TipoDocumento__c"),
            docNumber : component.get("v.accRcd.SOD_XS_NroDocumento__c"),
            cntCode : component.get("v.sldRcdPais.SOD_XS_Codigo__c")
        });
        Promise.all([this.serverSideCall(component, Client)])
        .then(
            $A.getCallback(response => {
                component.set('v.accJson', JSON.stringify(JSON.parse(response)));
                this.getAccount(component, event, helper);
            })).catch(error => {                
                var errors = JSON.parse(error.message);
                if (errors.code == 404 || errors.code == 500 || errors.code == 503) {
                    component.set('v.accJson', errors.message);
                }
                errors.message = $A.util.isEmpty(errors.message) ? 'Error en la Integración de Búsqueda de Clientes' : error.message;
                console.error("Error: " + errors.message);
                this.popEvent(errors.name, errors.message, "error", parseInt($A.get("$Label.c.SOD_XS_DuracionBUCYSFDC")));
                this.getAccount(component, event, helper);
                component.set('v.loaded', !component.get('v.loaded'));

            });
   },
   /**
   *  @Description: Get record types for an account
   *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
   *  @Date:        03/08/2020
   */
   getRcdType: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        let rcd = component.get( "c.getRecTypeMap" );
        rcd.setParams({recordTypeLabel : component.get("v.sldRcdName")});
        Promise.all([this.serverSideCall(component, rcd)])
        .then(
            $A.getCallback(response => {
                for(var key in response[0]) {
                    component.set('v.sldRcdDevName', key);
                    component.set('v.selectedRecordId', response[0][key]);
                }
                component.set('v.loaded', !component.get('v.loaded'));
            })).catch(error => {
                var errors = JSON.parse(error.message);
                this.popEvent(errors.name, errors.message, "error", parseInt($A.get("$Label.c.SOD_XS_DuracionBUCYSFDC")));
                console.log("Error: " + errors.message);
                component.set('v.loaded', !component.get('v.loaded'));
            });
   },
   /**
   *  @Description: Get the client, if it exists(SFCD Or BUC) it redirects to view360,
   *                if it does not exist the client redirects to the client creation page.
   *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
   *  @Date:        03/08/2020
   */
   getAccount: function(component, event, helper) {
        let action = component.get("c.newRcdAcc");
        action.setParams({
            jsonObj : component.get("v.accJson"),
            docTypeSFDC : component.get("v.accRcd.SOD_XS_TipoDocumento__c"),
            docNumSFCD: component.get("v.accRcd.SOD_XS_NroDocumento__c"),
            rcdCnt : component.get("v.sldRcdPais"),
            rcdType : component.get("v.selectedRecordId")
        });

        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                component.set('v.loaded', !component.get('v.loaded'));
                this.getPupUpBUC(response.getReturnValue().acc.SOD_XS_RegistradoBUC__c, response.getReturnValue().exists);

                // If the client exists it redirects to the 360 ​​view
                if (response.getReturnValue().exists) {
                    var urlRedirect = $A.get("e.force:navigateToURL");
                    urlRedirect.setParams({ url: "/lightning/r/Account/" + response.getReturnValue().acc.Id + "/view" });
                    urlRedirect.fire();
                    $A.get('e.force:refreshView').fire();
                }
                // If the client does not exist redirects to the creation page
                else {                   
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Account",
                        "recordTypeId": component.get("v.selectedRecordId"),
                        "defaultFieldValues": response.getReturnValue().acc
                    });
                    createRecordEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                var errors = JSON.parse(response.getError()[0].message);
                this.popEvent("Error", "Problemas con la Integración, consulte con su administrador Salesforce", "error", 5000);
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });       
        $A.enqueueAction(action);
    },
    /**
    *  @Description: Promise to call APEX controller
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
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
    *  @Description: Get the url of the case and redirect to the case creation page
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    getCase: function (component, event, rcdName) {
        component.set('v.loaded', !component.get('v.loaded'));
        var newRcd = component.get("c.newRcdCase");
        newRcd.setParams({devName : rcdName});
        newRcd.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                component.set('v.loaded', !component.get('v.loaded'));
                var urlRedirect = $A.get("e.force:navigateToURL");
                urlRedirect.setParams({ url: response.getReturnValue() });
                urlRedirect.fire();
            } else {
                var errors = JSON.parse(response.getError()[0].message);
                this.popEvent(errors.name, errors.message, "error", parseInt($A.get("$Label.c.SOD_XS_DuracionBUCYSFDC")));
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
    	$A.enqueueAction(newRcd);
    },
    /**
    *  @Description: Opens pop-up for customer search
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    getPupUpBUC: function (existsBUC, existsSFCD) {
        var time = parseInt($A.get("$Label.c.SOD_XS_DuracionBUCYSFDC"));
        if (existsBUC && existsSFCD) {
            this.popEvent($A.get("$Label.c.SOD_XS_TituloBUCYSFCD"), $A.get("$Label.c.SOD_XS_ClienteExisteBUCYSFDC"), "success", time);
        } else if (existsBUC && !existsSFCD) {
            this.popEvent($A.get("$Label.c.SOD_XS_TituloBUCYSFCD"), $A.get("$Label.c.SOD_XS_ClienteExisteBUC"), "info", time);
        } else if (!existsBUC && existsSFCD) {
            this.popEvent($A.get("$Label.c.SOD_XS_TituloBUCYSFCD"), $A.get("$Label.c.SOD_XS_ClienteExisteSFCD"), "info", time);
        } else if (!existsBUC && !existsSFCD) {
            this.popEvent($A.get("$Label.c.SOD_XS_TituloBUCYSFCD"), $A.get("$Label.c.SOD_XS_ClienteNoExiste"), "warning", time);
        }       
    },
    /**
    *  @Description: Raise a Toast
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
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
    }
})