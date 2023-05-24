/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 03/08/2020
Description  : Test Class JSON - SOD_XS_JSONClientsBUC
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
Leonardo Mu�oz              LMG
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            03/08/2020      initial version
1.1      LMG            28/01/2021      Optimize test class
********************************************************************************/
@isTest
public class SOD_XS_JSONClientsBUC_TEST {
	
	/**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
	@testSetup static void setup(){
        test.startTest();
        test.stopTest();
    }
    /**
	*  @Description: Test JSON
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        03/08/2020
	*/
	@isTest static void testParseResponse() {
        test.startTest();
		StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_SEARCHPERSON_CL LIMIT 1];
		String json = sr.Body.toString();
		SOD_XS_JSONResponseClientsBUC obj = SOD_XS_JSONResponseClientsBUC.parse(json);
		System.assertEquals(obj != null, true, 'The json parse has been returned');
		test.stopTest();
    }

	/**
	*  @Description: Test JSON
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        03/08/2020
	*/
	@isTest static void testParse() {
		test.startTest();
		boolean error;
		SOD_XS_JSONClientsBUC obj;
		try {
			obj = SOD_XS_JSONClientsBUC.parse('');			
		} catch (Exception e) {
            error =  e != null ? true:false;
		}
		System.assertEquals(error, true, 'An error has been returned');
		test.stopTest();
	}

	/**
	*  @Description: Test JSON
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        03/08/2020
	*/
	@isTest static void testParseSend() {
		test.startTest();
		boolean error;
		SOD_XS_JSONSendClientsBUC obj;
		try {
			obj = SOD_XS_JSONSendClientsBUC.parse('');			
		} catch (Exception e) {
            error =  e != null ? true:false;
		}
		System.assertEquals(error, true, 'An error has been returned');
		test.stopTest();
	}
}