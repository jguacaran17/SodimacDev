/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : FTC
Created Date : 18/08/2021
Description  : Task Trigger definition
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodolfo Valencia            RV
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RV         18/08/2021          Initial class definition
********************************************************************************/

trigger SOD_XS_TaskTrigger on Task (before delete) {
    if(SOD_XS_Bypass__c.getInstance().SOD_XS_DesactivarTriggers__c) {
            System.debug('Bypassing trigger due to custom setting');
            return;
        } else { 
        new SOD_XS_TriggerHandler(Task.sObjectType).Run();
    }
}