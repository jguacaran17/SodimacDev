/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : FTC
Created Date : 02/02/2022
Description  : Trigger Handler class for Log Event object
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodolfo Valencia Tapia			RVT
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RVT			02/02/2022		Initial definition of the class.
********************************************************************************/

public with sharing class SOD_XS_LogEventTriggerHandler extends SOD_XS_AbstractTriggerHandler{

    private static Integer logCounter = 0;

    public static String generateLogIdentifier(){
        String paddedCounter = String.valueOf(logCounter).leftPad(4, '0');
        String logIdentifier = 'LOG-' + Datetime.now().format('yyMMddHHmmss'+paddedCounter, 'UTC');
        logCounter++;
        return logIdentifier;
    }

    public override void afterInsert() {
        List<SOD_XS_RegistroDepuracion__c> registrosDepuracion = new List<SOD_XS_RegistroDepuracion__c>();
        List<SOD_XS_LogEvent__e> logs = Trigger.new;
        for(SOD_XS_LogEvent__e logEvent : logs){
            try {
                SOD_XS_RegistroDepuracion__c registroDepuracion = (SOD_XS_RegistroDepuracion__c)JSON.deserialize(logEvent.SOD_XS_Log__c, SObject.class);
                registrosDepuracion.add(registroDepuracion);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
        if(!registrosDepuracion.isEmpty()){
            insert registrosDepuracion;
        }
    }
    
}