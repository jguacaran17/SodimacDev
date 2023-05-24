/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 25/01/2020
Description  : Test class for SOD_XS_EnLogger
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Michaell Reis			    MR
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      MR			25/01/2020		Created the file/class
********************************************************************************/
@isTest
private class SOD_XS_EnLogger_TEST
{
    private static final String ACCOUNT_NAME = 'test-acc';
    private static final String SUCCESS = 'success';
    private static final String FAILURE = 'failure';

    static{
        SOD_XS_EnLogger.ENABLE_EVENT = false; //disable event logs
    }

    /**
    *  @Description: verify log creation
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void itShouldCreateSystemLog()
    {
        Test.startTest();
        SOD_XS_EnLogger logger = new SOD_XS_EnLogger();
        logger.log('**************logs**************').push();
        List<EN_Log__c> logs = [SELECT Id FROM EN_Log__c limit 1];
        System.assertEquals(1, logs.size());

        Test.stopTest();
    }

    /**
    *  @Description: itShouldCreateSystemLog2. verify log creation
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void itShouldCreateSystemLog2()
    {
        Test.startTest();
        SOD_XS_EnLogger logger = new SOD_XS_EnLogger();//'**************logs**************'
        logger.log(new Map<String, Object>{
            'Comments' => '**************logs**************',
            'Category' => 'default',
            'Severity' => SOD_XS_EnLogger.SEVERITY_TYPES.ERROR,
            'ClassObject' => SOD_XS_EnLogger_TEST.class,
            'SourceId' => null
        }).push();
        List<EN_Log__c> logs = [SELECT
            Id,Comment__c,Source_Id__c,Severity__c,Apex_Class__c,Category__c
            FROM EN_Log__c limit 1];
        System.assertEquals(1, logs.size());

        EN_Log__c l = logs[0];
        System.assertEquals('**************logs**************', l.Comment__c);
        System.assertEquals(null, l.Source_Id__c);
        System.assertEquals('error', l.Severity__c.toLowerCase());
        System.assertEquals(SOD_XS_EnLogger_TEST.class.toString(), l.Apex_Class__c);
        System.assertEquals('default', l.Category__c);

        Test.stopTest();
    }

    /**
    *  @Description: itShouldCreateSystemLog3. verify log creation
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void itShouldCreateSystemLog3()
    {
        Test.startTest();
        Exception error = null;
        try{
            insert new User(FirstName = 'abc');
        }catch(DmlException e){
            error = e;
            new SOD_XS_EnLogger().log(new Map<String, Object>{
                'ExceptionObj' => e,
                'Severity' => SOD_XS_EnLogger.SEVERITY_TYPES.Warning
            }).push();
        }

        List<EN_Log__c> logs = [SELECT
            Id,Comment__c,Source_Id__c,Severity__c,Apex_Class__c,Description__c,Exception_Type__c,Exception_Stack_Trace__c
            FROM EN_Log__c limit 1];
        System.assertEquals(1, logs.size());

        EN_Log__c l = logs[0];
        System.assertNotEquals(null, l.Description__c);
        System.assertNotEquals(null, l.Exception_Type__c);
        System.assertNotEquals(null, l.Exception_Stack_Trace__c);
        System.assertEquals('warning', l.Severity__c.toLowerCase());

        Test.stopTest();
    }

    /**
    *  @Description: itShouldCreateSystemLogFuture. Verify create log in future
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void itShouldCreateSystemLogFuture()
    {
        Test.startTest();
        SOD_XS_EnLogger logger = new SOD_XS_EnLogger();
        logger.log('**************logs**************').pushAsync();

        Test.stopTest();
        List<EN_Log__c> logs = [SELECT Id FROM EN_Log__c limit 1];
        System.assertEquals(1, logs.size());
    }

    /**
    *  @Description: Test log error
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void itShouldLogError()
    {
        Test.startTest();
        try{
            insert new User(FirstName = 'abc');
        }catch(Exception e){
            SOD_XS_EnLogger logger = new SOD_XS_EnLogger();
            logger.log(e);
            logger.log(e, SOD_XS_EnLogger.class);
            logger.log(e, SOD_XS_EnLogger.class, 'myCat');
            logger.log(e, '500123', SOD_XS_EnLogger.class);
            logger.log(e, SOD_XS_EnLogger.class, 'myCat', SOD_XS_EnLogger.SEVERITY_TYPES.ERROR, null);
            logger.pushAsync();
        }

        Test.stopTest();
        List<EN_Log__c> logs = [SELECT Id FROM EN_Log__c limit 1000];
        System.assertEquals(5, logs.size());
    }

    /**
    *  @Description: Test bulkfied log insertion
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void testBulkifiedInsert()
    {
        Test.startTest();
        SOD_XS_EnLogger logger = new SOD_XS_EnLogger();
        logger
        .log('**************logs 1**************')
        .log('**************logs 2**************')
        .log('**************logs 3**************').pushAsync();

        Test.stopTest();

        //inserted in future method, has to assert after Test.stopTest
        List<EN_Log__c> logs = [SELECT Id FROM EN_Log__c limit 1000];
        System.assertEquals(3, logs.size());
    }

    /**
    *  @Description: Test verify log population
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void verifyLogPopulation()
    {
        Test.startTest();
        try{
            insert new User(FirstName = 'abc');//will raise error due to system validation rule
        }catch(Exception e){
            SOD_XS_EnLogger logger = new SOD_XS_EnLogger();
            logger.log(e, SOD_XS_EnLogger.class, 'myCat', SOD_XS_EnLogger.SEVERITY_TYPES.ERROR, '001');
            logger.pushAsync();
        }

        Test.stopTest();//wait future job to finish

        //inserted in future method, has to assert after Test.stopTest
        EN_Log__c log = [
            SELECT
            Id,Apex_Class__c,Category__c,Comment__c,
            Description__c,Exception_Stack_Trace__c,
            Exception_Type__c,Severity__c,Source_Id__c
            FROM EN_Log__c limit 1];

        System.assertEquals('001', log.Source_Id__c);
        System.assertEquals(String.valueOf(SOD_XS_EnLogger.SEVERITY_TYPES.ERROR), log.Severity__c);
        System.assertNotEquals(null, log.Exception_Type__c);
        System.assertNotEquals(null, log.Exception_Stack_Trace__c);
        System.assertNotEquals(null, log.Description__c);
        System.assertEquals('myCat', log.Category__c);
        System.assert(String.valueOf(log.Apex_Class__c).contains('SOD_XS_EnLogger'));
    }

    /**
    *  @Description: Test log database save result
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void logDatabaseSaveResult(){
        Test.startTest();
        Database.SaveResult[] results = Database.insert(
            new List<SObject>{
                new User(FirstName = 'abc'),//will fail
                new User(FirstName = '123'),//will fail
                new Account(Name = 'newAccount', BillingCity='Montreal')
            },
            false);//will raise error due to system validation rule

        SOD_XS_EnLogger.Instance.log(results).pushAsync();
        Test.stopTest();//wait future job to finish

        EN_Log__c[] logs = [
            SELECT
            Id,Apex_Class__c,Category__c,Comment__c,
            Description__c,Exception_Stack_Trace__c,
            Exception_Type__c,Severity__c,Source_Id__c
            FROM EN_Log__c];

        System.assertEquals(logs.size(), logs.size());//should generate two logs
        EN_Log__c log = logs[0];
        System.assertEquals(String.valueOf(SOD_XS_EnLogger.SEVERITY_TYPES.ERROR), log.Severity__c);
        System.assertNotEquals(null, log.Comment__c);
    }

    /**
    *  @Description: Test log database upsert result
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void logDatabaseUpsertResult(){
        Test.startTest();
        Database.UpsertResult[] results = Database.upsert(
            new List<User>{
                new User(FirstName = 'abc'),//will fail
                new User(FirstName = '123')//will fail
            },
            false);//will raise error due to system validation rule

        SOD_XS_EnLogger.Instance.log(results).pushAsync();
        Test.stopTest();//wait future job to finish

        EN_Log__c[] logs = [
            SELECT
            Id,Apex_Class__c,Category__c,Comment__c,
            Description__c,Exception_Stack_Trace__c,
            Exception_Type__c,Severity__c,Source_Id__c
            FROM EN_Log__c];

        System.assertEquals(2, logs.size());//should generate two logs
        EN_Log__c log = logs[0];
        System.assertEquals(String.valueOf(SOD_XS_EnLogger.SEVERITY_TYPES.ERROR), log.Severity__c);
        System.assertNotEquals(null, log.Comment__c);
    }

    /**
    *  @Description: Test should publish log event
    *  @Autor:       MR, Deloitte, mreisg@deloitte.com
    *  @Date:        25/01/2020
    */    
    @isTest
    static void shouldPublishLogEvent(){
        SOD_XS_EnLogger.ENABLE_EVENT = true; //disable event logs

        Test.startTest();
        SOD_XS_EnLogger logger = SOD_XS_EnLogger.Instance;
        logger.log('**************log1**************');
        logger.log('**************log2**************');
        Exception e = new AuraHandledException('Custom Error');
        logger.log(e);

        logger.pushAsync();
        Test.stopTest();

        List<EN_Log__c> logs = [SELECT Id,Severity__c FROM EN_Log__c limit 10];
        System.assertEquals(logs.size(), logs.size());

        SOD_XS_EnLogger.ENABLE_EVENT = false;
    }
}