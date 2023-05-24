/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : FTC
Created Date : 19/08/2021
Description  : Test Class for Task Trigger Handler
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodolfo Valencia            RV
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RV         19/08/2021          Initial TEST class
********************************************************************************/

@isTest
public class SOD_XS_TaskTriggerHandler_TEST {
    
    @isTest
    static void taskTriggerDeleteTest(){
       
        try{
            Account accRecord = SOD_XS_DataFactory.createAccountXS(true, 'Business_Account', 'RUT', '11934773-4','CL');
            Task tskRecord = SOD_XS_DataFactory.createTask(accRecord.Id);
            Test.startTest();
                delete tskRecord;
            Test.stopTest(); 
        }catch(DMLexception e){
            Boolean deleteFailed = (e.getMessage().contains('no se puede eliminar') || e.getMessage().contains('Delete failed'));
            System.assert(deleteFailed,'La tarea no se puede eliminar');
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }

}