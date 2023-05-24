/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/07/2020
Description  : Helper Controller - Creating and updating clients(BUC)
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
        let init = component.get( "c.initClass" );
        init.setParams({
            rcdId : component.get("v.recordId")
        });
        Promise.all([this.serverSideCall(component, init)])
        .then(
            $A.getCallback(response => {
                component.set('v.accRcd', response[0].acc);
                if (response[0].rsp == 404) {
                	this.getCreateClient(component, event, helper);
            	}
        	})
        )
        .catch(error => {
            console.log("Error: " + error.message);
        });
    },
    /**
    *  @Description: Create client in BUC
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        03/08/2020
    */
    getCreateClient: function(component, event, helper) {
        let crt = component.get( "c.createClientBUC" );
        crt.setParams({
            acc : component.get("v.accRcd")
        });
        Promise.all([this.serverSideCall(component, crt)])
        .then(
            $A.getCallback(response => {})
        )
        .catch(error => {
            console.log("Error: " + error.message);			
        });
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
    }
})