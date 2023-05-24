public class SOD_XS_InvokeActivateCaseAssignmentRules {
    @InvocableMethod
    public static void caseAssignment(List<Id> caseIds){
        SOD_XS_ActivateCaseAssignmentRules updateJob = new SOD_XS_ActivateCaseAssignmentRules(caseIds);
        System.enqueueJob(updateJob);
        /*
        List<Case> casesList = new List<Case>();
        for(Case c : [Select Id, SOD_XS_PaisDeLaCuenta__c from Case where Id in :caseIds]){           
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId = SOD_XS_EnUtility.getAssignmentRulesForCountry(c.SOD_XS_PaisDeLaCuenta__c);
            c.setOptions(dmo);
            casesList.add(c);
        }
        Database.upsert(casesList);
        */
    }
}