/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 19/10/2018
Description  : SOD_XS_TriggerHandler_TEST
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Felipe Paulino			    FP
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      FP			19/10/2018		Created the file/class
1.1      LMG        27/01/2021      Optimize test class
********************************************************************************/

@isTest
public class SOD_XS_TriggerHandler_TEST {
    
    /**
    * @description: Initialize data for the test
    * @Autor        LMG, Deloitte, lmunozg@deloitte.com
    * @date         26/03/2021
    */
    @testSetup static void setup(){
        Test.startTest();
        test.stopTest();
    }
    /**
    *  @Description: Custom metadata type record for account needed for this test
    *  @Autor:       Felipe Paulino, Deloitte, fpaulinoc@deloitte.com
    *  @Date:        19/10/2018
    */ 
	@isTest
    static void triggerFactoryTest(){
        Test.startTest();

        Account c = new Account(Name = 'XXX');
        Database.insert(c, false);
        c.Name = 'FFF';
        Database.update(c, false);
        Test.stopTest();

        system.assertEquals(c.Name, 'FFF');
    }
    /**
    *  @Description: trigger Factory No Handler
    *  @Autor:       Felipe Paulino, Deloitte, fpaulinoc@deloitte.com
    *  @Date:        19/10/2018
    */
    @isTest
    static void triggerFactoryNoHandlerTest(){
        String msg = '';
        test.startTest();
        try{
        	new SOD_XS_TriggerHandler(Contact.sObjectType).Run();
        }catch(Exception ex){
            msg = ex.getMessage();
        }
        test.stopTest();
        
        System.assertEquals('Attempt to de-reference a null object', msg);
    }

    private class ConcreteHandler extends SOD_XS_AbstractTriggerHandler{
    }

}