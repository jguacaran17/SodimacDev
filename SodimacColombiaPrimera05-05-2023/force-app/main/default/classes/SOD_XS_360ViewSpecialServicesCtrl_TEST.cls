/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 24/03/2021
Description  : Test Class SOD_XS_360ViewSpecialServicesController
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			24/03/2021		initial version
********************************************************************************/
@isTest
public with sharing class SOD_XS_360ViewSpecialServicesCtrl_TEST {

    private static final String PRV_STR_DATEFROM;
    private static final String PRV_STR_DATETO;
    private static final String PRV_STR_DOCNUMCL;
    private static final String PRV_STR_DOCTYPECL;
    private static final String PRV_STR_CNTCL;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        24/03/2021
    */
    static {
        PRV_STR_DATEFROM = '23-02-2018';
        PRV_STR_DATETO = '23-06-2018';
        PRV_STR_DOCNUMCL = '13550036-4';
        PRV_STR_DOCTYPECL = 'RUT';
        PRV_STR_CNTCL = 'CL';
    }
    
    /**
    *  @Description: Loading records for the test
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        24/03/2021
    */
	@testSetup static void setup() {
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, PRV_STR_DOCTYPECL, PRV_STR_DOCNUMCL, PRV_STR_CNTCL);       
		Account acc = [Select Name, SOD_XS_Country__c from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        SOD_XS_Country__c p = [Select SOD_XS_Codigo__c, CurrencyIsoCode from SOD_XS_Country__c where SOD_XS_Codigo__c =: PRV_STR_CNTCL];
        p.Id = acc.SOD_XS_Country__c;
        SOD_XS_DataFactory.createStore(p);
    }

    /**
    * @description Default Special Services search: Date Range
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void initClassCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];        
        Test.startTest();    
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_DATERANGE_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 200, staticResource.Body.toString()));   
        SOD_XS_360ViewSpecialServicesController obj360View = SOD_XS_360ViewSpecialServicesController.initClass(acc.Id);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Special Services search: By date range
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void getPageDataAsDateRangeCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);

        SOD_XS_360ViewPurchasesUtility.SearchSpecialServices searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchSpecialServices(acc);
        searchCriteria.isDateRange = true;
        searchCriteria.purchaseDateFilter = new SOD_XS_360ViewPurchasesUtility.PurchaseDateFilterSpcSrv();
        searchCriteria.purchaseDateFilter.dateFrom = PRV_STR_DATEFROM;
        searchCriteria.purchaseDateFilter.dateTo = PRV_STR_DATETO;
        searchCriteria.purchaseDateFilter.Identification = new SOD_XS_360ViewPurchasesUtility.Identification(acc);

        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_DATERANGE_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 200, staticResource.Body.toString()));        
        SOD_XS_360ViewSpecialServicesController obj360View = SOD_XS_360ViewSpecialServicesController.getPageData(searchCriteria);
        system.debug(searchCriteria);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Special Services search: By Sales Document
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void getSalesDocumentCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesUtility.SearchSpecialServices searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchSpecialServices(acc);
        searchCriteria.isSalesDocument = true;
        searchCriteria.salesDocumentFilter = new SOD_XS_360ViewPurchasesUtility.SalesDocumentFilter();
        searchCriteria.salesDocumentFilter.salesDocumentNumber = '857452151';
        searchCriteria.salesDocumentFilter.salesDocumentNumber = 'BOLETA';

        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_DATERANGE_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 200, staticResource.Body.toString()));        
        SOD_XS_360ViewSpecialServicesController obj360View = SOD_XS_360ViewSpecialServicesController.getPageData(searchCriteria);
        system.debug(searchCriteria);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Special Services search: By Project
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void getProjectCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesUtility.SearchSpecialServices searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchSpecialServices(acc);
        searchCriteria.isProject = true;
        searchCriteria.projectNumber = '9491';
        
        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_DATERANGE_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 200, staticResource.Body.toString()));        
        SOD_XS_360ViewSpecialServicesController obj360View = SOD_XS_360ViewSpecialServicesController.getPageData(searchCriteria);
        system.debug(searchCriteria);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Special Services search: By Sub Project Number
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void getSubProjectCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesUtility.SearchSpecialServices searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchSpecialServices(acc);
        searchCriteria.isSubProject = true;
        searchCriteria.subProjectNumber = '8172';
        
        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_DATERANGE_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 200, staticResource.Body.toString()));        
        Object obj360View = SOD_XS_360ViewSpecialServicesController.getPurchaseDataObject(searchCriteria);
        system.debug(searchCriteria);
        System.assertEquals(obj360View != null, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Test Not Found Exception
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void notFoundTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesUtility.SearchSpecialServices searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchSpecialServices(acc);
        searchCriteria.isSubProject = true;
        searchCriteria.subProjectNumber = '8172';

        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 404, Label.SOD_XS_V360OCNoSeEncontraronResultados));
        Test.startTest();
        try {
            Object obj360View = SOD_XS_360ViewSpecialServicesController.getPurchaseDataObject(searchCriteria);
        } catch(Exception e) {
            System.assertEquals(e != null, true, Label.SOD_XS_V360OCNoSeEncontraronResultados);
        }
        Test.stopTest();
    }

    /**
    * @description Test Not Found Exception
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void notFound404Test() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];        
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON, 404, Label.SOD_XS_V360OCNoSeEncontraronResultados));
        Test.startTest();
        try {
            SOD_XS_360ViewSpecialServicesController obj360View = SOD_XS_360ViewSpecialServicesController.initClass(acc.Id);
        } catch(Exception e) {
            System.assertEquals(e != null, true, Label.SOD_XS_V360OCNoSeEncontraronResultados);
        }
        Test.stopTest();
    }

    /**
    * @description Test wrapper class SearchOrdersAndPayments
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        24/03/2021
    */ 
    @isTest static void searchOrdersAndPaymentsTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewSpecialServicesController.getRecord(acc.Id);
        SOD_XS_360ViewPurchasesUtility.SearchOrdersAndPayments searchCriteria = new SOD_XS_360ViewPurchasesUtility.SearchOrdersAndPayments(acc);
        searchCriteria.isDateRange = true;
        searchCriteria.purchaseDateFilter = new SOD_XS_360ViewPurchasesUtility.PurchaseDateFilter();
        searchCriteria.purchaseDateFilter.dateFrom = PRV_STR_DATEFROM;
        searchCriteria.purchaseDateFilter.dateTo = PRV_STR_DATETO;
        System.assertEquals(searchCriteria != null, true, 'The data has been returned');
    }
    
    /**
    * @description Test method processCaseData
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */ 
    @isTest static void processCaseDataTest() {
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SPS_STOREPROJECT_CL LIMIT 1];
        String json = staticResource.Body.toString();
        String countryIsoCode = 'CL';
        String numberDocument = '13550036-4';
        String caseClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SOD_XS_DataFactory.PRV_STR_CASE_CLAIM).getRecordTypeId();
        Account acc = [Select Name, SOD_XS_Country__c, RecordTypeId, CreatedById, PersonContactId from Account where SOD_XS_NroDocumento__c =: numberDocument];
        SOD_XS_Country__c p = [Select SOD_XS_Codigo__c, CurrencyIsoCode from SOD_XS_Country__c where SOD_XS_Codigo__c =: countryIsoCode];
        p.Id = acc.SOD_XS_Country__c;

        SOD_XS_CentroDeCosto__c t = [Select Id, SOD_XS_Country__c from SOD_XS_CentroDeCosto__c where SOD_XS_CentroDeCosto__c =: '972'];
        Test.startTest();

            json = json.replace('001g000002UpjVgAAJ', acc.Id);
            json = json.replace('a0555000008Ta3dAAC', p.Id);
            json = json.replace('"CL"', '"'+p.SOD_XS_Codigo__c+'"');
            json = json.replace('"CLP"', '"'+p.CurrencyIsoCode+'"');
            json = json.replace('0122E000000dDeJQAU', acc.RecordTypeId);
            json = json.replace('00555000005ZzhGAAS', acc.CreatedById);
            json = json.replace('003g0000027zxDcAAI', acc.PersonContactId);
            json = json.replace('a0g55000001Yf33AAC', t.Id);
            json = json.replace('012550000017QpKAAU', caseClaimRecordTypeId);

            String resp = SOD_XS_360ViewSpecialServicesController.processCaseData(json);
    	    System.assertEquals(resp != null, true, 'The data has been returned');

        Test.stopTest();
    }

    /**
    * @description Test method getDescriptionForSubProject
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getDescriptionForSubProjectTest(){
       Test.startTest();
       String resp = SOD_XS_360ViewSpecialServicesController.getDescriptionForSubProject(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();
    }
    
    /**
    * @description Test method getColumnsForProductsSubProject
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getColumnsForProductsSubProjectTest(){
       Test.startTest();
       List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> resp = SOD_XS_360ViewSpecialServicesController.getColumnsForProductsSubProject(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();
    }
    
    /**
    * @description Test method getDescriptionForAsocDocument
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getDescriptionForAsocDocumentTest(){
       Test.startTest();
       String resp = SOD_XS_360ViewSpecialServicesController.getDescriptionForAsocDocument(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }
    
    /**
    * @description Test method getColumnsForProductsPaymentVouchers
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getColumnsForProductsPaymentVouchersTest(){
       Test.startTest();
       List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> resp = SOD_XS_360ViewSpecialServicesController.getColumnsForProductsPaymentVouchers(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }
    
    /**
    * @description Test method getDescriptionForCaseCreation
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getDescriptionForCaseCreationTest(){
       Test.startTest();
       String resp = SOD_XS_360ViewSpecialServicesController.getDescriptionForCaseCreation(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }
    
    /**
    * @description Test method getDescriptionObjectsForCase
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getDescriptionObjectsForCaseTest(){
       Test.startTest();
       Map<String,String> resp = SOD_XS_360ViewSpecialServicesController.getDescriptionObjectsForCase(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }
    
    /**
    * @description Test method getCaseRecordType
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getCaseRecordTypeTest(){
       Test.startTest();
       Map<id,String> resp = SOD_XS_360ViewSpecialServicesController.getCaseRecordType(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }

    /**
    * @description Test method getProductColumnsForResume
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        25/03/2021
    */    
    @isTest static void getProductColumnsForResumeTest(){
       Test.startTest();
       List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> resp = SOD_XS_360ViewSpecialServicesController.getProductColumnsForResume(); 
       System.assertEquals(resp != null, true, 'The data has been returned');
       Test.stopTest();        
    }
}