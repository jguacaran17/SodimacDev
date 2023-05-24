/**
*  @Description: Queueable class used to Async activate case assignment rules for a list of Cases
*  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
*  @Date:        01/06/2022
*/    
public class SOD_XS_ActivateCaseAssignmentRules implements Queueable, Database.AllowsCallouts{
    
    private List<Id> caseIds;
    List<Case> casesList;

    public SOD_XS_ActivateCaseAssignmentRules (List<Id> caseIds) {
        this.casesList = new List<Case>();
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        for(Case c : [Select Id, SOD_XS_PaisDeLaCuenta__c from Case where Id in :caseIds]){           
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.assignmentRuleId = SOD_XS_EnUtility.getAssignmentRulesForCountry(c.SOD_XS_PaisDeLaCuenta__c);
            c.setOptions(dmo);
            casesList.add(c);
        }
        Database.upsert(casesList);
    }
}