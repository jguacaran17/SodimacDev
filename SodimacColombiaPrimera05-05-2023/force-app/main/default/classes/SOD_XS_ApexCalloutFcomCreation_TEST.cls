/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ApexCalloutFcomCreation_Test
Comment: Test to SOD_XS_ApexCalloutFcomCreation class
**********************************************************
*/

@isTest
public class SOD_XS_ApexCalloutFcomCreation_TEST {
    //Case Creation with Personal Account
    private static testMethod void execute(){
        User u1 = createUser();
        System.runAs(u1){
            Test.startTest();
            try{
                createCountry();
                List<SOD_XS_Country__c> Pais = [SELECT Id FROM SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL'];
                Id accountId = createAccount(Pais[0].Id);
                Id caseId = createCase(accountId, null, Pais[0].Id);
                List<Id> caseList = new list<Id>();
                caseList.add(caseId); 
                
                Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
                SOD_XS_ApexCalloutFcomCreation.SOD_XS_ApexCalloutFcomCreation(caseList);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba 1 '+e.getMessage());   
            }
        }
    }
    
    //Case Creation with Business Account
    private static testMethod void execute2(){
        User u1 = createUser();
        System.runAs(u1){
            Test.startTest();
            try{
                createCountry();
                List<SOD_XS_Country__c> Pais = [SELECT Id FROM SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL'];
                Id accountId = createAccountBA(Pais[0].Id);
                Id contactId = createContact(accountId);
                Id caseId = createCase(accountId, contactId, Pais[0].Id);
                List<Id> caseList = new list<Id>();
                caseList.add(caseId); 
                
                Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
                SOD_XS_ApexCalloutFcomCreation.SOD_XS_ApexCalloutFcomCreation(caseList);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba 2 '+e.getMessage());   
            }
        }       
    }
    
    //Case Creation without Account
    private static testMethod void execute3(){
        User u1 = createUser();
        System.runAs(u1){
            Test.startTest();
            try{
                createCountry();
                List<SOD_XS_Country__c> Pais = [SELECT Id FROM SOD_XS_Country__c WHERE SOD_XS_Codigo__c = 'CL'];
                Id caseId = createCase('', '', Pais[0].Id);
                List<Id> caseList = new list<Id>();
                caseList.add(caseId); 
                System.debug('Paseee');
                Test.setMock(HttpCalloutMock.class, new SOD_XS_ConsumeFcorp_MockClass('0'));  
                SOD_XS_ApexCalloutFcomCreation.SOD_XS_ApexCalloutFcomCreation(caseList);
                Test.stopTest();
            }catch(Exception e){
                System.debug('Error al ejecutar prueba 3 '+e.getMessage());   
            }
        }       
    }
    
    //Method for Account Creation
    public static Id createAccount(String pais){
        RecordType accountRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='Account' AND IsPersonType=True AND DeveloperName='PersonAccount' Limit 1];
        Account acc = new Account();    
        acc.FirstName = 'Testcliente';
        acc.LastName = 'TestAp';
        acc.SOD_XS_NroDocumento__c = '17674839-7';
        acc.SOD_XS_Country__c = pais;
        acc.SOD_XS_TipoDocumento__c = 'RUT';
        acc.RecordTypeId = accountRT.Id;
        acc.PersonEmail = 'test@test.com';
        acc.Phone = '957483954';
        acc.PersonMobilePhone = '647382902';
        insert acc;
        return acc.Id;
    }
    
    //Method for Business Account Creation
    public static Id createAccountBA(String pais){
        RecordType accountRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='Account' AND DeveloperName='Business_Account' Limit 1];
        Account acc = new Account();    
        acc.Name = 'Testcliente';
        acc.SOD_XS_NroDocumento__c = '17674838-9';
        acc.SOD_XS_Country__c = pais;
        acc.SOD_XS_TipoDocumento__c = 'RUT';
        acc.RecordTypeId = accountRT.Id;
        acc.Phone = '957483954';
        insert acc;

        return acc.Id;
    }
    
    //Method for Contact Creation
    public static Id createContact(String accountId){
        Contact ct = new Contact();
        ct.FirstName = 'Contacto';
        ct.LastName = 'Prueba';
        ct.Email = 'test@prueba.ts';
        ct.MobilePhone = '999999999';
        ct.AccountId = accountId;
        
        insert ct;
        
        return ct.Id;
    }
    
    //Method for Country creation
    public static void createCountry(){
        SOD_XS_Country__c pais = new SOD_XS_Country__c();
        pais.Name = 'Chile';
        pais.SOD_XS_Codigo__c = 'CL';
        pais.CurrencyIsoCode = 'CLP';
        insert pais;
    }
    
    //Method for CC creation
    public static SOD_XS_CentroDeCosto__c createCc(String pais){
        SOD_XS_CentroDeCosto__c cc = new SOD_XS_CentroDeCosto__c();
		cc.Name = 'Centro de Costo 1';
        cc.SOD_XS_NombreCompleto__c	= 'Centro de Costo 1';
        cc.SOD_XS_NombreCorto__c = 'Centro de Costo 1';
        cc.SOD_XS_TipoDeCC__c = 'TDA';
        cc.SOD_XS_Country__c = pais;
        cc.SOD_XS_PaisTiendaLiteral__c = 'Chile';
        insert cc;

        return cc;
    }
    
    //Method for Case Creation
    public static Id createCase(String accountId, String contactId, String pais){
        Id IdRecordType = Schema.SObjectType.case.getRecordTypeInfosByName().get('Consulta').getRecordTypeId();
        System.debug('Id Record'+IdRecordType);
        SOD_XS_CentroDeCosto__c cc;
        cc = createCc(pais);

        Case c = new Case();
        c.RecordTypeId = IdRecordType;
        c.Origin = 'Redes Sociales';
        c.Subject = 'Asunto de Prueba';
        c.Description = 'Descripcion del Caso';
        c.SOD_XS_Area__c = 'Post Venta';
        c.SOD_XS_Motivo__c = 'Información Devoluciones';
        c.SOD_XS_Submotivo__c = '';
        c.SOD_XS_FormadePago__c = 'Tarjeta CMR';
        c.SOD_XS_FechaDeCompra__c = Date.newInstance(2021, 04, 01);
        c.SOD_XS_DocumentoAsociado__c = createDocument('Documento Asociado');
        c.SOD_XS_DocumentoDeVenta__c = createDocument('Documento Venta');
        c.SOD_XS_CentroCostoResponsable__c = cc.Id;
        
        if(accountId != null && accountId != ''){
            c.AccountId = accountId;
        }
        
        if(contactId != null && contactId != ''){
            c.ContactId = contactId;
        }
        
        insert c;
        createProducts(c.Id);
        
        return c.Id;
    }
    
    //Create Sales and Associate Document
    public static Id createDocument(String type){
        Id idObject;
        if(type == 'Documento Venta'){
            SOD_XS_DocumentoDeVenta__c dv = new SOD_XS_DocumentoDeVenta__c();
            dv.Name = '758493022';
            dv.SOD_XS_TipoDeDdocumento__c = 'boleta';
            insert dv;
            idObject = dv.Id;
        }
        
        if(type == 'Documento Asociado'){
            SOD_XS_DocumentoAsociado__c da = new SOD_XS_DocumentoAsociado__c();
            List<RecordType> daRt = [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'SOD_XS_DocumentoAsociado__c' AND DeveloperName ='SOD_XS_ODC'];
            da.Name = '758499302';
            da.SOD_XS_TipoDeDdocumento__c = 'ODC';
            da.RecordTypeId = daRt[0].Id;
            insert da;
            idObject = da.Id;
        }
        
       return idObject;
    }
    
    //Method for Product Creation
    public static void createProducts(Id caseId){
        SOD_XS_ProductoDelCaso__c pd = new SOD_XS_ProductoDelCaso__c();
        pd.SOD_XS_Cantidad__c = 1;
        pd.SOD_XS_DescripcionDelProducto__c = 'Lavadora';
        pd.SOD_XS_PrecioUnitario__c = 3990;
        pd.SOD_XS_CodigoProducto__c = '5500';
        pd.SOD_XS_Caso__c = caseId;
        pd.SOD_XS_CreadoPorIntegracion__c = True;
        insert pd;
    }
    
    //Method for User creation 
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
}