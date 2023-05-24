/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 14/07/2020
Description  : Handler class for Trigger of the Cases object (Entitlement assignment)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Jessica Gómez			    JG
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      JG			14/07/2020		    Initial definition of the class.
********************************************************************************/

public with sharing class SOD_XS_CaseTriggerHandler extends SOD_XS_AbstractTriggerHandler{
    private List<Case> casesToAssign; 
    private List<Case> cases= new List<Case>(); 
    private List<Case> casesEntitlement = cases ;
    private static final Map<String, SOD_XS_Milestone_Time__mdt> PRV_MAP_MILE;
    private static Boolean isCheckMail = false;
    private static Boolean isFirstTime = true;
    private String PRV_STR_MT;
    public static List<Case> lstNewAux;
    private static final String PRV_CTG_CLI;
    private static final String PRV_PRI_CAS;

    static {
        PRV_MAP_MILE = SOD_XS_MilestoneTimeCalculator.fillMapMilestone(SOD_XS_MilestoneTimeCalculator.PRV_STR_CASE);
        PRV_CTG_CLI = 'S';
        PRV_PRI_CAS = 'High';                
    }
    
    /**
    *  @description Method that is in charge of ordering the elements prior to the insert and modify actions
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    private void sortItems(){
        cases = Trigger.new;    
        Map<Id,Case> oldMapCases = (Map<Id,Case>) Trigger.oldMap;
        Map<Id, String> category = mapCategoryClient();
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        
        for(Case c: cases ){
            if(c.Origin != 'Web-to-Case'){
                if( PRV_MAP_MILE.containsKey(rtMap.get(c.RecordTypeId).getDeveloperName()) && 
                    (isChanged(c, 'Type') || isChanged(c, 'RecordTypeId') || ( c.EntitlementId==null))  ){ 
                    casesEntitlement.add(c);
                }
                if(Trigger.isBefore && Trigger.isInsert){
                    if( category.get(c.AccountId) == PRV_CTG_CLI){                    
                        c.Priority = PRV_PRI_CAS;
                    } 
                }
            } 
        }
    }
    /**
    *  @description Method that is responsible for abbreviating the country
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        05/08/2020
    */
    private Map<Id, String> abbCountry() {
        cases = Trigger.new;        
        List<String> accId = new List<String>();
        Map<Id, String> country = new Map<Id, String>();
        
        for (case c : cases) {
            accId.add(c.AccountId);
        }
        
        for (Account ac : [SELECT Id, SOD_XS_Country__c, SOD_XS_Country__r.SOD_XS_Codigo__c  FROM Account WHERE Id IN :accId]) {
            country.put(ac.Id , ac.SOD_XS_Country__r.SOD_XS_Codigo__c); 
        }     
        return country; 
    }

    /**
    *  @description Method that is responsible for client Category map
    *  @author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @date        30/03/2021
    */
    private Map<Id, String> mapCategoryClient() {
        cases = Trigger.new;        
        List<String> accId = new List<String>();
        Map<Id, String> category = new Map<Id, String>();
        if(Trigger.isBefore && Trigger.isInsert){
            for (case c : cases) {
                accId.add(c.AccountId);
            }
            List<Account> listAcc = [SELECT Id, SOD_XS_CategoriaCliente__c FROM Account WHERE Id IN :accId];
            for (Account ac : listAcc) {
                category.put(ac.Id , ac.SOD_XS_CategoriaCliente__c); 
            }
        }
     
        return category; 
    }
    
    /**
    *  @description Method that is responsible for obtaining the name of the corresponding SLA to complete.
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        14/07/2020
    */
    private void getMT() {
        cases = Trigger.new;    
        
        for (Case c: [SELECT Id, Status, SOD_XS_ActualizacionPorIntegracion__c, (SELECT Id FROM Tasks WHERE Status !='Cerrada') FROM Case WHERE Id in : cases]){
            if((isChanged(c, 'Status')) && (c.Status == 'Closed') && (!c.SOD_XS_ActualizacionPorIntegracion__c && c.Tasks.size()!=0 && !c.Tasks.isEmpty())){
                Trigger.newMap.get(c.id).addError(Label.Caso_Tareas_Abiertas);
            } else if(c.Status == 'Gestionado'){
                PRV_STR_MT = 'Solución del Caso'; 
            }
        }
        
        for (Case c : [SELECT Id, owner.type, ownerid, contactid, SOD_XS_CheckMailLlamada__c, Status  FROM Case WHERE Id in : cases]) { 
            
            if((isChanged(c,'OwnerId'))&&(c.owner.type != 'Queue')) {
                PRV_STR_MT = 'Inicio de Gestión'; 
            }
            
            if ((c.Status == 'New' || c.Status == 'On Hold') && c.SOD_XS_CheckMailLlamada__c == true && isCheckMail == false) {
                PRV_STR_MT = 'Primer Contacto'; 
                isCheckMail = true; 
            } 
            
            if(c.Status == 'Closed') {
                PRV_STR_MT = 'Cierre de Caso'; 
            } 
        }
    }
    
    /**
    *  @description Before object insert preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public override void beforeInsert(){
        lstNewAux = (List<Case>) Trigger.new;
        
        sortItems();
        for(Case c : lstNewAux){
            // Para los tres paises ver si aplica cambiar el CC Responsable por la Tienda Que Vende
            cambiarCCResponsablePorTiendaQueVende(c, null);
        }
        if(!casesEntitlement.isEmpty()){
            setEntitlement(casesEntitlement, new Map<id,Case>());
        } 
    }
    
    /**
    *  @description Before object update preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        14/07/2020
    */
    public override void beforeUpdate(){
        lstNewAux = (List<Case>) Trigger.new;
        sortItems();
        Map<Id,Case> oldMapCases = (Map<Id,Case>) Trigger.oldMap;
        for(Case c : lstNewAux){
            Case oldCase = oldMapCases.get(c.Id);
            // Para los tres paises ver si aplica cambiar el CC Responsable por la Tienda Que Vende
            cambiarCCResponsablePorTiendaQueVende(c, oldCase);
        }
        if(!casesEntitlement.isEmpty()){
            setEntitlement(casesEntitlement, oldMapCases);
        }               
    }
    /**
    *  @description After object Insert preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        24/07/2020
    */
    public override void afterInsert(){ 
        casesToAssign = Trigger.new;
        if(casesToAssign.size() > 0) {
            activateAssignmentRule(); 
        }
    }
    
    
    /**
    *  @description After object Update preparations
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        24/07/2020
    */
    public override void afterUpdate(){
        DateTime completionDate = System.now(); 
        cases = Trigger.new; 
        Map<Id,Case> oldMapCases = (Map<Id,Case>) Trigger.oldMap;
        Boolean ccIsChanged = false;
        Case caseOld = new Case(); 
        Map<Id, USer> OwnerCaseList = New Map<Id, User>();
       
        List<Id> updateCases = new List<Id>();
        
        //New Map to get user owner of cases
        Map<Id, Case> caseOwnerMap = new Map<Id, Case>();
        for (Case c : cases) {
            if(string.valueOf(c.OwnerId).startsWith('005')){
              caseOwnerMap.put(c.OwnerId, c);  
            }
        }
        //New Map to get user owner of cases
        getMT();
 
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
        Boolean isFCR;
        casesToAssign = new List<Case>();
	
	    if(!caseOwnerMap.isEmpty()){
        	OwnerCaseList = New Map<Id, User>([SELECT ID, Name, isActive 
                                               FROM User 
                                               WHERE Id IN :caseOwnerMap.keySet()]); 
        }
        
        boolean CenterCostChange = false;
        
        for (Case c : cases){
            ccIsChanged = false;
            isFCR = ( rtMap.get(c.RecordTypeId)?.getDeveloperName()?.compareTo('SOD_XS_Consulta') == 0 ||
                      rtMap.get(c.RecordTypeId)?.getDeveloperName()?.compareTo('SOD_XS_Felicitacion') == 0);

            if ( (c.SlaStartDate <= completionDate) && (c.SlaExitDate == null) && !(isFCR) )
                updateCases.add(c.Id);

            caseOld = oldMapCases.get(c.Id);
            if( caseOld != null && !(isFCR) ) {

                // Para Colombia - Si la tipologia del Caso es actualizada regatillar reglas de asignacion del Caso
                if(c.SOD_XS_PaisdelCaso__c == 'Colombia' && c.Status != 'Closed'){
                    if(c.RecordTypeId != caseOld.RecordTypeId || c.SOD_XS_Area__c != caseOld.SOD_XS_Area__c || c.SOD_XS_Motivo__c != caseOld.SOD_XS_Motivo__c || c.SOD_XS_Submotivo__c != caseOld.SOD_XS_Submotivo__c || c.SOD_XS_TiendaVende__c != caseOld.SOD_XS_TiendaVende__c){
                        casesToAssign.add(c);
                    }
                }

                if(c.SOD_XS_CentroCostoResponsable__c != caseOld.SOD_XS_CentroCostoResponsable__c) {
                	ccIsChanged = true;
                    CenterCostChange = true;
            	}
                
                //if someone open a case which user is inactive must activate the assingment rule
               if(!caseOwnerMap.isEmpty()){
            
                   if( c.Status != 'Closed' && caseOld.Status == 'Closed' && OwnerCaseList.get(caseOld.OwnerId).isActive == false) {
                	     ccIsChanged = true;
            	     } 
                }

                // add the case to assign if it is required
                if (ccIsChanged) {
                    casesToAssign.add(c);
                }
                
                if (CenterCostChange) {
                    casesToAssign.add(c);
                }
            }              	
        }
         
        if(updateCases.isEmpty() == false)
        completeMilestone(updateCases, PRV_STR_MT, completionDate);     
        
        if(isFirstTime) {
            isFirstTime = false;
            if(casesToAssign.size() > 0) {
                activateAssignmentRule(); 
            }
        }
        
        if(CenterCostChange && casesToAssign.size() > 0) {
            System.debug('Se ejecuta el llamado a las reglas de asignación, cuando el contro de costo cambia a: F.COM');
            CenterCostChange = false;
        	activateAssignmentRule(); 
        }
        	        	
    }
    
     /**
    *  @description Method used to complete SLAs
    *  filtering by reason
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public static void completeMilestone(List<Id> caseIds, String milestoneName, DateTime complDate) {

        List<CaseMilestone> cmilestone = new List<CaseMilestone>();
        for (CaseMilestone cm : [select Id, completionDate
                                 from CaseMilestone cm
                                 where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                                 and completionDate = null])
        {
            cm.completionDate = complDate;
            cmilestone.add(cm);
        }
        if(!cmilestone.isEmpty())
            update cmilestone;
        
    }
    
    /**
    *  @description Method that is responsible for activating the corresponding allocation rule.
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        05/08/2020
    */  
    private void activateAssignmentRule() {        
        Map<Id, String> country = AbbCountry();
        // assign the cases we need to assing
        cases = casesToAssign;

        List<Id> caseIds = new List<Id>{};
        Map<String, Id> asrMap = new Map<String, Id>();
        
        for(AssignmentRule  asr : [select Id, Name from AssignmentRule where SobjectType = 'Case']){
            asrMap.put(asr.Name.SubString(4,6), asr.Id);
        }
        
        for (Case theCase : cases) 
            caseIds.add(theCase.Id);
        
        List<Case> casesList = new List<Case>{}; 
        for(Case c : [Select Id, AccountId from Case where Id in :caseIds])
        {            
            Database.DMLOptions dmo = new Database.DMLOptions();
            
            
            dmo.assignmentRuleHeader.assignmentRuleId = asrMap.get(country.get(c.AccountId));  
            c.setOptions(dmo);
            
            casesList.add(c);
        }
        
        Database.upsert(casesList);    
    }
    
    
    /**
    *  @description Set Entitlement Process on Case
    *  @author      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @date        27/05/2020
    */  
    private void setEntitlement(List<Case> newCases, Map<Id,Case> oldMapCases) {
        
        try {
            Set<Id> acctIds = new Set<Id>();
            Set<Id> contIds = new Set<Id>();
            Set<Id> caseRvl = new Set<Id>();
            Map<Id, Entitlement> entMap = new Map<Id, Entitlement>();
            Map<Id, Id> contAccIds = new Map<Id, Id>();
            //AccountID shows as null in the Before Insert event or Update Case trigger(Workaround III)
            //https://help.salesforce.com/articleView?siteLang=es_mx&id=000335451&type=1&mode=1
            for (Case c : newCases) {
                contIds.add(c.ContactId);
            }
            for (Contact c : [SELECT Id, Name, AccountId FROM Contact WHERE Id IN :contIds]) {
                acctIds.add(c.AccountId);
                contAccIds.put(c.Id, c.AccountId);
            }
            for (Entitlement e : [SELECT Id, StartDate, EndDate, 
                                  AccountId, AssetId
                                  FROM Entitlement
                                  WHERE AccountId in :acctIds and Status != 'Expired']) {
                                      entMap.put(e.AccountId, e);
                                  }
            Map<Id, Entitlement> entMapUp = new Map<Id, Entitlement>();
            for (Case c : newCases) {
                if ((c.EntitlementId == null && c.ContactId != null) || c.SOD_XS_ReevaluacionAsignacion__c) {
                    if (entMap.containsKey((contAccIds.get(c.ContactId)))) {
                        c.EntitlementId = (entMap.get((contAccIds.get(c.ContactId)))).Id;
                    } else {
                        Entitlement entObj = new Entitlement();
                        entObj.AccountId = (contAccIds.get(c.ContactId));
                        entObj.StartDate = system.today();
                        entMapUp.put((contAccIds.get(c.ContactId)), entObj);
                    }
                    c.SOD_XS_ReevaluacionAsignacion__c = c.SOD_XS_ReevaluacionAsignacion__c ? False : c.SOD_XS_ReevaluacionAsignacion__c;
                } else if (oldMapCases.containsKey(c.id) && isChanged(c, 'RecordTypeId') && c.EntitlementId != null && c.ContactId != null) {
                    c.EntitlementId = null;
                    caseRvl.add(c.Id);
                }
            }
            if (!entMapUp.isEmpty()) {
                insert entMapUp.values();
            }
            if (!caseRvl.isEmpty()) {
                reEvaluateEnt(caseRvl);
            }
        } catch (Exception e) {
            new SOD_XS_EnLogger().log(e).push();
        }
    }
    
    /**
    *  @description Re-Evaluate Entitlement Process on Case
    *  @author      Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @date        27/05/2020
    */
    @future
    public static void reEvaluateEnt(Set<id> setId)
    {
        List<Case> Obj = [SELECT Id, EntitlementId, AccountId, SOD_XS_ReevaluacionAsignacion__c FROM Case WHERE Id in :setId AND EntitlementId = Null];
        for ( Case c : Obj ) {            
            c.SOD_XS_ReevaluacionAsignacion__c = true;
        }        
        update Obj;
    }

    /**
    *  @description Cambia el CC Responsable del Caso si la tipificacion del caso es especial
    *  @author      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    *  @date        21/10/2022
    */
    private void cambiarCCResponsablePorTiendaQueVende(Case newCase, Case oldCase){
        if(SOD_XS_EnUtility.isFeatureAvailable('SOD_XS_Cambiar_CCR_Por_TQV', newCase.CreatedDate)){
            if(newCase.Status != 'Closed' && newCase.SOD_XS_TiendaVende__c != null){
                if(oldCase == null || (newCase.SOD_XS_CentroCostoResponsable__c != oldCase.SOD_XS_CentroCostoResponsable__c) || (newCase.SOD_XS_TiendaVende__c != oldCase.SOD_XS_TiendaVende__c)){
                    List<SOD_XS_TipificacionEspecial__mdt> teList = SOD_XS_TipificacionEspecial__mdt.getAll().values();
                    for(SOD_XS_TipificacionEspecial__mdt te : teList){
                        if(te.SOD_XS_PaisDelCaso__c == newCase.SOD_XS_PaisDelCaso__c && String.valueOf(SOD_XS_EnUtility.getRecordTypeID('Case', 'SOD_XS_'+te.SOD_XS_TipoDelCaso__c)) == String.valueOf(newCase.RecordTypeId) && te.SOD_XS_AreaDelCaso__c == newCase.SOD_XS_Area__c && te.SOD_XS_MotivoDelCaso__c == newCase.SOD_XS_Motivo__c && te.SOD_XS_SubmotivoDelCaso__c == newCase.SOD_XS_Submotivo__c){
                            if(te.SOD_XS_CambiarCCRPorTiendaQueVende__c == true){
                                newCase.SOD_XS_CentroCostoResponsable__c = newCase.SOD_XS_TiendaVende__c;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}