/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/11/2020
Description  : Test Class JSON - SOD_XS_JSON360ViewProduct_TEST
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade Alviárez    EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA            08/01/2021      initial version
********************************************************************************/
@isTest
public with sharing class SOD_XS_JSON360ViewProduct_TEST {

    /**
	*  @Description: Test JSON of 360 View Product
	*  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
	*  @Date:        08/01/2021
	*/
	@isTest static void arrayOfSkuReserveEventsParseTest() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_VIEW_PRODUCT_CL LIMIT 1];
        test.startTest();
		String json = sr.Body.toString();
        SOD_XS_JSON360ViewProduct obj = SOD_XS_JSON360ViewProduct.parse(json);
        System.assertEquals(obj != null, true, 'The parse of the JSON has been returned');
        test.stopTest();
    }
}