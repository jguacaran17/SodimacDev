/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Controller - 360 view of a client: Detail of a Reserve
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
    *  @Description: Show an Alert in case the reserve has Childs
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   doInit: function(component, event, helper) {
        let objComponentData = component.get('v.dataPurchase'); // Data received from parent component
        let objComponentObject;
        if(!$A.util.isEmpty(objComponentData)) {
            objComponentObject = helper.getComponentDataObject(component, helper, objComponentData);
            helper.setComponentAttributes(component, event, objComponentObject);                       
        }
    },
    
    /**
    *  @Description: Handle the row selection on the table
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   handleSaveSelection: function(component, event, helper) {        
        let selectedRows = component.find('datatable1').getSelectedRows();
        let selectedIds = [];

        selectedRows.forEach( function(row) {
            selectedIds.push(row.SOD_XS_Key);
        });
        
        let draftValues = event.getParam('draftValues');            
        let objComponentData = component.get("v.objReserveComponent");
        let objError = helper.validateProductSelection(draftValues, selectedIds, objComponentData, helper);

        if (!$A.util.isEmpty(objError)) {
            helper.setErrorAttributes(component, event, objError)
        }
        else {
            let lstRemoved = objComponentData.checkProductsRemoved(selectedIds);
            objComponentData.removeProductSelection(lstRemoved);
            objComponentData.saveProductSelection(draftValues);

            helper.setSaveAttributes(component, event, objComponentData);
        }       
    },

    /**
    *  @Description: Handle the row selection on the table for generating draft values
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   handleRowSelection: function(component, event, helper) {
        let objComponentData = component.get("v.objReserveComponent");
        let selectedRows = event.getParam('selectedRows');
        let selectedIds = [];

        selectedRows.forEach( function(row) {
            selectedIds.push(row.SOD_XS_Key);
        });  

        let lstRemoved = objComponentData.checkProductsRemoved(selectedIds);
        if(lstRemoved.length > 0) {
            objComponentData.removeProductSelection(lstRemoved);
            helper.setDeselectionAttributes(component, event, objComponentData);
        }
    },

    /**
    *  @Description: Handle the row selection on the table for generating draft values
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        05/01/2021
    */
    handleRowAction: function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        //shows the header of the selected order
        switch (action.name) {
            case 'view_product': 
            helper.showRowDetails(component, event, row);
                break;
            default:
                break;
            }
        }
})