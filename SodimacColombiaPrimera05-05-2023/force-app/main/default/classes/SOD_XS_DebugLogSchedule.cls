/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 18/03/2021
Description  : Schedule apex for ejecute batch apex SOD_XS_DebugLogBatchSchedule.
History      : CMRSC-5119
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Nelson Lepiqueo			    NL
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      NL			18/03/2021		Created the file/class
********************************************************************************/
global class SOD_XS_DebugLogSchedule implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        SOD_XS_DebugLogBatchSchedule batchLog = new SOD_XS_DebugLogBatchSchedule ();

        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(batchLog,200);
    }

}