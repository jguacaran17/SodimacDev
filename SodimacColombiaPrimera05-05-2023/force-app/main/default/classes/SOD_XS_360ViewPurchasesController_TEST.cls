/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 16/11/2020
Description  : Test Class SOD_XS_360ViewPurchasesController
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			16/11/2020		initial version
1.1      LMG            28/01/2021      Optimize test class
********************************************************************************/
@isTest
public with sharing class SOD_XS_360ViewPurchasesController_TEST {

    private static final String PRV_STR_PATH_LAST10;
    private static final String PRV_STR_PATH_DATEFILTER;
    private static final String PRV_STR_PATH_DATEFILTER_PO_PV;
    private static final String PRV_STR_PATH_ORDER;
    private static final String PRV_STR_PATH_SLSDOC;
    private static final String PRV_STR_PATH_RSV;
    private static final String PRV_STR_DATEFROM;
    private static final String PRV_STR_DATETO;
    private static final String PRV_STR_DOCNUMCL;
    private static final String PRV_STR_DOCTYPECL;
    private static final String PRV_STR_CNTCL;
    private static final String PRV_STR_PATHCLIENTCL;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdón Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        16/11/2020
    */
    static {
        PRV_STR_PATH_LAST10 = '/360View?fields=purchaseOrders&pageNumber=1&pageSize=10';
        PRV_STR_PATH_DATEFILTER = '/360View?fields=purchaseOrders&pageNumber=1&pageSize=10&purchaseDateFilter=';
        PRV_STR_PATH_DATEFILTER_PO_PV = '/360View?fields=purchaseOrders,paymentVouchers&pageNumber=1&pageSize=10&purchaseDateFilter=';
        PRV_STR_DATEFROM = '23-02-2019';
        PRV_STR_DATETO = '23-06-2018';
        PRV_STR_PATH_ORDER = '?fields=purchaseOrders&purchaseOrderNumber=';
        PRV_STR_PATH_SLSDOC = '?fields=purchaseOrders&salesDocumentFilter=';
        PRV_STR_PATH_RSV = '?fields=purchaseOrders&reserveNumber=';
        PRV_STR_DOCNUMCL = '13550036-4';
        PRV_STR_DOCTYPECL = 'RUT';
        PRV_STR_CNTCL = 'CL';
        PRV_STR_PATHCLIENTCL = '/CL/RUT/13550036-4';

    }
    /**
    * @description: Setup for test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
	@testSetup static void setup(){       
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, PRV_STR_DOCTYPECL, PRV_STR_DOCNUMCL, PRV_STR_CNTCL);       
		Account acc = [Select Name, SOD_XS_Country__c from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        SOD_XS_Country__c p = [Select SOD_XS_Codigo__c, CurrencyIsoCode from SOD_XS_Country__c where SOD_XS_Codigo__c =: PRV_STR_CNTCL];
        p.Id = acc.SOD_XS_Country__c;
        SOD_XS_DataFactory.createStore(p);
    }
    /**
    * @description Default Order search: Last 10 Purchase Orders
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        16/11/2020
    */ 
    @isTest static void initClassCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        String path = PRV_STR_PATHCLIENTCL + PRV_STR_PATH_LAST10;
        
        Test.startTest();    
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST1_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', 'application/json', 200, staticResource.Body.toString()));   
        SOD_XS_360ViewPurchasesController obj360View = SOD_XS_360ViewPurchasesController.initClass(acc.Id);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Order search: By pagination and date range
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        16/11/2020
    */ 
    @isTest static void getPageOrdersAsPerPaginationCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewPurchasesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesController.WrapSearchCriteria searchCriteria = new SOD_XS_360ViewPurchasesController.WrapSearchCriteria(acc);
        searchCriteria.isDateRange = true;
        searchCriteria.purchaseDateFilter = new SOD_XS_360ViewPurchasesController.PurchaseDateFilter();
        searchCriteria.purchaseDateFilter.dateFrom = PRV_STR_DATEFROM;
        searchCriteria.purchaseDateFilter.dateTo = PRV_STR_DATETO;
        
        String dt = '{"dateFrom":"' + PRV_STR_DATEFROM + '","dateTo":"' + PRV_STR_DATETO + '"}';
        String path = PRV_STR_PATHCLIENTCL + PRV_STR_PATH_DATEFILTER_PO_PV + dt;
        
        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST1_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', 'application/json', 200, staticResource.Body.toString()));
        
        SOD_XS_360ViewPurchasesController obj360View = SOD_XS_360ViewPurchasesController.getPageOrdersAsPerPagination(searchCriteria);
        System.assertEquals(obj360View.dataTable.size() > 0, true, 'The data table has been returned');
        Test.stopTest();
    }
    
    /**
    * @description Order search: By order number
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        16/11/2020
    */ 
    @isTest static void getPurchaseOrdersCLTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewPurchasesController.getRecord(acc.Id);
        
        SOD_XS_360ViewPurchasesController.WrapSearchCriteria searchCriteria = new SOD_XS_360ViewPurchasesController.WrapSearchCriteria(acc);
        searchCriteria.isDateRange = true;
        searchCriteria.purchaseDateFilter = new SOD_XS_360ViewPurchasesController.PurchaseDateFilter();
        searchCriteria.purchaseDateFilter.dateFrom = PRV_STR_DATEFROM;
        searchCriteria.purchaseDateFilter.dateTo = PRV_STR_DATETO;
        
        String dt = '{"dateFrom":"' + PRV_STR_DATEFROM + '","dateTo":"' + PRV_STR_DATETO + '"}';
        String path = PRV_STR_PATHCLIENTCL + PRV_STR_PATH_DATEFILTER_PO_PV + dt;
        
        Test.startTest();
		StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST10_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', 'application/json', 404, staticResource.Body.toString()));
        SOD_XS_360ViewPurchasesController obj360View = SOD_XS_360ViewPurchasesController.getPageOrdersAsPerPagination(searchCriteria);
        System.assertEquals(obj360View != null, true, 'The data table has been returned');
        Test.stopTest();
    }

    /**
    * @description Order search: By reservation number
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        16/11/2020
    */ 
     @isTest static void getPurchaseDataObjectTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewPurchasesController.getRecord(acc.Id);
        SOD_XS_360ViewPurchasesController.WrapSearchCriteria searchCriteria = new SOD_XS_360ViewPurchasesController.WrapSearchCriteria(acc);
        searchCriteria.is360View = false;
        searchCriteria.isPurchaseOrders = true;
        searchCriteria.orderNumber = '21336269199';
        String path = PRV_STR_PATH_ORDER + searchCriteria.orderNumber;
        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST1_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', 'application/json', 200, staticResource.Body.toString()));
        object objData = SOD_XS_360ViewPurchasesController.getPurchaseDataObject(searchCriteria);
        System.assertEquals(objData != null, true, 'The data table has been returned');
        Test.stopTest();
    }    

    /**
    * @description:  Get the objects description for show the Reserve Detail
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getDescriptionForReserveTest() {
        String result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getDescriptionForReserve();
        System.assertEquals(result.length() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Get the objects column for show the Product Columns
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getColumnsForProductsPurchaseOrdersTest() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getColumnsForProductsPurchaseOrders();
        System.assertEquals(result.size() > 0, true, 'The data has been returned');
        Test.stopTest();
    }
    /* @description: Get description for sell document
    *  @Autor        Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date         26/03/2021
    */
    @isTest static void getDescriptionForSellDocumentTest() {
        String accLabels;
        Test.startTest();
        accLabels = SOD_XS_360ViewPurchasesController.getDescriptionForSellDocument();
        System.assertEquals(accLabels != null, true, 'The data has been returned');
        Test.stopTest();
    }
    /* @description: Get description for sell document 2
    *  @Autor        Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date         26/03/2021
    */
    @isTest static void getDescriptionForSellDocumentTest2() {
        String accLabels;
        String PRV_OBJ_DOCV = '';
        Test.startTest();
        accLabels = SOD_XS_360ViewPurchasesController.getDescriptionForSellDocument();
        //System.assertEquals(null, accLabels);
        Test.stopTest();
    }
    /* @description: Get columns for products payment vouchers
    *  @Autor        Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @date         26/03/2021
    */
    @isTest static void getColumnsForProductsPaymentVouchersTest() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getColumnsForProductsPaymentVouchers();
        System.assertEquals(result.size() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Get the objects description for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getDescriptionForCaseCreationTest() {
        String result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getDescriptionForCaseCreation();
        System.assertEquals(result.length() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Get the objects labels for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getDescriptionObjectsForCaseTest() {
        Map<String, String> result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getDescriptionObjectsForCase();
        System.assertEquals(result.size() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Get the case Record Types for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getCaseRecordTypeTest() {
        Map<Id, String> result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getCaseRecordType();
        System.assertEquals(result.size() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Get the product columns for Case Creation
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void getProductColumnsForResumeTest() {
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.getProductColumnsForResume();
        System.assertEquals(result.size() > 0, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description:  Create a Case
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    */ 
    @isTest static void processCaseDataTest() {
        StaticResource sr = [SELECT Id, Body 
                             FROM StaticResource 
                             WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEW_CASE_CL LIMIT 1];
        String json = sr.Body.toString();
        String countryIsoCode = 'CL';
        String numberDocument = '13550036-4';
        String caseClaimRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(SOD_XS_DataFactory.PRV_STR_CASE_CLAIM).getRecordTypeId();
        Account acc = [Select Name, SOD_XS_Country__c from Account where SOD_XS_NroDocumento__c =: numberDocument];
        SOD_XS_Country__c p = [Select SOD_XS_Codigo__c, CurrencyIsoCode from SOD_XS_Country__c where SOD_XS_Codigo__c =: countryIsoCode];
        p.Id = acc.SOD_XS_Country__c;
        
        SOD_XS_CentroDeCosto__c b = [Select SOD_XS_CentroDeCosto__c, Name, SOD_XS_NombreCorto__c, SOD_XS_NombreCompleto__c, SOD_XS_TipoDeCC__c, SOD_XS_Country__c from SOD_XS_CentroDeCosto__c where SOD_XS_CentroDeCosto__c =: '214'];
        SOD_XS_CentroDeCosto__c t = [Select SOD_XS_CentroDeCosto__c, Name, SOD_XS_NombreCorto__c, SOD_XS_NombreCompleto__c, SOD_XS_TipoDeCC__c, SOD_XS_Country__c from SOD_XS_CentroDeCosto__c where SOD_XS_CentroDeCosto__c =: '972'];
        SOD_XS_CentroDeCosto__c o = [Select SOD_XS_CentroDeCosto__c, Name, SOD_XS_NombreCorto__c, SOD_XS_NombreCompleto__c, SOD_XS_TipoDeCC__c, SOD_XS_Country__c from SOD_XS_CentroDeCosto__c where SOD_XS_CentroDeCosto__c =: '913'];

        json = json.replace('0017A00000eEyQeQAK', acc.Id);
        json = json.replace('a0555000008Ta3dAAC', p.Id);
        json = json.replace('"CL"', '"'+p.SOD_XS_Codigo__c+'"');
        json = json.replace('"CLP"', '"'+p.CurrencyIsoCode+'"');
        json = json.replace('012550000017QpKAAU', caseClaimRecordTypeId);

        Test.startTest();
        try {
        	String result = SOD_XS_360ViewPurchasesController.processCaseData(json);
        	Case c = [SELECT Id 
                  	  FROM Case 
                      WHERE Id =: result];
        	System.assertEquals(result, c.Id, 'The data has been returned');
        } catch(Exception ex) {
            System.debug('DEBUG: ' + ex.getStackTraceString());
        }
        Test.stopTest();
    }

    /**
    * @description:  Set the view product button
    *  @Author:      Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        07/01/2021
    */ 
    @isTest static void setPrdButtonTest() {
        SOD_XS_DataTableUtily.ButtonDescriptionWrapper result;
        Test.startTest();
        result = SOD_XS_360ViewPurchasesController.setPrdButton();
        System.assertEquals(result != null, true, 'The data has been returned');
        Test.stopTest();
    }

    /**
    * @description Order search for Fcom.
    * @Autor       Rodolfo Valencia, FTC, rlvalencia@falabella.cl
    * @date        30/06/2021
    */     
    @isTest static void getPurchaseDataObjectFcomTest() {
        Account acc = [Select Id from Account where SOD_XS_NroDocumento__c =: '13550036-4'];
        acc = SOD_XS_360ViewPurchasesController.getRecord(acc.Id);
        SOD_XS_360ViewPurchasesController.WrapSearchCriteria searchCriteria = new SOD_XS_360ViewPurchasesController.WrapSearchCriteria(acc);
        searchCriteria.is360View = false;
        searchCriteria.isPurchaseOrders = true;
        searchCriteria.orderNumber = '21336269199';
        String path = PRV_STR_PATH_ORDER + searchCriteria.orderNumber;
        Test.startTest();
        StaticResource staticResource = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST1_CL LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new SOD_XS_JWTRestMock_TEST('', 'application/json', 200, staticResource.Body.toString()));
        object objData = SOD_XS_360ViewPurchasesController.getPurchaseDataObjectFcom(null, searchCriteria);
        System.assertEquals(objData != null, true, 'The data has been returned');
        Test.stopTest();
    } 

}