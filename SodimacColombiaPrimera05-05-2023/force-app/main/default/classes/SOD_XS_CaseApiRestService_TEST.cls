/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/02/2021
Description  : SOD_XS_CaseApiRestService_TEST Class - Test Class 
History      : CMRSC-5107
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      Deloitte
Lazaro Quintana 			LQS (lquintanas@deloitte.com)
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      LQS			12/02/2021		initial version
********************************************************************************/
@IsTest
public class SOD_XS_CaseApiRestService_TEST {
    
	/*********************************************************************************************************************
	 * @description Method testGetCases test the search cases per filters  
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/    
    @isTest static void testGetCases() {
        // create a generic case
        Case thisCase = createTestRecord();
        
        // Set up a test request endpoint + params + method
        DateTime todayDateTime = DateTime.now();
		String today = todayDateTime.format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/caseUpdateService/';
        request.httpMethod = 'GET';
        request.addParameter('status', 'New');
        request.addParameter('fechaCompraDesde',today);
        request.addParameter('fechaCompraHasta',today);
        request.addParameter('fechaCreacionDesde',today);
        request.addParameter('fechaCreacionHasta',today);
        request.addParameter('recordTypeId','012550000017QpKAAU');
        RestContext.request = request;        
        
        // Call the method to test
        Test.startTest();
        	SOD_XS_CaseApiRestService.ReturnClass caseList = SOD_XS_CaseApiRestService.SearchCasesByFilter();
        Test.stopTest();   
        
        // Verify results
        System.assert(caseList != null);
        System.assert((caseList.message == 'Búsqueda ejecutada con éxito.' || caseList.message == 'No se encontraron registros, revise los parámetros de búsqueda.'),'OK');
    }
    
    
    /*********************************************************************************************************************
	 * @description Method testGetCasesNoParams test the search cases per filters using no params 
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest static void testGetCasesNoParams() {
        // create a generic case
        Case thisCase = createTestRecord();
        
        // Set up a test request
        DateTime todayDateTime = DateTime.now();
		String today = todayDateTime.format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/caseUpdateService/';
        request.httpMethod = 'GET';
        RestContext.request = request;
        
        // Call the method to test
        Test.startTest();
        	SOD_XS_CaseApiRestService.ReturnClass caseList = SOD_XS_CaseApiRestService.SearchCasesByFilter();
        Test.stopTest();
        
        // Verify results
        System.assert(caseList != null);
        System.assert((caseList.message == 'Búsqueda ejecutada con éxito.' || caseList.message == 'No se encontraron registros, revise los parámetros de búsqueda.'),'OK');
    }
    
    
    /*********************************************************************************************************************
	 * @description Method testGetCasesException test the exception in the get method
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest static void testGetCasesException() {
        // create a generic case
        Case thisCase = createTestRecord();
        
        // Set up a test request
        DateTime todayDateTime = DateTime.now();
		String today = todayDateTime.format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/caseUpdateService/';
        request.httpMethod = 'GET';
        request.addParameter('recordTypeId','22');
        RestContext.request = request;        
        
        // Call the method to test
        Test.startTest();
          SOD_XS_CaseApiRestService.ReturnClass caseList = SOD_XS_CaseApiRestService.SearchCasesByFilter();
        Test.stopTest();
        
        // Verify results
        System.assert(caseList != null);
        System.assertEquals('false', caseList.success);
    }
    
    
    /*********************************************************************************************************************
	 * @description Method testUpdateCaseFields testing update case patch method
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
	@isTest static void testUpdateCaseFields() {
        // create a generic case
        Case thisCase = createTestRecord();
        
        // Set up a test request
        DateTime todayDateTime = DateTime.now();
		String today = todayDateTime.format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/caseUpdateService/'+thisCase.Id;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"status" : "En Proceso","caseComment" : "Este comentario se agrega al caso 3333","caseFile" : "JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4"}');
        RestContext.request = request;        
        
        RestResponse res = new RestResponse();
        RestContext.response = res;
        
        // Call the method to test
        Test.startTest();
        	SOD_XS_CaseApiRestService.ReturnClassCase caseList = SOD_XS_CaseApiRestService.updateCaseFields();
        Test.stopTest();
        
        // Verify results
        System.assert(caseList != null);
        System.assertEquals('true', caseList.success);
    } 
    
    /*********************************************************************************************************************
	 * @description Method testUpdateCaseFieldsException testing the exception in update case patch method
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest static void testUpdateCaseFieldsException() {
        // create a generic case
        Case thisCase = createTestRecord();
        
        // Set up a test request
        DateTime todayDateTime = DateTime.now();
		String today = todayDateTime.format('yyyy-MM-dd');
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/caseUpdateService/';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf('{"status" : "En Proceso","caseComment" : "Este comentario se agrega al caso 3333","caseFile" : "JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4}');
        RestContext.request = request;
        
        RestResponse res = new RestResponse();
        RestContext.response = res;

        // Call the method to test
        Test.startTest();
        	SOD_XS_CaseApiRestService.ReturnClassCase caseList = SOD_XS_CaseApiRestService.updateCaseFields();
        Test.stopTest();
        
        // Verify results
        System.assert(caseList != null);
        System.assertEquals('false', caseList.success);
    }        
    
    
    /*********************************************************************************************************************
	 * @description Method testReturnClassCase testing returnClassCase inner class of the SOD_XS_CaseApiRestService
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest
    static void testReturnClassCase() {
        // create a generic case
        Case thisCase = createTestRecord();
        List<Case> listCase = new List<Case>();
        listCase.add(thisCase);
        // Call the method to test
        Test.startTest();
        	SOD_XS_CaseApiRestService.ReturnClassCase newCase = new SOD_XS_CaseApiRestService.ReturnClassCase('true', 'success', 'success', 'success', 'success', listCase, 1);
        Test.stopTest();
        
        // Verify results
        system.assertEquals('success', newCase.message);
    }
    
    
    /*********************************************************************************************************************
	 * @description Method testReturnClass testing returnClass, inner class of the SOD_XS_CaseApiRestService
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest
    static void testReturnClass() {
        // create a generic list of cases
        List<Case> thisCases = createTestRecords();
        
        // Call the method to test
        Test.startTest();
         SOD_XS_CaseApiRestService.ReturnClass newCase = new SOD_XS_CaseApiRestService.ReturnClass('true', 'success', thisCases, 3);
        Test.stopTest();
        
        // Verify results
        system.assertEquals('success', newCase.message);
    }
    
    
    /*********************************************************************************************************************
	 * @description Method testCheckValidateInput testing CheckValidateInput inner method of the SOD_XS_CaseApiRestService
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    @isTest
    static void testCheckValidateInput() {
        // Call the method to test
        Test.startTest();
        	String fieldInput = SOD_XS_CaseApiRestService.CheckValidateInput('34234 2342');
        Test.stopTest();
        
        // Verify results
        system.assertEquals('342342342', fieldInput);
    }
    
    
    
    /*********************************************************************************************************************
	 * @description Helper method create a single case
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/ 
    static Case createTestRecord() {
        // Create a test record
        Case caseTest = new Case(
            Subject='Test record',
            Status='New',
            Origin='Phone',
            Priority='Medium');
        insert caseTest;
        return caseTest;
    }  

    
    /*********************************************************************************************************************
	 * @description Helper method create a list of cases
     * @author  Lazaro Quintana, Deloitte, lquintanas@deloitte.com 12/02/2021
     * @return  no return
	 *********************************************************************************************************************/
    static List<Case> createTestRecords() {
        // Create test list of 3 records
        List<Case> caseList = new List<Case>();  
        caseList.add(new Case(Subject='Test record',Status='New',Origin='Phone',Priority='Medium'));
        caseList.add(new Case(Subject='Test record2',Status='En Proceso',Origin='Phone',Priority='Medium'));
        caseList.add(new Case(Subject='Test record3',Status='Working',Origin='Phone',Priority='Medium'));
        return caseList;
    }  
    
    
    
    
	
}