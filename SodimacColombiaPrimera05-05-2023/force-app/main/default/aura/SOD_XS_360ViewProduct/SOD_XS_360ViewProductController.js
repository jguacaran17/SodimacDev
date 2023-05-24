/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 09/12/2020
Description  : Javascript Controller - 360 view of a client: Products
History      : CMRSC-3932
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade Alviarez	EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			09/12/2020		initial version
********************************************************************************/
({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        09/12/2020
    */
    doInit: function (component, event, helper) {
        helper.getInitClass(component, event);
    },
    /**
    *  @Description: Handle the action back of button
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        09/12/2020
    */
    handleBackButton: function (component, event, helper) {
        helper.setComponentVisivility(component, event);
    }
})