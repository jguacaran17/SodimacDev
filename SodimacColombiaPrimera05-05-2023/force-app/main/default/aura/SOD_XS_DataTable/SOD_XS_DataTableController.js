/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 27/10/2020
Description  : Javascript Controller - Generic data table for complex object structures.
History      :
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/10/2020		initial version
********************************************************************************/
({
  	/**
  	*  @Description: Used to handle jsHandleSort method
  	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
  	*  @Date:        27/10/2020
  	*/	
    handleSort: function(component, event, helper) {
        //Sort items in ascending or descending order
        window.jsHandleSort(component, event);
    },
    /**
    *  @Description: Used to handle row action
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        27/10/2020
    */
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        //shows the header of the selected order
        switch (action.name) {
            case 'view_headers':
                helper.showRowDetails(cmp, event, row);
                break;
            case 'view_projectDetail':
                helper.showProjectDetail(cmp, event, row);
                break;
            case 'view_subProjectDetail':
                helper.showSubProjectDetail(cmp, event, row);                
                break;
            default:
                break;
        }
    },
    /**
    *  @Description: Used to handle row selection
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/11/2020
    */	
    updateSelected: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        cmp.set('v.selectedReserve', selectedRows);
    }    
})