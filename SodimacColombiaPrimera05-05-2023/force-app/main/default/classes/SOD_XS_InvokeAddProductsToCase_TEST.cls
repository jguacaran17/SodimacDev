/**
*  @Description: Test Class for SOD_XS_InvokeAddProductsToCase
*  @Author:      Rodolfo Valencia, FTC, rlvalencia@falabella.cl
*  @Date:        11/10/2022
*/    
@isTest
public class SOD_XS_InvokeAddProductsToCase_TEST {
    @isTest
    public static void testInvoke() {
        List<Id> caseIds = new List<Id>();
        Case c = new Case();
        c.SOD_XS_IdExterno__c = '040323';
        c.SOD_XS_AuxOrdenDeCompra__c = '10001';
        c.SOD_XS_AuxCodigoDelProductoAfectado__c = '80';
        Account a = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '18959028-8','CL');
        c.AccountId = a.Id;
        insert c;
        caseIds.add(c.Id);
        Test.startTest();
        SOD_XS_InvokeAddProductsToCase.invokeAddProductsToCaseAux(caseIds);
        Test.stopTest();
    }
}