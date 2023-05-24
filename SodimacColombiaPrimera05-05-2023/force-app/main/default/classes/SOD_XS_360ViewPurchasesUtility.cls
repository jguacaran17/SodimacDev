/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 15/03/2021
Description  : Virtual class for common methods and constants for purchase
History      : CMRSC-4310
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            15/03/2021      initial version
********************************************************************************/
public virtual class SOD_XS_360ViewPurchasesUtility {
   
    @AuraEnabled public List<SOD_XS_MAPJSON360ViewClient.DataTableWrapper> dataTable {get;set;}
    @AuraEnabled public List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> labelsTable {get;set;}
    @AuraEnabled public Map<String, Object> mapPurchases {get;set;}
    @AuraEnabled public Boolean isError {get;set;}
    @AuraEnabled public UserMessage errorService {get;set;}

    /**
    *  @Description: Declaration of static variables
    *  @Author:      ATO
    *  @Date:        15/03/2021
    */
    private static final String PRV_WS_360VIEW;
    private static final String PRV_WS_ORD;
    private static final String PRV_STR_PCK;
    private static final String PRV_STR_DIFF;

    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    static {
        PRV_WS_360VIEW = Label.SOD_XS_HistorialCompra;
        PRV_WS_ORD = Label.SOD_XS_OrdenCompra;
        PRV_STR_PCK = 'Documento de Venta';
        PRV_STR_DIFF = 'ndc';
    }

    public SOD_XS_360ViewPurchasesUtility() {

    }

    /**
    *  @Description: Wrapper used to set path parameters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public virtual class WrapSearchCriteria extends SOD_XS_360ViewPurchasesUtility{
        @AuraEnabled public Account client {get;set;}
        @AuraEnabled public String path360View {get;set;} 
        @AuraEnabled public List<OptionDocType> docType {get; set;}
        @AuraEnabled public Boolean is360View {get;set;}
        @AuraEnabled public Boolean isDateRange {get;set;}        
        @AuraEnabled public Boolean isSalesDocument {get;set;}        
        @AuraEnabled public SalesDocumentFilter salesDocumentFilter {get; set;}
        @AuraEnabled public Integer totalElements {get; set;}
    }

    /**
    *  @Description: Wrapper used to searh Orders and Payments
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class SearchOrdersAndPayments extends WrapSearchCriteria{
        @AuraEnabled public Boolean isPurchaseOrders {get;set;}
        @AuraEnabled public Boolean isReserve {get;set;}
        @AuraEnabled public String orderNumber {get;set;}
        @AuraEnabled public String reserveNumber {get;set;}
        @AuraEnabled public PurchaseDateFilter purchaseDateFilter {get; set;}
        //Pagination
        @AuraEnabled public Integer pageNumber {get; set;}
        @AuraEnabled public Integer pageSize {get; set;}
        @AuraEnabled public Integer numberOfPages {get; set;}        
        //Constructor used to initialize the search criteria in the 360 ​​view
        public SearchOrdersAndPayments(Account client) {
            this.client = client;
            this.path360View = '360View';
            this.docType = optionDocType(client.SOD_XS_Country__r.SOD_XS_Codigo__c);
            this.is360View = true;
            this.isDateRange = false;
            this.isPurchaseOrders = false;
            this.isSalesDocument = false;
            this.isReserve = false;
            this.pageNumber = 1;
            this.pageSize = 10;
        }
        public SearchOrdersAndPayments() {}
    }

    /**
    *  @Description: Wrapper used to searh Special Services
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class SearchSpecialServices extends WrapSearchCriteria{
        @AuraEnabled public Boolean isProject {get;set;}
        @AuraEnabled public Boolean isSubProject {get;set;}
        @AuraEnabled public String projectNumber {get;set;}
        @AuraEnabled public String subProjectNumber {get;set;}
        @AuraEnabled public PurchaseDateFilterSpcSrv purchaseDateFilter {get; set;}
        //Constructor used to initialize the search criteria in the 360 ​​view
        public SearchSpecialServices(Account client) {
            this.client = client;
            this.path360View = '360View';
            this.docType = optionDocType(client.SOD_XS_Country__r.SOD_XS_Codigo__c);
            this.is360View = true;
            this.isDateRange = true;
            this.isSalesDocument = false;
        }
        public SearchSpecialServices() {}
    }

    /**
    *  @Description: Wrapper used to set a selection list
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class OptionDocType{
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}        
    }

    /**
    *  @Description: Wrapper used to set the purchase date filters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class PurchaseDateFilter {
        @AuraEnabled public String dateFrom {get; set;}
        @AuraEnabled public String dateTo {get; set;}
        
        public purchaseDateFilter() {
            DateTime df = Date.Today() - 90;
            DateTime dt = Date.Today();
            this.dateFrom = df.format('dd/MM/yyyy');
            this.dateTo = dt.format('dd/MM/yyyy');
        }
    }

    /**
    *  @Description: Wrapper used to set the purchase date filters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class PurchaseDateFilterSpcSrv {
        @AuraEnabled public String dateFrom {get; set;}
        @AuraEnabled public String dateTo {get; set;}
        @AuraEnabled public Identification Identification {get; set;}
        
        public PurchaseDateFilterSpcSrv() {
            DateTime df = Date.Today() - 90;
            DateTime dt = Date.Today();
            this.dateFrom = df.format('dd-MM-yyyy');
            this.dateTo = dt.format('dd-MM-yyyy');
        }
    }

    /**
    *  @Description: Wrapper used to set the purchase date filters
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class Identification {
        @AuraEnabled public String value {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String isoCountry {get; set;}
        
        public Identification(Account acc) {
            this.value = acc.SOD_XS_NroDocumento__c;
            this.type = getDocTypeMap(acc.SOD_XS_Country__r.SOD_XS_Codigo__c).get(acc.SOD_XS_TipoDocumento__c);
            this.isoCountry = acc.SOD_XS_Country__r.SOD_XS_Codigo__c;
        }

        public Identification() {
            
        }
    }

    /**
    *  @Description: Wrapper used to set the sales document filter
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        15/03/2021
    */
    public class SalesDocumentFilter {
        @AuraEnabled public String salesDocumentNumber {get; set;}
        @AuraEnabled public String salesDocumentType {get; set;}
    }

    /**
    *  @Description: Method used to set the values ​​of the document types
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    protected List<OptionDocType> optionDocType(String country) {
        List<OptionDocType> options = new List<OptionDocType>();
        
        Map<String, SOD_XS_WS_Translator_Catalog__mdt> mpTd = new Map<String, SOD_XS_WS_Translator_Catalog__mdt>();
        for (SOD_XS_WS_Translator_Catalog__mdt tcm : [SELECT Id, SOD_XS_WS_CorporateCode__c, SOD_XS_WS_CorporateName__c 
                                                      FROM SOD_XS_WS_Translator_Catalog__mdt
                                                      WHERE SOD_XS_WS_PickListTypeName__c =: PRV_STR_PCK 
                                                      AND SOD_XS_WS_CorporateCode__c !=: PRV_STR_DIFF
                                                      AND SOD_XS_WS_CountryISOCode__c =:country order by SOD_XS_WS_CorporateName__c asc]) {

			mpTd.put(tcm.SOD_XS_WS_CorporateName__c, tcm);
        }
           
        SOD_XS_WS_Translator_Catalog__mdt tCmdt = new SOD_XS_WS_Translator_Catalog__mdt();
        OptionDocType opt = new OptionDocType();
        
        for (String tpDoc : mpTd.keySet()){
            opt = new OptionDocType();
            tCmdt = mpTd.get(tpDoc);
            opt.label = tCmdt.SOD_XS_WS_CorporateName__c;
            opt.value = tCmdt.SOD_XS_WS_CorporateCode__c.toUpperCase();
            options.add(opt);
        }
        
        return options;
    }

    /**
    *  @Description: Query the database to obtain the information of the customer consulted in the 360 ​​view
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static account getRecord(Id rcdId) {
        return [SELECT Id, FirstName, LastName, Name, SOD_XS_TipoDocumento__c, SOD_XS_NroDocumento__c, SOD_XS_IdExterno__c, SOD_XS_Country__c, 
        isPersonAccount, RecordTypeId, CreatedById, CurrencyIsoCode, SOD_XS_Country__r.SOD_XS_Codigo__c, PersonContactId FROM Account WHERE Id = :rcdId];
    }

    
    /**
    *  @Description: Get the types of documents
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        02/10/2020
    */
    public static Map<String, String> getDocTypeMap(String isoCode) {
        Map<String, String> str = new Map<String, String>();
        for (SOD_XS_Tipo_de_documento_BUC__mdt tdp : SOD_XS_ClientsConstant.PBC_MAP_DOCTYPEBYCOUNTRY) {
            if (isoCode == tdp.SOD_XS_CodigoPais__c) {
                str.put(tdp.Label, tdp.SOD_XD_Parametro_BUC__c);
            }            
        }
        return str;
    }

    /**
    *  @Description: Service exception, wrapper class used to set a service exception
	*  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        02/10/2020
    */    
    public class UserMessage {
        @AuraEnabled public Integer code;
        @AuraEnabled public String internalMessage;
        @AuraEnabled public String showMessage;
        public UserMessage(String internalMessage, Integer code) {
            this.internalMessage = internalMessage;
            this.code = code;            
        }
    }
}