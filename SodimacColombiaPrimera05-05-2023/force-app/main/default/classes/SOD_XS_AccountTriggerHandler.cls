/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 22/10/2020
Description  : Trigger Handler class for Account object (data update for BUC)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO			22/10/2020		Initial definition of the class.
1.1      ATO			17/12/2020		Fix cognitive complexity.
1.2      ATO			17/12/2020		afterInsert method is added.
********************************************************************************/

public with sharing class SOD_XS_AccountTriggerHandler extends SOD_XS_AbstractTriggerHandler{

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        17/12/2020
    */
    private static Boolean isFirstTime = true;
    private static Integer typeUpdate = 0; // 1 = Update, 2 = update + delete selected fields, 3 = delete selected fields
    private static List<String> idFieldDel = new List<String>(); //list of Id's field to be deleted
    /**
    *  @description Before object insert preparations
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    public override void beforeInsert(){
        updateFieldsAccount();
        
    }

    /**
    *  @description After object Insert preparations
    *  @author      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @date        17/12/2020
    */
    public override void afterInsert() {
        List<Account> accs = Trigger.new;
        for (Account accObj : accs) {
            // Check if it is the first time and if it has an external id
            if (isFirstTime && String.isNotBlank(accObj.SOD_XS_IdExterno__c)) {
                // Updating clients in the BUC
                SOD_XS_UpsertClientsBUCController.enqueueUpdateClientBUC(accs, null);
                isFirstTime = false;
            }
            
        }
    }
    
    /**
    *  @description Before object update preparations
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    public override void beforeUpdate(){
        updateFieldsAccount();

    }

    /**
    *  @description After object Update preparations
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    public override void afterUpdate(){
        List<Account> accs= Trigger.new;
        Map<Id,Account> oldMapAccount = (Map<Id,Account>) Trigger.oldMap;

        for (Account accObj : accs) {
            // Check isFirstTime, any field has been updated, SOD_XS_IdExterno__c exists and SOD_XS_ActualizacionPorIntegracion__c is false
            if (isFirstTime && checkUpdatedAccount(accObj, oldMapAccount.get(accObj.Id)) 
                && String.isNotBlank(accObj.SOD_XS_IdExterno__c) && !accObj.SOD_XS_ActualizacionPorIntegracion__c) {                
                    //only update
                if(typeUpdate == 1){
                    // Updating clients in the BUC
                    SOD_XS_UpsertClientsBUCController.enqueueUpdateClientBUC(accs, null);
                } else if(typeUpdate == 2){
                    //first update
                    SOD_XS_UpsertClientsBUCController.enqueueUpdateClientBUC(accs, null);
                    //and finaly delete selected fields
                    for(String idDel : idFieldDel){
                        SOD_XS_UpsertClientsBUCController.enqueueUpdateClientBUC(accs, idDel);
                    }
                } else if(typeUpdate == 3){
                    //delete selected fields
                    for(String idDel : idFieldDel){
                        SOD_XS_UpsertClientsBUCController.enqueueUpdateClientBUC(accs, idDel);
                    }
                }
            }
            isFirstTime = false;
        }
    }

    /**
    *  @description Update the fields on Account object for Before opperations
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    private void updateFieldsAccount(){
        List<Account> accs= Trigger.new;
        Map<String, List<String>> fieldMapUpper = new Map<String, List<String>>();
        fieldMapUpper.put(SOD_XS_ClientsConstant.PBC_STR_B2C, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2CUPPERCASE));
        fieldMapUpper.put(SOD_XS_ClientsConstant.PBC_STR_B2B, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2BUPPERCASE));
        Map<String, List<String>> fieldMapLower = new Map<String, List<String>>();
        fieldMapLower.put(SOD_XS_ClientsConstant.PBC_STR_B2C, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2CLOWERCASE));
        fieldMapLower.put(SOD_XS_ClientsConstant.PBC_STR_B2B, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2BLOWERCASE));
        for (Account accObject : accs) {
            for (String fieldname : fieldMapUpper.get(SOD_XS_ClientsConstant.PBC_MAP_RCT.get(accObject.RecordTypeId).getDeveloperName())) {
                if (String.isNotBlank((String)accObject.get(fieldname)) && !((String)accObject.get(fieldname)).equals(((String)accObject.get(fieldname)).toUpperCase())) {
                    accObject.put(fieldname, ((String)accObject.get(fieldname)).toUpperCase());
                }
            }
            for (String fieldname : fieldMapLower.get(SOD_XS_ClientsConstant.PBC_MAP_RCT.get(accObject.RecordTypeId).getDeveloperName())) {
                if (String.isNotBlank((String)accObject.get(fieldname)) && !((String)accObject.get(fieldname)).equals(((String)accObject.get(fieldname)).toUpperCase())) {
                    accObject.put(fieldname, ((String)accObject.get(fieldname)).toUpperCase());
                }
            }
        }
    }

    /**
    *  @description check if the Account record was updated by the user
    *  @author      Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @date        27/10/2020
    */
    private Boolean checkUpdatedAccount(Account accNew, Account accOld) {
        Map<String, List<String>> fieldMap = new Map<String, List<String>>();
        fieldMap.put(SOD_XS_ClientsConstant.PBC_STR_B2C, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2CVALIDATE));
        fieldMap.put(SOD_XS_ClientsConstant.PBC_STR_B2B, fillFieldsList(SOD_XS_ClientsConstant.PBC_STR_FIELDSB2BVALIDATE));
        Boolean result = false;
        for (String fieldname : fieldMap.get(SOD_XS_ClientsConstant.PBC_MAP_RCT.get(accNew.RecordTypeId).getDeveloperName())) {
            if (accNew.get(fieldname) != accOld.get(fieldname)) {
                result = true;
                //if this fields are blank, must be deleted

                if( (fieldname == 'PersonMobilePhone' && accNew.get(fieldname) == null) || (fieldname == 'PersonHomePhone' && accNew.get(fieldname) == null) || (fieldname == 'PersonEmail' && accNew.get(fieldname) == null) ){
                    
                    if(typeUpdate == 0) { typeUpdate = 3; } //only delete selected fields
                    else if(typeUpdate == 1) {typeUpdate = 2; }//update some fields and delete selected fields

                    if(fieldname == 'PersonHomePhone'){ idFieldDel.add(String.valueOf(accOld.SOD_XS_IdPersonHomePhone__c)); }
                    else if(fieldname == 'PersonEmail'){ idFieldDel.add(String.valueOf(accOld.SOD_XS_IdPersonEmail__c));}
                    else{idFieldDel.add(String.valueOf(accOld.SOD_XS_IdPersonMobilePhone__c));}

                }else{
                    if(typeUpdate == 0) {typeUpdate = 1; }//only update
                    else if(typeUpdate == 3) {typeUpdate = 2; } //update some fields and delete selected fields
                }
            }
        }
        return result;
    }

    /**
    *  @Description: Fill the list of fields
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        17/12/2020
    */    
    private static List<String> fillFieldsList(String fields) {
        List<String> str = new List<String>();
        if (!String.isEmpty(fields)) {
            String[] splitStr = fields.Split(SOD_XS_ClientsConstant.PBC_STR_COMMA);
            for (String c : splitStr) {
                str.add(c);
            }
        }
        return str;
    }

}