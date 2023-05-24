/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 19/10/2018
Description  : SOD_XS_TriggerHandler
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Felipe Paulino			    FP
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FP			19/10/2018		Created the file/class
********************************************************************************/

public without sharing class SOD_XS_TriggerHandler {
    private static Map<String, TriggerCfg> handlers = new Map<String, TriggerCfg>();
    private String sObjName;
    
    static
    {
        if (handlers.isEmpty()){
            for(TriggerConfig__mdt t : [SELECT Active__c,Handler_Name__c, SObject__c FROM TriggerConfig__mdt ORDER BY Order__c ASC]){
                handlers.put(t.SObject__c, new TriggerCfg(t));
            }
        }
    }
    
    /**
    * @Description Get Name of object
    * @Author      Felipe Paulino
    * @Date        26/03/2021
    */
    public SOD_XS_TriggerHandler(Schema.SObjectType soType){
        this.sObjName = soType.getDescribe().getName();
    }
    
    /**
    * @Description   Create Trigger handler and execute
    * @Author        Felipe Paulino
    * @Date   20/10/2018
    */
    public void Run()
    {
        try{
            if (isHandlerEnabled()){
                execute(getHandler());
            }
        }catch(Exception ex){
            throw new SOD_XS_TriggerException(ex.getMessage());
        }
    }
    
    
    /***
    * @Description   Get trigger handler for sObject
    * @Author        Felipe Paulino
    * @Date   20/10/2018
    */
    private SOD_XS_TriggerInterface getHandler(){
        return (SOD_XS_TriggerInterface)Type.forName(handlers.get(sObjName).handlerName).newInstance();
    } 
    
    /**
    * @Description   Check Trigger Status
    * @Author        Felipe Paulino
    * @Date   20/10/2018
    */
    private Boolean isHandlerEnabled(){
        return handlers.get(sObjName).isActive;
    }
    
    /**
    * @Description   Get trigger handler for sObject
    * @Author        Felipe Paulino
    * @Date   20/10/2018
    */
    private void execute(SOD_XS_TriggerInterface handler)
    {
        if(Trigger.isBefore) {
            handler.beforeBulk();
            if     (Trigger.isDelete)    handler.beforeDelete();
            else if(Trigger.isInsert)    handler.beforeInsert();
            else if(Trigger.isUpdate)    handler.beforeUpdate();            
        }
        else {
            handler.afterBulk();
            if      (Trigger.isDelete)   handler.afterDelete();
            else if (Trigger.isInsert)   handler.afterInsert();
            else if (Trigger.isUpdate)   handler.afterUpdate();
            else if (Trigger.isUndelete) handler.afterUndelete();
        }
        handler.andFinally();
    }
    
    /**
    * @Description  : Trigger config wrapper
    * @Author       : Felipe Paulino, Deloitte, fpaulinoc@deloitte.com
    * @Date   20/10/2018
    */
    public class TriggerCfg {
        
        public Boolean isActive			{get;private set;}
        public String handlerName		{get;private set;}
        public String sObjectName		{get;private set;}
        
        public TriggerCfg(TriggerConfig__mdt cfg){
            this.isActive    = cfg.Active__c;
            this.sObjectName = cfg.SObject__c;
            this.handlerName = cfg.Handler_Name__c;
        }        
    }
    
    /**
    * @Description   Trigger Exception Class
    * @Author        Felipe Paulino, Deloitte, fpaulinoc@deloitte.com
    * @Date   20/10/2018
    */
    public class SOD_XS_TriggerException extends Exception{}
}