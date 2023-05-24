/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/03/2021
Description  : JSON mapping to expose Special Services of a client
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            08/03/2021      initial version
********************************************************************************/
public with sharing class SOD_XS_MAPJSON360ViewSpecialServices 
implements SOD_XS_MAPJSON360ViewClientExtension.SpecialServicesInterface{

    /**
    *  @Description: Declaration of static variables
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public static final String PRV_OBJ_SPL;
    public static final Id PRV_ID_RCTPROJ;


    /**
    *  @Description: Initialization of static variables
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    static {
        PRV_OBJ_SPL = 'SSP';    // Special Services Projects
    }

    @AuraEnabled public String id;
    @AuraEnabled public String strObjectType;
    @AuraEnabled public SOD_XS_DocumentoAsociado__c objDocA {get;set;}
    @AuraEnabled public Map<String, SOD_XS_DocumentoDeVenta__c> mapObjDocV {get;set;}
    @AuraEnabled public Map<String, SOD_XS_CentroDeCosto__c> mapObjShopThatSell {get;set;}
    @AuraEnabled public Map<String, List<SOD_XS_SubproyectoDelCaso__c>> mapObjSubP {get;set;}
    @AuraEnabled public Case objCase {get;set;}
    @AuraEnabled public Map<String, List<SOD_XS_ProductoDelCaso__c>> mapProducts {get;set;}
    public Map<String, SOD_XS_CentroDeCosto__c> storeMapCC;
    public SOD_XS_JSON360ViewClient.SpecialServices spl;

    /**
    *  @Description: Constructor
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public SOD_XS_MAPJSON360ViewSpecialServices(Object jsonData, String idParam, Object storeMapCC) {
        spl = (SOD_XS_JSON360ViewClient.SpecialServices) jsonData;
        this.storeMapCC = (Map<String, SOD_XS_CentroDeCosto__c>) storeMapCC;
        id = idParam;
        strObjectType = PRV_OBJ_SPL;
        getMappingForCase();
        getMappingForSalesDocument();
        getMappingForAssociatedDocument();
        getMappingForSubProject();
        getMappingForProduct();
        getShopThatSell();
    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoDeVenta__c
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        09/03/2021
    */
    public void getMappingForAssociatedDocument() {
            objDocA = new SOD_XS_DocumentoAsociado__c();
            //mapping
            objDocA.Name = spl?.orderNumber;
            objDocA.SOD_XS_IdExterno__c = spl?.orderNumber;
            objDocA.SOD_XS_Estado__c = spl?.state?.name; // spl?.state?.code
            objDocA.SOD_XS_MontoProyecto__c = spl?.amount;
            objDocA.SOD_XS_FechaCompraProyecto__c = spl?.purchaseDate == null ? null : Datetime.parse(spl?.purchaseDate?.replace('-', '/'));
            objDocA.SOD_XS_TipoDeDdocumento__c = 'Proyecto';
            objDocA.SOD_XS_CreadoPorIntegracion__c = true;
    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_DocumentoDeVenta__c
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public void getMappingForSalesDocument() {
        mapObjDocV = new Map<String, SOD_XS_DocumentoDeVenta__c>();
        mapObjShopThatSell = new Map<String, SOD_XS_CentroDeCosto__c>(); 
        for (SOD_XS_JSON360ViewClient.SubProjects psp : spl?.subProjects) {
            SOD_XS_DocumentoDeVenta__c objDocV = new SOD_XS_DocumentoDeVenta__c();
            // Mapping
            objDocV.Name = psp.salesDocument?.documentNumber;
            objDocV.SOD_XS_IdExterno__c = psp.salesDocument?.documentNumber;
            objDocV.SOD_XS_TipoDeDdocumento__c = psp.salesDocument?.documentType;
            objDocV.SOD_XS_FechaDeCompra__c = getDateParse(spl?.purchaseDate?.split(' ')[0]);
            objDocV.SOD_XS_CodigoTiendaQueVende__c = psp.shopThatSells?.id;
            objDocV.SOD_XS_NumeroDeLaOrdenDeCompra__c = spl?.orderNumber;
            objDocV.SOD_XS_CreadoPorIntegracion__c = true;
            mapObjDocV.put(psp.subProjectNumber, objDocV);
            mapObjShopThatSell.put(psp.salesDocument?.documentNumber, storeMapCC.get(psp.shopThatSells?.id));
        }

    }

    /**
    *  @Description: Method used to iterate over a Salesforce SOD_XS_SubProyectos_c
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        09/03/2021
    */
    public void getMappingForSubProject() {
        mapObjSubP = new Map<String, List<SOD_XS_SubproyectoDelCaso__c>>();
        List<SOD_XS_SubproyectoDelCaso__c> listSubP = new List<SOD_XS_SubproyectoDelCaso__c>();
        for (SOD_XS_JSON360ViewClient.SubProjects psp : spl?.subProjects) {
            SOD_XS_SubproyectoDelCaso__c objSubP = new SOD_XS_SubproyectoDelCaso__c();
            //mapping
            objSubP.Name = psp.subProjectNumber;
            objSubP.SOD_XS_Servicio__c = psp.serviceType?.serviceDescription;
            objSubP.SOD_XS_DireccionCalle__c = spl?.addressService?.street;
            objSubP.SOD_XS_DireccionArea__c = spl?.addressService?.administrativeArea;
            objSubP.SOD_XS_DireccionSubarea__c = spl?.addressService?.subAdministrativeArea;
            objSubP.SOD_XS_DireccionLocalidad__c = spl?.addressService?.locality;
            objSubP.SOD_XS_DireccionReferencia__c = spl?.addressService?.reference;
            objSubP.SOD_XS_TelefonoContacto__c = spl?.contactPhoneService;
            objSubP.SOD_XS_TipoCanasto__c = spl?.basketType?.code;
            objSubP.SOD_XS_Estado__c = psp.state?.name;
            objSubP.SOD_XS_Contratista__c = psp.serviceContractor?.contractorName;
            objSubP.SOD_XS_CreadorOrden__c = psp.creatorOrder;           
            objSubP.SOD_XS_FechaDeCotizacion__c = getDateParse(psp.quotationDate);
            objSubP.SOD_XS_FechaOrden__c = getDateParse(psp.orderDate);
            objSubP.SOD_XS_FechaTrabajo__c = getDateParse(psp.workDate);
            objSubP.SOD_XS_FechaTerminacion__c = getDateParse(psp.workFinishDate);
            objSubP.SOD_XS_FechaPagoManual__c = getDateParse(psp.manualPaymentDate);
            objSubP.SOD_XS_NotasOrden__c = String.join(psp.subProjectNotes, '\\n');
            objSubP.SOD_XS_CreadoPorIntegracion__c = true;
            listSubP.add(objSubP);
        }
        mapObjSubP.put(spl.orderNumber, listSubP);

    }

    /**
    *  @Description: Method used to map a Salesforce Case
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public void getMappingForCase() {
        objCase = new Case();
        objCase.SOD_XS_CreadoPorIntegracion__c = true;
        // Add SOD_XS_FechaDeCompra__c on SOD_XS_DocumentoDeVenta__c
    }

    /**
    *  @Description: Method used to iterate over a Product List
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public void getMappingForProduct() {
        mapProducts = new Map<String, List<SOD_XS_ProductoDelCaso__c>>();
        for (SOD_XS_JSON360ViewClient.SubProjects psp : spl?.subProjects) {
            List<SOD_XS_ProductoDelCaso__c> objProdList = new List<SOD_XS_ProductoDelCaso__c>();
            for (SOD_XS_JSON360ViewClient.SubProjectDetail spDtl : psp.subProjectDetail) {
                SOD_XS_ProductoDelCaso__c objProd = new SOD_XS_ProductoDelCaso__c();
                objProd.SOD_XS_CodigoProducto__c = spDtl.product?.sku;
                objProd.SOD_XS_DescripcionDelProducto__c = spDtl.product?.description;
                objProd.SOD_XS_PrecioUnitario__c = spDtl.unitPrice;
                objProd.SOD_XS_ImporteTotal__c = spDtl.subTotal;
                objProd.SOD_XS_Cantidad__c = spDtl.quantity;
                objProd.SOD_XS_Pagado__c = spDtl.paidUp;
                objProd.SOD_XS_CreadoPorIntegracion__c = true;
                objProdList.add(objProd);
            }
            mapProducts.put(psp.subProjectNumber, objProdList);
        }
    }

    /**
    *  @Description: Method used to parses a string representation of a date
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public Date getDateParse(String strDate) {
        Date objDate = strDate == null ? null : Date.parse(strDate?.replace('-', '/'));
        return objDate;
    }

    /**
    *  @Description: Method used to return Id
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public String getId() {
        return id;
    }

    /**
    *  @Description: Method used to return Associated document
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public SOD_XS_DocumentoAsociado__c getAsocDocument() {
        return objDocA;
    }

    /**
    *  @Description: Method used to return Sales document
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        08/03/2021
    */
    public Map<String, SOD_XS_DocumentoDeVenta__c> getSalesDocument() {
        return mapObjDocV;
    }

    /**
    *  @Description: Method used to return Shop that sell
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        12/03/2021
    */
    public Map<String, SOD_XS_CentroDeCosto__c> getShopThatSell() {
        return mapObjShopThatSell;
    }
    
    /**
    *  @Description: Method used to return SubProjects
    *  @Author:      Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        12/03/2021
    */
    public Map<String, List<SOD_XS_SubproyectoDelCaso__c>> getSubProjects(){
        return mapObjSubP;
    }
}