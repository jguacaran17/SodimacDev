trigger SOD_XS_LogEventTrigger on SOD_XS_LogEvent__e (after insert) {
    if(!SOD_XS_Bypass__c.getInstance().SOD_XS_DesactivarTriggers__c){
        new SOD_XS_TriggerHandler(SOD_XS_LogEvent__e.sObjectType).Run();
    }
}