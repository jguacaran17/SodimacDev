/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 12/02/2020
Description  : Test Class for the Utility class SOD_XS_EnUtility
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
Eilhert Andrade A.          EAA
Leonardo Muñoz              LMG
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			12/02/2020		Created the file/class
1.1      EAA        18/08/2020      Add method 
1.1      LMG        28/01/2021      Optimize test class
********************************************************************************/

@isTest
private class SOD_XS_EnUtility_TEST {
    
    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup() {
        Test.startTest();
        SOD_XS_DataFactory.createAccountXS(true, SOD_XS_DataFactory.PRV_STR_B2C, 'RUT', '22333889-5','CL');
        Test.stopTest(); 
    }
    /**
    *  @Description: test RecordType Getters
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */
    @isTest static void testRecordTypeGetters()
    {
        Test.startTest();
        
        Id recId = SOD_XS_EnUtility.getRecordTypeID('Account', 'B2B');
        Map<String, Id> recIds1   = SOD_XS_EnUtility.getRecordTypeIDs('Account', new List<String>{'B2B', 'B2C'});
        Map<String, Id> recIds2_1 = SOD_XS_EnUtility.getAllRecordTypeIDsMap('Contact');
        Map<String, Id> recIds2_2 = SOD_XS_EnUtility.getAllRecordTypeIDsMap(new Set<String>{'Contact'});
        Map<String, Id> recIds3   = SOD_XS_EnUtility.getAllRecordTypeIDsMap(new Set<String>{'Contact', 'Task'});
        Map<String, RecordType> recTps = SOD_XS_EnUtility.getAllRecordTypes(new Set<String>{'Account'});
        
        Test.stopTest();
        
        System.assert(
            recId == recIds1.get('AccountB2B')
            , 'Expected B2B Id to be in the group; got ' + recId + ' :: ' + JSON.serialize(recIds1)
        );
        System.assert(
            recIds2_1 == recIds2_2
            , 'Expected same results; got ' + JSON.serialize(recIds2_1) + ' :: ' + JSON.serialize(recIds2_2)
        );
        for(String devName : recTps.keySet())
        {
            if(recIds1.containsKey('Account'+devName))
                System.assert(
                    recIds1.get('Account'+devName) == recTps.get(devName).Id
                    , 'Expected same Ids; got ' + JSON.serialize(recIds1) + ' :: ' + JSON.serialize(recTps)
                );
        }
    }
    /**
    *  @Description: test Get SObjects
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void testGetSObjects() {
        Test.startTest();
        Account acc1 = [Select id, Name from Account where SOD_XS_NroDocumento__c =: '22333889-5'];
        List<Account> accList = (List<Account>)SOD_XS_EnUtility.GetSObjects(new Set<Id>{acc1.Id});
        System.assert(accList != null);
        Test.stopTest(); 
    }
    /**
    *  @Description: test Get SObjects Simple
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void testGetSObjectsSimple() {
        Test.startTest();
        Account acc1 = [Select id, Name from Account where SOD_XS_NroDocumento__c =: '22333889-5'];
        List<Account> accList = (List<Account>)SOD_XS_EnUtility.GetSObjectsSimple(new Set<Id>{acc1.Id});
        System.assert(accList != null);
        Test.stopTest();
    }
    /**
    *  @Description: test Strings
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void testStrings() {
        test.startTest();
        System.assert(SOD_XS_EnUtility.cleanTrimLength(null,  20) == '');
        System.assert(SOD_XS_EnUtility.cleanTrimLength('    ',20) == '');
        System.assert(SOD_XS_EnUtility.cleanTrimLength('H1Y 1M9',20) == 'H1Y 1M9');
        System.assert(SOD_XS_EnUtility.cleanTrimLength('H1Y 1M9 is a very long postal code',20) == 'H1Y 1M9 is a very lo');
    	test.stopTest();
    }
      
    /**
    *  @Description: Test Method to SOD_XS_EnUtility getUserDetails method
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */
    @isTest static void getUserDetailsTest(){
        test.startTest();
        User u = SOD_XS_DataFactory.createUser();
        User us = [SELECT Name, Email
                   FROM User WHERE UserRole.DeveloperName != null
                   LIMIT 1];
        
        User us2 = SOD_XS_EnUtility.getUserDetails(us.Id);
        System.assertEquals(us.Name, us2.Name);
    	test.stopTest();
    }
    
    /**
    *  @Description: Test Method to SOD_XS_EnUtility getCurrentUserDetails method
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void getCurrentUserDetailsTest(){
        test.startTest();
        User us = SOD_XS_EnUtility.getCurrentUserDetails();
        System.assertNotEquals(null, us);
    	test.stopTest();
    }
    
    /**
    *  @Description: Test Method to SOD_XS_EnUtility removeDiacritics method
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void removeDiacriticsTest(){
        Test.startTest();
        System.assertEquals('Hello a toi pan', SOD_XS_EnUtility.removeDiacritics('Ḧéļḻṏ à tôî påñ'));
        Test.stopTest();
    }

    /**
    *  @Description: Test Method to SOD_XS_EnUtility phoneClean* methods
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void phoneCleanTests(){
        Test.startTest();
        System.assertEquals('1338001800GOTJUNKHELLOTOIPAN', SOD_XS_EnUtility.phoneCleanup('+1-33 (800) 1-800-GOTJUNK Ḧéļḻṏ tôî påñ'));
        System.assertEquals('1338001800468586543556864726', SOD_XS_EnUtility.phoneCleanAll('+1-33 (800) 1-800-GOTJUNK Ḧéļḻṏ tôî påñ'));
        Test.stopTest();
    }

    /**
    *  @Description: Test Method to SOD_XS_EnUtility getDescribedObjects method
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        12/02/2020
    */    
    @isTest static void getDescribedObjectsTests(){
        Test.startTest();
        String objActual = SOD_XS_EnUtility.getDescribedObjects( new List<String>{'Account'} );
        System.assert(objActual.contains('Account'));
        Test.stopTest();
    }
    /**
    *  @Description: Test Method to SOD_XS_EnUtility validateEmail method
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        18/08/2020
    */    
    @isTest static void validateEmail_Test(){
        Test.startTest();
        Boolean res = SOD_XS_EnUtility.validateEmail('test@test.com');
        System.assert(res);
        Test.stopTest();
    } 
    /**
    *  @Description: Test Method to SOD_XS_EnUtility getFieldNameLabel method
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        18/08/2020
    */    
    @isTest static void getFieldNameLabel_Test(){
        Test.startTest();
        String res = SOD_XS_EnUtility.getFieldNameLabel('Account','Name');
        System.assert(res != null);
        Test.stopTest();
    } 
    /**
    *  @Description: Test Method to SOD_XS_EnUtility getMapFromString method
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        18/08/2020
    */    
    @isTest static void getMapFromString_Test(){
        Test.startTest();
        String req = 'Pais:Chile,Sigla:CL';
        Map<String,String> res = SOD_XS_EnUtility.getMapFromString(req);
        System.assert(res != null);
        Test.stopTest();
    }
}