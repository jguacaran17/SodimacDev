/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/11/2020
Description  : Test Class JSON - SOD_XS_JSON360ViewClient_TEST
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            17/11/2020      initial version
********************************************************************************/
@isTest
public with sharing class SOD_XS_JSON360ViewClient_TEST {
    
    /**
	*  @Description: Test JSON of 360 View
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        17/11/2020
	*/
	@isTest static void threeHundredAndSixtyViewParseTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_360VIEWLAST10_CL LIMIT 1];
        test.startTest();
		String json = sr.Body.toString();
        SOD_XS_JSON360ViewClient obj = SOD_XS_JSON360ViewClient.parse(json);
        System.assertEquals(obj != null, true, 'The parse of the JSON has been returned');
        test.stopTest();
    }
    
    /**
	*  @Description: Test JSON of purchase orders
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        17/11/2020
	*/
	@isTest static void purchaseOrdersParseTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_PURCHARSEORDERBYORDERNUM_CL LIMIT 1];
        test.startTest();
		String json = sr.Body.toString();
		SOD_XS_JSON360ViewClient obj = SOD_XS_JSON360ViewClient.parse(json);
        System.assertEquals(obj != null, true, 'The parse of the JSON has been returned');
        test.stopTest();
    }

    /**
	*  @Description: Test JSON of Sales Document
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        17/11/2020
	*/
	@isTest static void salesDocumentParseTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_PURCHARSEORDERBYSLSDOC_CL LIMIT 1];
        test.startTest();
		String json = sr.Body.toString();
		SOD_XS_JSON360ViewClient obj = SOD_XS_JSON360ViewClient.parse(json);
        System.assertEquals(obj != null, true, 'The parse of the JSON has been returned');
        test.stopTest();
    }
    
    /**
	*  @Description: Test JSON of reseve number
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        17/11/2020
	*/
	@isTest static void reserveNumberParseTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_PURCHARSEORDERBYRSVNUM_CL LIMIT 1];
        test.startTest();
		String json = sr.Body.toString();
		SOD_XS_JSON360ViewClient obj = SOD_XS_JSON360ViewClient.parse(json);
        System.assertEquals(obj != null, true, 'The parse of the JSON has been returned');
        test.stopTest();
    }

    /**
	*  @Description: Test force error
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        17/11/2020
	*/
    @isTest static void itShould()
    {
        test.startTest();
        try {
            String json = '';
            SOD_XS_JSON360ViewClient j = new SOD_XS_JSON360ViewClient();
            SOD_XS_JSON360ViewClient.parse(json);            
        } catch(Exception e) {     
            System.assertEquals(e != null, true, 'An error has occurred');
        }
        test.stopTest();
    }
}