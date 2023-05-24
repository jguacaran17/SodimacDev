/*
Created By: David Palma (FTC)
Date: 18/02/2021
Class Name: SOD_XS_CaseCreationRequestWrapper
Comments: Class created for APEX Rest Case Creation Service (Request Class)
*/

public class SOD_XS_CaseCreationRequestWrapper {

	public class Account {
        public String companyName;
		public String accountName;
        public String accountLastName;
		public String recordType;
		public String documentType;
		public String documentNumber;
		public String currencyName;
		public String country;
		public String region;
		public String province;
		public String commune;
		public String address;
        public String personEmail;
        public String mobilePhone;
	}
    
    public class Product{
        public String productCode;
        public String productDescription;
        public String quantity;
        public String price;
        public String reserveAmount;
        public String productStatus;
        public Boolean lock;
        public String affectedQuantity;
        public String deliveryType;
        public String returnReason;
        public String hours;
        public Date originalDeliveryDate;
        public Date shipmentDate;
        public Date deliveryDate;
        public Boolean ncr;
        public String guideNumber;
        public String provider;
    }
    
    public class AssociateDocument{
        public String docType;
        public String docNumber;
    }

    public class SalesDocument{
        public String docType;
        public String docNumber;
    }
	
	public Account account;
	public Contact contact;
	public Cases cases;
	
	public class Cases {
		public String area;
		public String reason;
		public String secondReason;
		public String recordType;
		public String store;
		public String origin; 
		public String priority;
		public String subject;
		public String description;
		public String paymentMethod;
		public String retailStore;
		public String issueDate;
		public String purchaseDate;
        public String externalNumber;
		public String regulatoryId; // rvalenciat: CREC-4971 Id Regulatorio F.com --> Sodimac
        public SalesDocument SalesDocument;
        public AssociateDocument AssociateDocument;
        public List<Product> Product;
		public List<Recontact> Recontacts;
	}
	
	public class Contact {
		public String contactName;
        public String contactLastName;
		public String email;
		public String phone;
	}
	
	// rvalenciat: CREC-4024 Recontacto F.com --> Sodimac
	public class Recontact {
        public String comments;
		public String type;
		public String origin;
		public Datetime createdDate;
	}

	public static SOD_XS_CaseCreationRequestWrapper parse(String json) {
		return (SOD_XS_CaseCreationRequestWrapper) System.JSON.deserialize(json,SOD_XS_CaseCreationRequestWrapper.class);
	}
}