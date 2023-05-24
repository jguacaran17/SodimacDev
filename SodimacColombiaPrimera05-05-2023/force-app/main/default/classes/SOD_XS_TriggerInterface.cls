/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 19/10/2018
Description  : SOD_XS_TriggerInterface
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Felipe Paulino			    FP
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FP			19/10/2018		Created the file/class
********************************************************************************/

public interface SOD_XS_TriggerInterface
{
    void beforeBulk();
    void afterBulk(); 
    void beforeInsert(); 
    void beforeUpdate();
    void beforeDelete();
    void afterInsert();
    void afterUpdate();
    void afterDelete();
    void afterUndelete();
    void andFinally();
}