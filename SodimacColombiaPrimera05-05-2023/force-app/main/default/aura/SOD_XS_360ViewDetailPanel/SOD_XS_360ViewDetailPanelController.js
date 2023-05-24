/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Controller - 360 view of a client: Panel for Reserves Lists
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
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    doInit: function (component, event, helper) {
        let lstData = component.get('v.lstReserveNumbers')
        let objComponentObject;
        if(!$A.util.isEmpty(lstData)) {
            objComponentObject = helper.getComponentDataObject(component, helper, lstData);
            helper.setPanelAttributes(component, objComponentObject);
            helper.fireSelectEvent(component, objComponentObject.getSelectedItem());
        }
    },

    /**
    *  @Description: Handle the selection made on the panel and fire the event
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    handleSelect: function(component, event, helper) {
        let strSelection = event.getParam('name');
        let objComponentObject = component.get("v.objComponentData");

        objComponentObject.setSelectedItem(strSelection);
        helper.setPanelAttributes(component, objComponentObject);
        helper.fireSelectEvent(component, strSelection);              // firing the event.
    }
})