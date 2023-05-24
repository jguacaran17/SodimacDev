/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Controller - 360 view of a client: Reserves
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
    doInit : function(component, event, helper) {
        let dataObject = component.get('v.dataObject');
        let objComponentData;

        if( !$A.util.isEmpty(dataObject) ) {
            objComponentData = helper.setComponentDataObject(component, helper, dataObject);
            let labelObject = helper.getLabelObject(component, event, objComponentData);
            helper.setLabelsComponentAttributes(component, event, labelObject);
            helper.setDataComponentAttributes(component, event, objComponentData);

            if($A.util.isEmpty(component.get('v.objReserveDescription')) 
               || $A.util.isEmpty(component.get('v.objProductDescription')) ) {
                    
                // Async function is set
                helper.setObjectDescription(component, event, helper);
            }
        }
    },

    /**
    *  @Description: handle the event fired from the panel when the user selects a reserve
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    handlePanelReserveSelection : function (component, event, helper) {
        let objComponentData = component.get('v.purchaseDataComponent');    
        helper.setDetailComponentAttributes(component, event, objComponentData);
    },

    /**
    *  @Description: handle the create case action
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   handleCreateButton: function (component, event, helper) {
        helper.setCaseCreationComponentAttributes(component, event, helper);
    },

    /**
    *  @Description: handle the cancel button
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   handleCancelButton: function (component, event, helper) {
        helper.setCancelButtonAttributes(component, event);
        
    },
    
    /**
    *  @Description: handle the Product Selection
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        05/01/2021
    */
    handleProductSelection: function (component, event, helper) {
        helper.setProductComponentAttributes(component, event);
    }

})