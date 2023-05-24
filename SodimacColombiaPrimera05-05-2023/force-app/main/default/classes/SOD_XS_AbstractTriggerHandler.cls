/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 19/10/2018
Description  : Abstract class of trigger events
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Felipe Paulino			    FP
Rodrigo Salinas Oye         RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FP			19/10/2018		    Created the file/class
1.1      RSO		03/09/2020		    Deprecated methods
********************************************************************************/

public with sharing abstract class SOD_XS_AbstractTriggerHandler implements SOD_XS_TriggerInterface{
    
    public virtual void beforeBulk(){}
    public virtual void afterBulk(){}
    public virtual void beforeInsert(){}
    public virtual void beforeUpdate(){}
    public virtual void beforeDelete(){}
    public virtual void afterInsert(){}
    public virtual void afterUpdate(){}
    public virtual void afterDelete(){}
    public virtual void afterUndelete(){}
    public virtual void andFinally(){}
    
    /**
    * @Description   Indicate if the field has changed; returns true for insert trigger
    * @Author        Felipe Paulino
    * @Date   19/10/2018
    */
    public Boolean isChanged(SObject obj, String field)
    {
        SObject oldObj = Trigger.oldMap == null ? null : Trigger.oldMap.get(obj.Id);
        
        return ((String.isBlank(obj.Id)) || (oldObj == null))
            ? true : (oldObj.get(field) != obj.get(field));
    }
}