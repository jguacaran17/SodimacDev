/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 06/01/2021
Description  : Test Class SOD_XS_360ViewProductController
History      : CMRSC-3932
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade A.			 EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA			06/01/2021		initial version
********************************************************************************/
@isTest
public with sharing class SOD_XS_360ViewProductController_TEST {
    
    private static final String PRV_STR_PATHCLIENTCL;
    private static final String PRV_STR_CNTCL;
    private static final String PRV_STR_RESRV;
    private static final String PRV_STR_SKU;
    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        06/01/2021
    */
    static {

        PRV_STR_PATHCLIENTCL = '/200935388/sku-reserves/2809575/events';
        PRV_STR_CNTCL = 'CL';
        PRV_STR_RESRV = '200935388';
        PRV_STR_SKU = '2809575';
    }

    /**
    * @description Test for initClass method
    * @Autor       EAA, Deloitte, eandradea@deloitte.com
    * @date        07/01/2021
    */ 
    @isTest static void initClassTest() {
        
        Test.startTest();
        String path = SOD_XS_JWTRestMock_TEST.endPointJWTRestMockTest(PRV_STR_CNTCL, SOD_XS_JWTRestMock_TEST.PBC_STR_PATH_VIEWPRODUCTS) + PRV_STR_PATHCLIENTCL;
        List<String> endPoint = new List<String>();
        endPoint.add(path);
        List<String> resBody = new List<String>();
        resBody.add(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_VIEW_PRODUCT_CL);
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(SOD_XS_JWTRestMock_TEST.PBC_STR_JSON_VIEW_PRODUCT_CL);
        mock.setStatusCode(200);
        mock.setHeader(SOD_XS_JWTRestMock_TEST.PBC_STR_CONTENTTYPE, SOD_XS_JWTRestMock_TEST.PBC_STR_APPJSON);
        Test.setMock(HttpCalloutMock.class, mock);
        SOD_XS_360ViewProductController objViewProduct = SOD_XS_360ViewProductController.initClass(PRV_STR_RESRV, PRV_STR_SKU, PRV_STR_CNTCL);
        
        System.assertEquals(objViewProduct.dataJson.length() > 0, true, 'The data table has been returned');
        System.assertEquals(!objViewProduct.prdLabelsTable.isEmpty(), true, 'The columns of the data table have been returned');
        Test.stopTest();
    }

    
}