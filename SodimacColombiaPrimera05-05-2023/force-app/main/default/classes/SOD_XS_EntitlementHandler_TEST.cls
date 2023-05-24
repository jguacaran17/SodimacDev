/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 28/05/2020
Description  : Test Class SOD_XS_EntitlementHandler
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			28/05/2020		initial version
1.1      LMG            26/01/2021      Optimize test class
********************************************************************************/
@isTest
public class SOD_XS_EntitlementHandler_TEST {
    
    private static String PRV_STR_B2C = SOD_XS_DataFactory.PRV_STR_B2C;    
    private static String PRV_STR_B2 = SOD_XS_DataFactory.PRV_STR_B2B;
    
    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        Test.startTest();
        SOD_XS_DataFactory.createUser();
        test.stopTest();
    }
    /**
    *  @description Method after insert BTOCCL Chile
    *  @author      ATO, Deloitte, atejoso@deloitte.com
    *  @date        28/05/2020
    */    
    @istest
    static void afterInsertBTOCCLTest() {
        Test.startTest();
        User u = [select id from User limit 1];
        System.runAs(u) {
            Id accId = SOD_XS_DataFactory.NewDataXS(PRV_STR_B2C);
            Entitlement entObj = SOD_XS_DataFactory.createEntitlement(false); 
            entObj.AccountId = accId;
            entObj.StartDate = system.today();
            Insert entObj;
        }        
        Test.stopTest();
        
        Entitlement ent = [Select StartDate from Entitlement limit 1];
        system.assertEquals(system.today(), ent.StartDate);
    }
    /**
    *  @description Method after insert BTOCPE Perú
    *  @author      ATO, Deloitte, atejoso@deloitte.com
    *  @date        28/05/2020
    */    
    @istest
    static void afterInsertBTOCPETest() {
        Test.startTest();
        User u = [select id from User limit 1];
        System.runAs(u) {
            Id accId = SOD_XS_DataFactory.NewDataXS(PRV_STR_B2C);
            Entitlement entObj = SOD_XS_DataFactory.createEntitlement(false);         
            entObj.AccountId = accId;
            entObj.StartDate = system.today();
            Insert entObj;
        }        
        Test.stopTest();

        Entitlement ent = [Select StartDate from Entitlement limit 1];
        system.assertEquals(system.today(), ent.StartDate);
    }
    /**
    *  @description Method after insert BTOCMX México
    *  @author      ATO, Deloitte, atejoso@deloitte.com
    *  @date        28/05/2020
    */    
    @istest
    static void afterInsertBTOCMXTest() {
        Test.startTest();
        User u = [select id from User limit 1];
        System.runAs(u) {
            Id accId = SOD_XS_DataFactory.NewDataXS(PRV_STR_B2C);
            Entitlement entObj = SOD_XS_DataFactory.createEntitlement(false);         
            entObj.AccountId = accId;
            entObj.StartDate = system.today();
            Insert entObj;
        }        
        Test.stopTest();

        Entitlement ent = [Select StartDate from Entitlement limit 1];
        system.assertEquals(system.today(), ent.StartDate);
    }
    /**
    *  @description Method before update BTOCMX México
    *  @author      ATO, Deloitte, atejoso@deloitte.com
    *  @date        28/05/2020
    */    
    @istest
    static void beforeUpdateBTOCMXTest() {
        Entitlement entObj;
        User u = [select id from User limit 1];
        System.runAs(u) {
            Id accId = SOD_XS_DataFactory.NewDataXS(PRV_STR_B2C);
            entObj = SOD_XS_DataFactory.createEntitlement(false);         
            entObj.AccountId = accId;
            entObj.StartDate = system.today();
            Insert entObj;
        } 
        Test.startTest();
        System.runAs(u) {
            Update entObj;
        } 
        Test.stopTest();
        
        Entitlement ent = [Select StartDate from Entitlement limit 1];
        system.assertEquals(system.today(), ent.StartDate);
    }
}