/**
*  @Description: Invokable class used together with Queueable SOD_XS_AddProductsToCaseFcom to update Cases Fcom with data from Backends
*  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
*  @Date:        11/10/2022
*/    
public class SOD_XS_InvokeAddProductsToCase {
    @InvocableMethod
    public static void invokeAddProductsToCaseAux(List<Id> caseIds) {
        List<Case> listCases = [Select Id, AccountId, SOD_XS_AuxOrdenDeCompra__c, SOD_XS_AuxCodigoDelProductoAfectado__c FROM Case WHERE Id IN :caseIds];
        for(Case c : listCases){
            if(c.SOD_XS_AuxOrdenDeCompra__c != null){
                String caseId = String.valueOf(c.Id);
                String order = c.SOD_XS_AuxCodigoDelProductoAfectado__c;
                List<String> productCodes = SOD_XS_EnUtility.getListFromString(c.SOD_XS_AuxCodigoDelProductoAfectado__c, ',');
                SOD_XS_AddProductsToCaseFcom updateJob = new SOD_XS_AddProductsToCaseFcom(caseId, order, productCodes);
                System.enqueueJob(updateJob);
            }
        }
    }
}