/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Case SLAs by type of records
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
Jessica Gómez               JG
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			28/05/2020		initial version
2.0      JG             15/07/2020      New case solution SLA added
********************************************************************************/
global class SOD_XS_MilestoneTimeCalculator implements Support.MilestoneTriggerTimeCalculator {
    
    public static final String PRV_STR_CASE = 'Case';
    private static final String PRV_STR_ASIGNACION = 'Inicio de Gestión';
    private static final String PRV_STR_PRIMERCONTACTO = 'Primer Contacto';
    private static final String PRV_STR_SOLUCIONCASO = 'Solución del Caso';
    private static final String PRV_STR_CIERRECASO = 'Cierre de Caso';
    private static Boolean ISFIRSTTIME = true;
    private static Map<Id, MilestoneType> MTMAP = new Map<Id, MilestoneType>();
    private static Map<Id, Case> CASEMAP = new Map<Id, Case>();
    public SOD_XS_MilestoneTimeCalculator (){
        
        if(ISFIRSTTIME) {
            List<Case> cases = new list<Case>(); 
            if (SOD_XS_CaseTriggerHandler.lstNewAux != null)
                cases = SOD_XS_CaseTriggerHandler.lstNewAux; 
            for (Case c :  [SELECT Id, RecordType.Name, RecordType.DeveloperName,SOD_XS_Motivo__c FROM Case WHERE Id IN: cases]) {
                CASEMAP.put(c.id, c);
            }

            List<MilestoneType> mt = [SELECT Id, Name FROM MilestoneType];            
            for (MilestoneType m : mt) {
                MTMAP.put(m.id, m);
            }
            ISFIRSTTIME = false;
        }
        
    }

     /**
    *  @description Method that is responsible for calculating the time of the SLA 
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId) {        
                
        Case c =  CASEMAP.get(caseId);
        
        MilestoneType mt = MTMAP.get(milestoneTypeId);
        if (c != null) {
            SOD_XS_Milestone_Time__mdt obj = (fillMapMilestoneWithReason(PRV_STR_CASE, c.SOD_XS_Motivo__c)).get(c.RecordType.DeveloperName);
            if(obj != null) {     
                                  
                if (mt.Name != null && mt.Name.equals(PRV_STR_ASIGNACION)) {
                    return Integer.valueOf(obj.SOD_XS_TiempoAsignacion__c);
                }
                else if (mt.Name != null && mt.Name.equals(PRV_STR_PRIMERCONTACTO)) {
                    return Integer.valueOf(obj.SOD_XS_TiempoPrimerContacto__c);
                }
                else if (mt.Name != null && mt.Name.equals(PRV_STR_SOLUCIONCASO)) {               
                    return Integer.valueOf(obj.SOD_XS_TiempoSolucionCaso__c);
                } else if (mt.Name != null && mt.Name.equals(PRV_STR_CIERRECASO)) {
                    return Integer.valueOf(obj.SOD_XS_TiempoCierreCaso__c);
                }else {
                    
                    return 1;
                }
            } else {                
                return 1;
            }
        } else {                
                return 1;
            }
        
                     
    }

     /**
    *  @description Method used to fetch the SLA values ​​of the custom metadata type
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public static Map<String, SOD_XS_Milestone_Time__mdt> fillMapMilestone(String objName) {
        
        List<SOD_XS_Milestone_Time__mdt> mls = [SELECT Id, DeveloperName, MasterLabel, Label, SOD_XS_Objeto__c, SOD_XS_API_Name_RecordType__c, SOD_XS_TiempoAsignacion__c,
												SOD_XS_TiempoPrimerContacto__c, SOD_XS_TiempoCierreCaso__c, SOD_XS_TiempoSolucionCaso__c
                                                FROM SOD_XS_Milestone_Time__mdt
                                                WHERE SOD_XS_Objeto__c =: objName];
        Map<String, SOD_XS_Milestone_Time__mdt>  str = new Map<String, SOD_XS_Milestone_Time__mdt>();
        if (mls != null && !mls.isEmpty()) {
            for (SOD_XS_Milestone_Time__mdt mt : mls) {
                str.put(mt.SOD_XS_API_Name_RecordType__c, mt);
            }
        }
        return str;
    }
    
     /**
    *  @description Method used to fetch the SLA values ​​of the custom metadata type,
    *  filtering by reason
    *  @author      Jessica Gómez, Deloitte, jgomezr@deloitte.com
    *  @date        30/07/2020
    */
    public static Map<String, SOD_XS_Milestone_Time__mdt> fillMapMilestoneWithReason(String objName, String motivo) {
        
        List<SOD_XS_Milestone_Time__mdt> mls = [SELECT Id, DeveloperName, MasterLabel, Label, SOD_XS_Objeto__c, SOD_XS_API_Name_RecordType__c, SOD_XS_TiempoAsignacion__c,
												SOD_XS_TiempoPrimerContacto__c, SOD_XS_Motivo__c, SOD_XS_TiempoCierreCaso__c, SOD_XS_TiempoSolucionCaso__c
                                                FROM SOD_XS_Milestone_Time__mdt
                                                WHERE SOD_XS_Objeto__c =: objName
                                                AND   SOD_XS_Motivo__c  =: motivo];
        Map<String, SOD_XS_Milestone_Time__mdt>  str = new Map<String, SOD_XS_Milestone_Time__mdt>();
        if (mls != null && !mls.isEmpty()) {
            for (SOD_XS_Milestone_Time__mdt mt : mls) {
                str.put(mt.SOD_XS_API_Name_RecordType__c, mt);
            }
        }
        return str;
    }    
    
}