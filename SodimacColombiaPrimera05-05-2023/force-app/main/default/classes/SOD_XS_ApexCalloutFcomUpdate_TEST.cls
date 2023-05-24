/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ApexCalloutFcomUpdate_Test
Comment: Test to SOD_XS_ApexCalloutFcomUpdate class
**********************************************************
*/

@isTest
public class SOD_XS_ApexCalloutFcomUpdate_TEST {
    //Creacion de Caso con respuesta Procede
    private static testMethod void execute(){
        Test.startTest();
        User u1 = createUser();
        System.runas(u1) { 
            Id accountId = createAccount();
            List<Account> accs = [Select Id, PersonContactId FROM Account WHERE Id =: accountId];
            Id contactId = accs[0].PersonContactId;
            Id caseId = createCase(accountId, contactId, u1.Id, '0');
            System.debug('Case Id==>'+caseId);
            List<Id> caseList = new list<Id>();
            caseList.add(caseId); 
        
            Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
            SOD_XS_ApexCalloutFcomUpdate.SOD_XS_ApexCalloutFcomUpdate(caseList);
        }
        Test.stopTest();
    }
    
    //Creacion de Caso con respuesta No Procede
    private static testMethod void execute2(){
        Test.startTest();
        User u1 = createUser();
        System.runas(u1) { 
            Id accountId = createAccount();
            List<Account> accs = [Select Id, PersonContactId FROM Account WHERE Id =: accountId];
            Id contactId = accs[0].PersonContactId;
            Id caseId = createCase(accountId, contactId, u1.Id, '1');
            System.debug('Case Id==>'+caseId);
            List<Id> caseList = new list<Id>();
            caseList.add(caseId); 
        
            Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
            SOD_XS_ApexCalloutFcomUpdate.SOD_XS_ApexCalloutFcomUpdate(caseList);
        }
        Test.stopTest();
    }
    
    //Creacion de Caso sin tipo de cierre
    private static testMethod void execute3(){
        Test.startTest();
        User u1 = createUser();
        System.runas(u1) { 
            Id accountId = createAccount();
            List<Account> accs = [Select Id, PersonContactId FROM Account WHERE Id =: accountId];
            Id contactId = accs[0].PersonContactId;
            Id caseId = createCase(accountId, contactId, u1.Id, '');
            System.debug('Case Id==>'+caseId);
            List<Id> caseList = new list<Id>();
            caseList.add(caseId); 
        
            Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
            SOD_XS_ApexCalloutFcomUpdate.SOD_XS_ApexCalloutFcomUpdate(caseList);
        }
        Test.stopTest();
    }
    
    public static User createUser() {
        Profile profile1 = [Select Id from Profile where name = 'SOD XS Administrador de Sistemas'];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  FirstName = 'Test',
                              LastName = 'Test',
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              UserRoleId = portalRole.Id,
                              XS_AreaDelUsuario__c = 'XS_Administracion',
                              XS_CentroDeCosto__c = '123',
                              Country = 'Chile',
                              ProfileId = profile1.Id);
        
        insert tuser;
        
        User u1 = [SELECT id from User WHERE Id=: tuser.Id LIMIT 1];
        
        return u1;
    }
    
    //Method for Account Creation
    public static Id createAccount(){
        createCountry();
        RecordType accountRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True AND DeveloperName='PersonAccount' Limit 1];
        List<SOD_XS_Country__c> Pais = [SELECT Id FROM SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL'];
        Account acc = new Account();    
        acc.FirstName = 'Testcliente';
        acc.LastName = 'TestAp';
        acc.SOD_XS_NroDocumento__c = '17674839-7';
        acc.SOD_XS_Country__c = Pais[0].Id;
        acc.SOD_XS_TipoDocumento__c = 'RUT';
        acc.RecordTypeId = accountRT.Id;
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '957483954';
        acc.PersonMobilePhone = '647382902';
        insert acc;
        return acc.Id;
    }

    //Method for Country creation
    public static void createCountry(){
        SOD_XS_Country__c pais = new SOD_XS_Country__c();
        pais.Name = 'Chile';
        pais.SOD_XS_Codigo__c = 'CL';
        pais.CurrencyIsoCode = 'CLP';
        insert pais;
    }
    
    public static Id createCase(Id accountId, Id contactId, Id u1, String opt){
        recordtype rc2 = [SELECT Id,Name,Developername FROM RecordType WHERE SObjectType = 'Case' and Developername = 'SOD_XS_Reclamo'];
        Case c = new Case();
        c.RecordTypeId = rc2.Id;
        c.Status = 'Closed';
        c.Origin = 'Portal';
        c.Subject = 'Asunto de Prueba';
        c.Description = 'Descripcion del Caso';
        c.SOD_XS_Area__c = 'Cajas';
        c.SOD_XS_Motivo__c = 'Mal Registro Pago de Deuda CMR';
        c.SOD_XS_Submotivo__c = '';
        c.SOD_XS_FormadePago__c = '';
        c.SOD_XS_FechaDeCompra__c = Date.newInstance(2021, 04, 01);
        c.AccountId = accountId;
        c.ContactId = contactId;
        c.OwnerId = u1;
        c.SOD_XS_IdExterno__c = '00394919';
        c.SOD_XS_DescripcionCierre__c = 'Cierre del Caso';
        if(opt == '0'){
            c.SOD_XS_ProcedeRequerimiento__c = 'Sí';
        }
        else if(opt == '1'){
           c.SOD_XS_ProcedeRequerimiento__c = 'No';
        }
        else{
            c.SOD_XS_ProcedeRequerimiento__c = '';
        }
        
        insert c;
        
        return c.Id;
    }
    
    
}