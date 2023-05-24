/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 29/01/2020
Description  : APEX Extension - MAP JSON 360 VIEW
History      : CMRSC-3934
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Rodrigo Salinas Oye         RSO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      RSO            29/01/2020      initial version
********************************************************************************/
public class SOD_XS_MAPJSON360ViewClientExtension {

    /***************************************************************************
    *  @Description: Factory class for each Purchase
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    ****************************************************************************/
    public class PurchaseFactory  {
        // Factory Method
        public Object getPurchase(Object jsonData, String id, object storeMapCC) {
            Object objPurchase;
            // PurchaseOrders
            if ( jsonData instanceof SOD_XS_JSON360ViewClient.PurchaseOrders ) {
                objPurchase = new SOD_XS_MAPJSON360ViewOrders(jsonData, id, storeMapCC);
            }
            // PaymentVouchers
            if ( jsonData instanceof SOD_XS_JSON360ViewClient.PaymentVouchers ) {
                objPurchase = new SOD_XS_MAPJSON360ViewPaymentVoucher(jsonData, id, storeMapCC);
            }
            // SpecialServices
            if ( jsonData instanceof SOD_XS_JSON360ViewClient.SpecialServices ) {
                objPurchase = new SOD_XS_MAPJSON360ViewSpecialServices(jsonData, id, storeMapCC);
            }
            return objPurchase;
        }  
    }

 
    /***************************************************************************
    *  @Description: Interface class for each Purchase
    *  @Author:      Rodrigo Salinas, Deloitte, rosalinas@deloitte.com
    *  @Date:        29/01/2020
    ****************************************************************************/
    public interface PurchaseInterface  {
        void getMappingForCase();
        void getMappingForSalesDocument();
        void getMappingForProduct();
        String getId();
    }

    /***************************************************************************
    *  @Description: Interface class for each Payment Voucher
    *  @Author:      Abd�n Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        16/03/2021
    ****************************************************************************/
    public interface PaymentVoucherInterface extends PurchaseInterface{
        void getMappingForReserve();
        SOD_XS_DocumentoDeVenta__c getSalesDocument();        
        SOD_XS_CentroDeCosto__c getShopThatSell();
    }

    /***************************************************************************
    *  @Description: Interface class for each Purchase Order
    *  @Author:      Abd�n Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        16/03/2021
    ****************************************************************************/
    public interface PurchaseOrderInterface extends PurchaseInterface{
        void getMappingForReserve();
        void getMappingForAssociatedDocument();
        SOD_XS_DocumentoAsociado__c getAsocDocument();
        SOD_XS_DocumentoDeVenta__c getSalesDocument();        
        SOD_XS_CentroDeCosto__c getShopThatSell();
    }

    /***************************************************************************
    *  @Description: Interface class for each Special Services
    *  @Author:      Abd�n Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        16/03/2021
    ****************************************************************************/
    public interface SpecialServicesInterface extends PurchaseInterface{
        void getMappingForSubProject();
        void getMappingForAssociatedDocument();
        SOD_XS_DocumentoAsociado__c getAsocDocument();
        Map<String, SOD_XS_DocumentoDeVenta__c> getSalesDocument();
        Map<String, SOD_XS_CentroDeCosto__c> getShopThatSell();
        Map<String, List<SOD_XS_SubproyectoDelCaso__c>> getSubProjects();        
    }
}