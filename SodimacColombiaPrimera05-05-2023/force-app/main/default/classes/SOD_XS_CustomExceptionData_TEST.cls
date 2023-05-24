/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 20/12/2020
Description  : Test Class SOD_XS_CustomExceptionData
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			20/12/2020		initial version
********************************************************************************/
@isTest
public with sharing class SOD_XS_CustomExceptionData_TEST {

    /**
    * @description Test all the methods of the SOD_XS_CustomExceptionData class
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        20/12/2020
    */ 
    @isTest static void allMethodsTest() {
        DmlException e = new DmlException();
        e.setMessage('Error');
        Test.startTest();
        SOD_XS_CustomExceptionData cstExp = new SOD_XS_CustomExceptionData('Test Error', e.getMessage(), e.getLineNumber());
        System.assertEquals(cstExp != Null, true, 'An error has been thrown');
        Test.stopTest();
    }
}