/*******************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/03/2021
Description  : Lightning component - 360 view: Case Creation For Special Services
History      : CMRSC-4891
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      RSO			18/03/2021		initial version
********************************************************************************/

({
    /**
    *  @Description: Initialize all variables in lightning component
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    doInit : function(component, event, helper) {
        let objCaseData = component.get('v.objCaseData');

        let objComponentData;
        if(!$A.util.isEmpty(objCaseData)) {
            objComponentData = helper.setComponentDataObject(component, helper, objCaseData);
            helper.setDataComponentAttributes(component, event, objComponentData);
            helper.setObjectDescription(component, event, helper);
        }
    },

    /**
    *  @Description: Handle the selection of the record type
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    onChangeRecordType: function (component, event, helper) {
        let rt = component.find('select').get('v.value');
        helper.setRecordTypeSelectedAttributes(component, event, rt);
    },

    /**
    *  @Description: Handle the selection of the record type
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
     onFormLoaded: function (component, event, helper) {
        helper.setFieldFormLoadedtAttributes(component, event);
    },
    
    /**
    *  @Description: Handle the selection of the record type
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
    onRecordSubmit : function(component, event, helper) {    
        event.preventDefault(); // stop form submission
        let data = event.getParam("fields");
        helper.setFieldSelectedAttributes(component, event, data);
    },

    /**
    *  @Description: Handle the selection of the record type
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
     onFormErrorLoad: function (component, event, helper) {
       helper.setErrorFormLoadedtAttributes(component, event);
   },

    /**
    *  @Description: Handle the selection of the record type
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        09/12/2020
    */
     onFormErrorSubmit : function(component, event, helper) {    
        event.preventDefault(); // stop form submission
        let data = event.getParam("fields");
        helper.setErrorSelectedAttributes(component, event, data);
        helper.setCaseProcessingComponentAttributes(component, event);
        helper.processCaseData(component, event, helper);
    },

    /**
    *  @Description: Handle the create button action
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    handleCreateButton: function (component, event, helper) {
        let rt = component.find('select').get('v.value');
        if(rt) {
            let objComponentData = component.get('v.objCaseDataComponent');
            // If the Case is different from a "Consulta" and the confirmation is needed
            if ( !objComponentData.boolRecordTypeConsultaSelected 
                 && helper.isConfirmationNeeded(component, event, objComponentData)) {
                // the confirm dialog is shown
                component.set('v.caseConfirmationVisibility', !component.get('v.caseConfirmationVisibility'));
                component.set('v.caseContentVisibility', !component.get('v.caseContentVisibility'));
            }
            else {
                helper.setCaseProcessingComponentAttributes(component, event);
                helper.processCaseData(component, event, helper);
            }
            
        }
    },

    /**
    *  @Description: Handle the cancel button action
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
   handleCancelButton: function (component, event, helper) {
        helper.setCancelComponentAttributes(component, event);
    },

    /**
    *  @Description: Handle the modal confirmation button action
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        18/03/2021
    */
    handleConfirmationButton: function (component, event, helper) {
        helper.setCaseProcessingComponentAttributes(component, event);
        helper.processCaseData(component, event, helper);
    }
    
})