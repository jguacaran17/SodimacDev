/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 27/03/2019
Description  : SOD_XS_DataFactory contains all method for account, case, country, entitlement, and more object creations 
History      : Leonardo Muñoz: Se modifica la Clase Test, incorporando Static Resource para creación de registros de los distintos objetos que posee la clase.
               1=Chile,2=Peru,3=Mexico,4=Colombia (Se definen estos códigos para la creación de países y así poder relacionarlo con las regiones,
               provincias y comunas)
               Se incorpora definición @isTest, porque esta clase es exclusiva para Test.
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Diego Villarroel			    DV
Eilhert Andrade					EA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      DV			27/03/2019		    Created Class
1.1      EA         24/07/2020
1.2      LM         25/01/2021          Actualizado
********************************************************************************/

@isTest
public class SOD_XS_DataFactory {
	
    @TestVisible public static final String PRV_STR_B2C;    
    @TestVisible public static final String PRV_STR_B2B;
    @TestVisible public static final String PRV_STR_CASE_CLAIM;
    public static List<sObject> objPais = new List<sObject>();
    public static List<sObject> objUser = new List<sObject>();

    static {
        PRV_STR_B2C = 'PersonAccount';
        PRV_STR_B2B = 'Business_Account';
        PRV_STR_CASE_CLAIM = 'SOD_XS_Reclamo';
    }
	
     /**
     * @description Create Account Person / Business
     * @author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
     * @date        24/07/2020
     */
     public static Account createAccountXS(Boolean doInsert, String RcdType, String tpDoc, String nroDoc, String sgPais) {
         String RecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(RcdType).getRecordTypeId();
         
         Account acc = new Account();
         switch on sgPais {
             when 'CL','cl' {
                 acc.Phone = '987654321';
                 acc.PersonMobilePhone = '987654321'; 
             }
             when 'PE', 'pe' {
                 acc.Phone = '987654321';
                 acc.PersonMobilePhone = '987654321';
             }
             when 'MX', 'mx'{
                 acc.Phone = '9876543210';
                 acc.PersonMobilePhone = '9876543210';
             }
             when 'CO', 'co'{
                 acc.Phone = '9876543';
                 acc.PersonMobilePhone = '9876543210';
             }
         }        
         //if person account
         if(RcdType == PRV_STR_B2C){
             acc.FirstName = RcdType;
             acc.LastName = 'Sodimac';
             acc.PersonEmail = 'notiene@correo.com';
             acc.SOD_XS_IdPersonEmail__c = 1915800;
         }else { // if Business account
             acc.Name = RcdType + ' Sodimac';
             acc.PersonMobilePhone = null;
         }
         
         acc.SOD_XS_TipoDocumento__c = tpDoc;
         SOD_XS_Country__c pais = createPaisXS(sgPais);
         acc.SOD_XS_Country__c = pais.Id;
         acc.CurrencyIsoCode = pais.CurrencyIsoCode;
         acc.SOD_XS_NroDocumento__c = nroDoc;     
         
         acc.RecordTypeId = RecTypeId;
         
         try{
             if(doInsert){
                 insert acc;
             }
         }catch(Exception e){
             System.debug('Error, Excepción: '+e);
         }
         
         return acc;
    }
     /**
     * @description Create Account Person / Business with new asociated case
     * @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
     * @date        03/12/2019
     */    
    public static Id  NewDataXS (String RcdType) {
        List<Case> casos = new List<Case>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
        Account acc;
        if (RcdType == PRV_STR_B2C) {
            acc = createAccountXS(true, RcdType, 'RUT', '18959028-8','CL');
        }
        SOD_XS_CentroDeCosto__c cCosto = createCentroCosto(acc.SOD_XS_Country__c);
        
        for (Id idCase : rtMapById.keySet()) {
            if((!rtMapById.get(idCase).isMaster()) && (rtMapById.get(idCase).getDeveloperName().contains('SOD_XS_'))) {
                Case caso = (Case) SOD_XS_DataFactory.createCase(false);
                caso.AccountId= acc.Id;
                caso.RecordTypeId = idCase;
                caso.SOD_XS_FechaDeCompra__c =Date.today();
                caso.SOD_XS_CheckMailLlamada__c = true; 
                caso.Status = 'New';
                
                casos.add(caso);
            }
        }
        insert casos;
        return acc.Id;
    }
    /**
      *  @description Creates Case record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        19/12/2019
    */
    public static Case createCase(Boolean doInsert){
        User userOwner = [Select Id From user Limit 1]; 
        SOD_XS_Country__c paisCC = createPaisXS('CL');
        SOD_XS_CentroDeCosto__c cCosto = createCentroCosto(paisCC.Id);
            
        Case c = new Case();
        c.SOD_XS_CentroCostoResponsable__c = cCosto.Id;
        c.OwnerId = userOwner.Id;
            
        if(doInsert){               
            insert c;
        }
        return c;
    }
    /**
     * @description Create Account Person / Business with new asociated case
     * @author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
     * @date        24/07/2020
     */     
    public static Contact createContact(Boolean doInsert) {
        return createContact(doInsert, createAccountXS(true, PRV_STR_B2B, 'RUT', '11934773-4','CL').Id);
    }
    /*  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
	*/
    public static Contact createContact(Boolean doInsert, Id accId) {
        List<sObject> objCon = Test.loadData(Contact.sObjectType, 'SOD_XS_ContactosTest');
        List<Contact> contacto = (List<Contact>)objCon;
            
        Contact con = new Contact();
        con = contacto[0];
        con.AccountId = accId;
        con.Email = con.Email + Math.floor(Math.random() * 1000);
        update con;

        return con;
    }
    /**
      *  @description Creates SOD_XS_Country__c record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        03/12/2019
    */
    public static SOD_XS_Country__c createPais(Boolean doInsert){
        SOD_XS_Country__c p = new SOD_XS_Country__c(
            Name = 'Chile',
            CurrencyIsoCode = 'CLP'
        );
		
        if(doInsert){
            insert p;
        }

        return p;
    }
    /**
      *  @description Creates especific SOD_XS_Country__c record
      *  @author      Eilhert Andrade, Deloitte, eandradea@deloitte.com
      *  @date        24/07/2020
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static SOD_XS_Country__c createPaisXS(String sgPais) {
        objPais = [Select Name,CurrencyIsoCode,SOD_XS_Codigo__c from SOD_XS_Country__c where SOD_XS_Codigo__c =: sgPais];
        if (objPais.size()==0){
        	objPais = Test.loadData(SOD_XS_Country__c.sObjectType, 'SOD_XS_PaisesTest');
		}

        SOD_XS_Country__c pais = [Select Name,CurrencyIsoCode,SOD_XS_Codigo__c from SOD_XS_Country__c where SOD_XS_Codigo__c =: sgPais];
        return pais;
    }
    
    /**
      *  @description Creates SOD_XS_AdministrativeArea__c record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        03/12/2019
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static List<SOD_XS_AdministrativeArea__c> createRegion(){
        
        List<sObject> objRegion = Test.loadData(SOD_XS_AdministrativeArea__c.sObjectType, 'SOD_XS_RegionesTest');
        return (List<SOD_XS_AdministrativeArea__c>)objRegion;
    }
    /**
      *  @description Creates SOD_XS_Locality__c record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        03/12/2019
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static List<SOD_XS_Locality__c> createProvincia(){
        List<sObject> objProvincia = Test.loadData(SOD_XS_Locality__c.sObjectType, 'SOD_XS_ProvinciasTest');
        return (List<SOD_XS_Locality__c>)objProvincia;
    }
    /**
      *  @description Creates SOD_XS_SubAdministrativeArea__c record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        03/12/2019
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static List<SOD_XS_SubAdministrativeArea__c> createComuna(){
        List<sObject> objComuna = Test.loadData(SOD_XS_SubAdministrativeArea__c.sObjectType, 'SOD_XS_ComunasTest');
        return (List<SOD_XS_SubAdministrativeArea__c>)objComuna;
    }
    /**
      *  @description Creates Task record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        10/12/2019
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static Task createTask(Id whatId){
        List<sObject> objTarea = Test.loadData(Task.sObjectType, 'SOD_XS_TasksTest');
        List<Task> lstTsk = new List<Task>();
		Task tsk = new Task();
        
        for(Task tarea : (List<Task>)objTarea){
            if (tarea.Subject == 'Call'){
                tsk = tarea;
	            tsk.WhatId = whatId;
            }
        }
        
        update tsk;
        return tsk;
    }
    /**
      *  @description Creates Entitlement record
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        19/12/2019
    */
    public static Entitlement createEntitlement(Boolean doInsert){
        Entitlement e = new Entitlement(
            Name = 'Tipo Incidente en Tienda'
        );

        if(doInsert){
            Account acc = createAccountXS(true,PRV_STR_B2C, 'RUT', '14950676-4','CL');
            e.AccountId = acc.Id;
            insert e;
        }

        return e;
    }
    /**
      *  @description Creates Salesforce User
      *  @author      Luciano Ditzel, Deloitte, lditzelramirez@deloitte.com
      *  @date        19/12/2019
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static User createUser(){
        Id userRoleId = [select id from UserRole where DeveloperName = 'Administrador'].Id;
        Id profileId = [select id from Profile where Name = 'SOD XS Administrador de Negocio'].Id;
        Id userRoleId2 = [select id from UserRole where DeveloperName = 'SOD_XS_SupervisorBO'].Id;
        Id profileId2 = [select id from Profile where Name = 'SOD XS Administrador de Sistemas'].Id;

        String numDoc = '19199199-0';

        User us = new User();        
        us.FirstName = 'Test2Tester';
        us.LastName = 'User2Tester';
        us.Alias = 'tester2';
        us.Email = 'tuser2tester@test.com';
        us.UserName = 'dumy2testuser1256881@sodimac.com';
        us.CommunityNickname = 'test2tester';
        us.Country = 'CL';
        us.NroDocumentoDeIdentidad__c = '17245183-7';
        us.TimeZoneSidKey = 'America/Santiago';
        us.LocaleSidKey = 'es_CL';
        us.EmailEncodingKey = 'ISO-8859-1';
        us.LanguageLocaleKey = 'es_CL';
        us.XS_CentroDeCosto__c ='0';
        us.XS_AreaDelUsuario__c='XS_Administracion';
        us.UserRoleId = userRoleId2;
        us.ProfileId = profileId2;
        insert us;
               
        User u = new User();        
        u.FirstName = 'Test';
        u.LastName = 'User';
        u.Alias = 'kuser';
        u.Email = 'tuser@test.com';
        u.UserName = 'dumytestuser@sodimac.com';
        u.CommunityNickname = 'test1';
        u.Country = 'CL';
        u.NroDocumentoDeIdentidad__c = '19199199-0';
        u.TimeZoneSidKey = 'America/Santiago';
        u.LocaleSidKey = 'es_CL';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'es_CL';
        u.XS_CentroDeCosto__c ='40';
        u.XS_AreaDelUsuario__c='SAC';
        u.UserRoleId = userRoleId;
        u.ProfileId = profileId;
        u.ManagerId = us.id;
        insert u;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SOD_XS_Supervisor'];        
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

        return u;
    }

    /**
      *  @description Creates Salesforce User with specific parameters
      *  @author      Monica Rivas, Deloitte, mrivasm@deloitte.com
      *  @date        02/06/2020
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
    */
    public static User createUser(String cnt, String country, String numDoc){
       
        Id userRoleId = [select id from UserRole where DeveloperName = 'Administrador'].Id;
        Id profileId = [select id from Profile where Name = 'SOD XS Administrador de Negocio'].Id;

        List<sObject> objUser = Test.loadData(User.sObjectType, 'SOD_XS_UsuariosTest');
        
        User u = new User();
        
        for(User user : (List<User>)objUser){
            if (user.NroDocumentoDeIdentidad__c == numDoc){
                u = user;
                u.UserRoleId = userRoleId;
                u.ProfileId = profileId;
            }
        }
        update u;
        return u;
    }

    /**
    *  @description Creates SOD_XS_SubAdministrativeArea__c record
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        15/12/2020
    *  @Update:      Leonardo Muñoz, Deloitte, (Se implementa Test.LoadData 26-01-2021)
	* public static Tienda__c createStore(SOD_XS_Country__c country, String name, String code, String type)
    */
    public static void createStore(SOD_XS_Country__c country){
        List<sObject> objTienda = Test.loadData(SOD_XS_CentroDeCosto__c.sObjectType, 'SOD_XS_TiendasTest');
        List<SOD_XS_CentroDeCosto__c> lstTnd = new List<SOD_XS_CentroDeCosto__c>();
        
        for(SOD_XS_CentroDeCosto__c tienda : (List<SOD_XS_CentroDeCosto__c>)objTienda){
            tienda.SOD_XS_Country__c = country.Id;
            lstTnd.add(tienda);
        }
        update lstTnd;
    }
    /**
    * @description: Data for Centro Costo test
    * @Autor       LMG, Deloitte, lmunozg@deloitte.com
    * @date        26/03/2021
    */
    public static SOD_XS_CentroDeCosto__c createCentroCosto(Id p){
        SOD_XS_CentroDeCosto__c cC = new SOD_XS_CentroDeCosto__c();
        
        cC.Name = 'Tienda';
        cC.SOD_XS_NombreCompleto__c = 'Tienda';
        cC.SOD_XS_NombreCorto__c = 'Tienda';
        cC.SOD_XS_TipoDeCC__c = 'TDA';
        cC.SOD_XS_Country__c = p;
        cC.SOD_XS_PaisTiendaLiteral__c = 'Chile';
       
        insert cC;
        return cC;
    }
    /**
    * @description: Data for Sales Document test
    * @Autor       LMG, Deloitte, lmunozg@deloitte.com
    * @date        29/03/2021
    */
    public static SOD_XS_DocumentoDeVenta__c createSaleDocument(Account cliente){
        SOD_XS_DocumentoDeVenta__c dV = new SOD_XS_DocumentoDeVenta__c();
        dV.SOD_XS_NombreCliente__c = cliente.Id;
        dV.CurrencyIsoCode = 'CLP';
        dV.SOD_XS_TipoDeDdocumento__c = 'boleta';
        dV.Name = '111211';

        insert dV;
        return dV;
    }
}