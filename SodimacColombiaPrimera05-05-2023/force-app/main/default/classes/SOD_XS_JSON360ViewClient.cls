/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 26/10/2020
Description  : JSON - 360 view of a client
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            26/10/2020      initial version
********************************************************************************/
public without sharing class SOD_XS_JSON360ViewClient {

    public ThreeHundredAndSixtyView threeHundredAndSixtyView;
    public List<PurchaseOrders> purchaseOrders;
    public List<PaymentVouchers> paymentVouchers;
    public List<SpecialServices> specialServices;
    
    /**
    *  @Description: JSON ThreeHundredAndSixtyView section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class ThreeHundredAndSixtyView {
        public Pagination pagination;
        public List<Reserves> reserves;
        public List<PurchaseOrders> purchaseOrders;
        public List<PaymentVouchers> paymentVouchers;
        public List<SpecialServices> specialServices;
    }

    /**
    *  @Description: JSON Address section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Address {
        public String street;
        public String administrativeArea;
        public String locality;
        public String subAdministrativeArea;
        public String reference;
    }

    /**
    *  @Description: JSON PurchaseHolder section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class PurchaseHolder {
        public Identification Identification;
        public String names;
        public String lastName;
        public String email;
        public String customerPhone;
    }

    /**
    *  @Description: JSON Dispatch section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Dispatch {
        public String nameToWhomIsDispatched;
        public String observation;
        public String firstPhone;
        public String secondPhone;
        public Address address;
        public Double amount;
        public CurrencyInformation currencyInformation;
    }

    /**
    *  @Description: JSON Product section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Product {
        public String sku;
        public String description;
    }

    /**
    *  @Description: JSON Purchase Holder of a Payment section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class PurchaseHolderPayment {
        public Identification Identification;
        public String names;
        public String lastName;
    }

    /**
    *  @Description: JSON Identification section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Identification {
        public String value;
        public String identificationType;
        public String isoCountry;
    }

    /**
    *  @Description: JSON Identification section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class ShopThatSells {
        public String id;
        public String name;
    }

    /**
    *  @Description: JSON PaymentMethods section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class PaymentMethods {
        public String typePaymentMethod;
        public CurrencyInformation currencyInformation;
        public Double amount;
    }

    /**
    *  @Description: JSON Pagination section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Pagination {
        public Integer numberOfPages;
        public Integer totalElements;
        public Integer page;
    }

    /**
    *  @Description: JSON SalesDocument section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class SalesDocument {
        public String documentType;
        public String documentNumber;
    }

    /**
    *  @Description: JSON DetailPayment section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class DetailPayment {
        public Product product;
        public Integer quantity;
        public Double unitPrice;
        public Double discount;
        public Double amount;
    }

    /**
    *  @Description: JSON Currency section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class CurrencyInformation {
        public String isoCode;
        public String name;
    }

    /**
    *  @Description: JSON AgreedDateRange section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class AgreedDateRange {
        public String fromDate;
        public String toDate;
    }

    /**
    *  @Description: JSON DeliveryType section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class DeliveryType {
        public String code;
        public String nombre;
    }

    /**
    *  @Description: JSON Reserves section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Reserves {
        public String id;
        public String reserveNumber;
        public String motherReserveNumber;
        public String reserveType;
        public DeliveryType deliveryType;
        public State state;
        public String reserveDate;
        public String salesOrderNumber;
        public SalesDocument salesDocument;
        public Double amount;
        public CurrencyInformation  currencyInformation;
        public ShopThatSells shopThatSells;
        public ShopThatSells salesChannel;
        public PurchaseHolder purchaseHolder;
        public Dispatch dispatch;
        public Boolean hasNcr;
        public List<Detail> detail;
    }

    /**
    *  @Description: JSON InventoryOriginCostCenter section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class InventoryOriginCostCenter {
        public String id;
    }

    /**
    *  @Description: JSON PurchaseOrders section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class PurchaseOrders implements Comparable{
        public String purchaseDate;
        public SalesDocument salesDocument;
        public String orderNumber;
        public Double amount;
        public CurrencyInformation currencyInformation;
        public List<PaymentMethods> paymentMethods;
        public ShopThatSells shopThatSells;
        public List<Reserves> reserves;
        public List<PaymentVouchers> paymentVouchers;
        public PurchaseOrders pow;
        
        public PurchaseOrders( PurchaseOrders po) {
            pow = po;
        }
        
        public Integer compareTo(Object compareTo) {
            
            PurchaseOrders compareToDate = (PurchaseOrders)compareTo;
            
            Integer returnValue = 0;
            Datetime prcDate = Datetime.parse(purchaseDate?.replace('-', '/'));
            Datetime cmtPrcDate = Datetime.parse(compareToDate.purchaseDate?.replace('-', '/'));
                       
            if (prcDate  > cmtPrcDate) {
                returnValue = -1;
                
            } else if (prcDate < cmtPrcDate) {
                returnValue = 1;
                
            } else if ((prcDate == null) && (cmtPrcDate != null)){
                returnValue = 1;
                
            } else if ((prcDate != null) && (cmtPrcDate == null)){
                returnValue = -1;
            }        
            return returnValue;       
        }
    }

    /**
    *  @Description: JSON Devolution section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Devolution {
        public Integer reasonCode;
        public String reason;
    }

    /**
    *  @Description: JSON Payment Vouchers section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class PaymentVouchers {
        public String dateOfIssue;
        public String documentType;
        public String documentNumber;
        public String salesOrderNumber;
        public Double amount;
        public Double discount;
        public Double totalPrice;
        public CurrencyInformation currencyInformation;
        public List<PaymentMethods> paymentMethods;
        public ShopThatSells shopThatSells;
        public PurchaseHolderPayment purchaseHolder;
        public List<DetailPayment> detail;
    }

    /**
    *  @Description: JSON State section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class State {
        public Integer id;
        public String name;
    }

    /**
    *  @Description: JSON Seller section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Seller {
        public String code;
        public String name;
    }

    /**
    *  @Description: JSON Delivery section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class Delivery {
        public AgreedDateRange agreedDateRange;
        public String hourRangeCode;
        public String hourRange;
        public String deliveryDate;
        public InventoryOriginCostCenter inventoryOriginCostCenter;
    }

    /**
    *  @Description: JSON Dispatch of a Detail section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class DispatchDetail {
        public String dispatchType;
        public String dispatchDate;
        public ShopThatSells costCenter;
        public String dispatchGuideNumber;
    }

    /**
    *  @Description: JSON Detail section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */ 
    public class Detail {
        public String id;
        public DispatchDetail dispatch;
        public Boolean isBlocked;
        public Boolean isBreak;
        public Product product;
        public Integer quantity;
        public Double unitPrice;
        public Double amount;
        public Seller seller;
        public State state;
        public Delivery delivery;
        public Devolution devolution;
    }

    // Special Service section

    /**
    *  @Description: JSON SubProjectDetail section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/03/2021
    */ 
    public class SubProjectDetail {
		public Product product;
		public Integer quantity;
		public Double unitPrice;
		public Double subTotal;
		public Boolean paidUp;
    }

    /**
    *  @Description: JSON SubProjects section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/03/2021
    */ 
    public class SubProjects {
		public String subProjectNumber;
		public ServiceType serviceType;
		public ServiceContractor serviceContractor;
		public ShopThatSells shopThatSells;
		public SalesDocument salesDocument;
		public Seller state;
		public String orderDate;
		public String workDate;
		public String manualPaymentDate;
		public String quotationDate;
		public String workFinishDate;
		public String creatorOrder;
		public List<SubProjectDetail> subProjectDetail;
        public List<String> subProjectNotes;
    }

    /**
    *  @Description: JSON SpecialServices section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/03/2021
    */ 
    public class SpecialServices  implements Comparable{
		public String orderNumber;
		public PurchaseHolder purchaseHolder;
		public String purchaseDate;
		public Address addressService;
		public String contactPhoneService;
		public Double amount;
		public Seller state;
		public Seller basketType;
		public List<SubProjects> subProjects;
        public Account client;
        // Order by purchaseDate CMRSC-4624-CA12
        public SpecialServices sps;
        public SpecialServices(SpecialServices ss) {
            sps = ss;
        }
        
        public Integer compareTo(Object compareTo) {
            
            SpecialServices compareToDate = (SpecialServices)compareTo;
            
            Integer returnValue = 0;
            Datetime prcDate = Datetime.parse(purchaseDate?.replace('-', '/'));
            Datetime cmtPrcDate = Datetime.parse(compareToDate.purchaseDate?.replace('-', '/'));
                       
            if (prcDate  > cmtPrcDate) {
                returnValue = -1;
                
            } else if (prcDate < cmtPrcDate) {
                returnValue = 1;
                
            } else if ((prcDate == null) && (cmtPrcDate != null)){
                returnValue = 1;
                
            } else if ((prcDate != null) && (cmtPrcDate == null)){
                returnValue = -1;
            }        
            return returnValue;       
        }
    }

    /**
    *  @Description: JSON ServiceType section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/03/2021
    */ 
    public class ServiceType {
		public String code;
		public String serviceDescription;
    }
    
    /**
    *  @Description: JSON ServiceContractor section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/03/2021
    */ 
    public class ServiceContractor {
		public String contractorName;
    }
    
    /**
    *  @Description: parse method
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */    
    public static SOD_XS_JSON360ViewClient parse(String json){
        return (SOD_XS_JSON360ViewClient) System.JSON.deserialize(json, SOD_XS_JSON360ViewClient.class);
    }
}