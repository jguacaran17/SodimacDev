/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Inserting Entitlements associated with accounts and assigning cases
History      : CRMSC-5038
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
Pablo Lopez Borquez         PLB
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			28/05/2020		initial version
2.0      JG             20/07/2020      Modification to take the country of the account
2.1      PLB            18/01/2021      Optimize code
********************************************************************************/
public without sharing class SOD_XS_EntitlementHandler extends SOD_XS_AbstractTriggerHandler {
    
    private List<Entitlement> ents = new List<Entitlement>();
	private Map<Id, Entitlement> accEntMap;
    private Map<Id, Account> accRcdMap;
    private Map<Id, Case> caseRcdMap;
    private static final String PRV_STR_ENTYPE;
    private static final String PRV_STR_ENNAME;
    private static final String PRV_STR_CASE;
    private static final Map<String, SOD_XS_Milestone_Time__mdt> PRV_MAP_MILE;
    
    static {
        PRV_STR_ENTYPE = 'Asistencia telefónica';
        PRV_STR_ENNAME = 'Asignación estandar ';
        PRV_STR_CASE = 'Case';
        PRV_MAP_MILE = SOD_XS_MilestoneTimeCalculator.fillMapMilestone(SOD_XS_MilestoneTimeCalculator.PRV_STR_CASE);
    }
     /**
    *  @description Constructor
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */   
    public SOD_XS_EntitlementHandler() {
        this.ents = Trigger.new;
    }
    
    /**
    *  @description Before object Insert preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
	public override void beforeInsert() {
        try {
            setSLAProcess();
        } catch (Exception e) {
            
            new SOD_XS_EnLogger().log(e).push();
        }
        
    }	

    /**
    *  @description After object Insert preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */    
    public override void afterInsert() {
        try {
            setEntCaseFuture(Trigger.newMap.keySet());
        } catch (Exception e) {
            
            new SOD_XS_EnLogger().log(e).push();
        }
        
    }
    
     /**
    *  @description Before object Update preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public override void beforeUpdate() {
        try {
            setEntCase();
        } catch (Exception e) {
            
            new SOD_XS_EnLogger().log(e).push();
        }
    }
  
    /**
    *  @description Method to set the SLA according to the allocation process
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public void setSLAProcess() {        
        getAcctIds();
        getAcctMap();
        List<SlaProcess> slaProcessList = [SELECT Id, Name, NameNorm, IsActive, SobjectType FROM SlaProcess WHERE SobjectType =: PRV_STR_CASE AND IsActive = TRUE];
        Map<String, Id> slaProcessMap = new Map<String, Id>();        
        
        for (SlaProcess s : slaProcessList) {
            slaProcessMap.put((s.Name).toLowerCase().subString(s.Name.length()-2,s.Name.length()), s.Id);
        }
        
        for (Entitlement e : ents) {
            if (e.SlaProcessId == Null) {
                String cnt = (accRcdMap.get(e.AccountId).SOD_XS_Country__r.SOD_XS_Codigo__c);
                e.Name = PRV_STR_ENNAME + cnt + ': ' + accRcdMap.get(e.AccountId).Name;
                e.Type = PRV_STR_ENTYPE;
                e.SlaProcessId = slaProcessMap.get(cnt.toLowerCase());
            }
        }
    }
    
    /**
    *  @description It is in charge of setting the entitlements of the case with a future method
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    @future
    public static void setEntCaseFuture(Set<id> entId) {
        Map<Id, Entitlement> ftrMap = new Map<Id, Entitlement>();
        
        for (Entitlement e : [SELECT Id, AccountId, Name FROM Entitlement WHERE Id in :entId]) {
            ftrMap.put(e.AccountId, e);
        }
        
        List<Case> caseList = [SELECT Id, EntitlementId, Entitlement.Name, AccountId, RecordTypeId, RecordType.DeveloperName, Status 
                               FROM Case
                               WHERE AccountId in :ftrMap.keySet() AND RecordType.DeveloperName in :PRV_MAP_MILE.keySet()
                               AND EntitlementId = Null];
        List<Case> caseUp = new List<Case>();
        List<Case> caseUp2 = new List<Case>();

        for (Case c : caseList) {
            if (ftrMap.containsKey(c.AccountId)) {
                c.EntitlementId = ftrMap.get(c.AccountId).Id;
                caseUp.add(c);
            }
        }
        
        if (!caseUp.isEmpty()) {
            for(Case c : caseUp){
                if(c.Status != 'Closed')
                  caseUp2.add(c);        
            }
            update caseUp2;
        }
    }
    
    /**
    *  @description It is in charge of setting the entitlements in the case
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public void setEntCase() {
        getAcctIds();
        List<Case> caseList = [SELECT Id, EntitlementId, Entitlement.Name, AccountId, RecordTypeId, RecordType.DeveloperName
                               FROM Case
                               WHERE AccountId in :accEntMap.keySet() AND RecordType.DeveloperName in :PRV_MAP_MILE.keySet()
                               AND EntitlementId = Null];
        List<Case> caseUp = new List<Case>();

        for (Case c : caseList) {
            
            if (accEntMap.containsKey(c.AccountId)) {
                
                c.EntitlementId = accEntMap.get(c.AccountId).Id;
                caseUp.add(c);
                
            }
        }
        
        if (!caseUp.isEmpty()) {
            update caseUp;
        }
    }
    
    /**
    *  @description Method to get the ID of the accounts
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public void getAcctIds() {
        accEntMap = new Map<Id, Entitlement>();
        for (Entitlement e : ents) {
            accEntMap.put(e.AccountId, e);
        }
    }
    
    /**
    *  @description Method to obtain the accounts to which the assignment will be created
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public void getAcctMap() {
        accRcdMap = new Map<Id, Account>();
        for (Account a : [SELECT Id, Name, RecordTypeId, SOD_XS_Country__c, SOD_XS_Country__r.SOD_XS_Codigo__c FROM Account WHERE Id in :accEntMap.keySet()]) {
            accRcdMap.put(a.Id, a);
        }
    }
    
}