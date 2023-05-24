@isTest
public class SOD_XS_AddProductsToCaseFcom_TEST {

    @isTest static void testQueueable() {
        Case c = new Case();
        c.SOD_XS_IdExterno__c = '040323';
        c.SOD_XS_AuxOrdenDeCompra__c = '10001';
        c.SOD_XS_AuxCodigoDelProductoAfectado__c = '80';
        Account a = SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '18959028-8','CL');
        c.AccountId = a.Id;
        insert c;
        Test.startTest();
        SOD_XS_AddProductsToCaseFcom updateJob = new SOD_XS_AddProductsToCaseFcom(c, '10001', new List<String>{'80'});
        System.enqueueJob(updateJob);
        Test.stopTest();
    }
        
}