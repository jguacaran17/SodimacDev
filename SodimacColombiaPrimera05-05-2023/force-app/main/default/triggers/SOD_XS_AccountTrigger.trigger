/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 22/10/2020
Description  : Trigger class for Account object (data update for BUC)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO			22/10/2020		Initial definition of the class.
1.1      RSO			03/12/2020		Custom Setting Bypass added.
********************************************************************************/

trigger SOD_XS_AccountTrigger on Account (before insert, after insert, before update, after update) {
    if(!SOD_XS_Bypass__c.getInstance().SOD_XS_DesactivarTriggers__c)
    {
        new SOD_XS_TriggerHandler(Account.sObjectType).Run();
    }
}