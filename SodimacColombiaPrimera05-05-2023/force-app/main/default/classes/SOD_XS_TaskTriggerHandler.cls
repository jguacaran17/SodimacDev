/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : FTC
Created Date : 18/08/2021
Description  : Trigger Handler class for Task
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodolfo Valencia               RV
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RV         18/08/2021          Initial definition of the class.
********************************************************************************/

public with sharing class SOD_XS_TaskTriggerHandler extends SOD_XS_AbstractTriggerHandler{
    private List<Task> lstTasks; 
    private Boolean canDeleteTasks = FeatureManagement.checkPermission('SOD_XS_CanDeleteTasks');
    
    /**
    *  @description Before object delete preparations
    *  @author      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @date        18/08/2021
    */
    public override void beforeDelete(){
        if(!canDeleteTasks){
            lstTasks = (List<Task>) Trigger.old;
            for(Task tsk : lstTasks){
                tsk.adderror('La tarea no se puede eliminar');
            }
        }
    }
}