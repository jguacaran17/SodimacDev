/*
**********************************************************
Created By: David Palma, 13/04/2021
Class Name: SOD_XS_ConsumeCreateFcomWrapper
Comment: Clase creada para armar request de Fcom
**********************************************************
*/

public class SOD_XS_ConsumeCreateFcomWrapper{
	public class Account{
		public String recordType {get;set;}
		public String documentType {get;set;}
		public String document {get;set;}
		public String externalId {get;set;}
		public String name {get;set;}
		public String phone {get;set;}
		public String country {get;set;}
	}

	public class Contact{
		public String documentType {get;set;}
		public String document {get;set;}
		public String externalId {get;set;}
		public String firstName {get;set;}
		public String middleName {get;set;}
		public String lastName {get;set;}
		public String mothersFamilyName {get;set;}
		public String personEmail {get;set;}
		public String phone {get;set;}
		public String country {get;set;}
	}

	public class BankDetails {
		public String accountHolder {get;set;} 
		public String accountHolderId {get;set;} 
		public String bank {get;set;} 
		public String accountType {get;set;} 
		public String accountNumber {get;set;} 
		public Integer grandTotal {get;set;} 
	}

	public class Asset {
		public String damageDescription {get;set;} 
		public String erDescription {get;set;} 
		public String lineId {get;set;} 
		public String name {get;set;} 
		public String packageCondition {get;set;} 
		public Integer price {get;set;} 
		public String productCondition {get;set;} 
		public Integer quantity {get;set;} 
		public Integer quantityOrdered {get;set;} 
		public String statusReason {get;set;} 
		public String stockKeepingUnite {get;set;} 
		public String upc {get;set;} 
		public String useLevel {get;set;} 
	}

	public class WorkOrderDetails {
        
		public Integer invoiceNumber {get;set;} 
		public String paymentMethod {get;set;} 
		public String purchaseDate {get;set;} 
		public String originStore {get;set;} 
		public String terminal {get;set;} 
		public String sequence {get;set;} 
		public String reasonProblem {get;set;} 
		public String deliveryStatus {get;set;} 
	}

	public class Cases {
		public String source {get;set;} 
		public String organization {get;set;} 
		public String channel {get;set;} 
		public String origin {get;set;} 
		public String subject {get;set;} 
		public String description {get;set;} 
		public String webEmail {get;set;} 
		public String level1 {get;set;} 
		public String level2 {get;set;} 
		public String level3 {get;set;} 
		public String country {get;set;} 
		public String city {get;set;} 
		public String commerce {get;set;} 
		public String text1 {get;set;} 
		public String text2 {get;set;} 
		public String text3 {get;set;} 
		public Boolean boolean1 {get;set;} 
		public Boolean boolean2 {get;set;} 
		public Boolean boolean3 {get;set;} 
		public String customerOrder {get;set;} 
		public String sellerOrder {get;set;} 
		public String externalId {get;set;} 
		public String seller {get;set;} 
		public String sellerId {get;set;} 
		public Boolean agentCase {get;set;} 
		public String agentCode {get;set;} 
		public Boolean bigticket {get;set;} 
		public WorkOrderDetails workOrderDetails {get;set;} 
		public BankDetails bankDetails {get;set;} 
		public List<Asset> asset {get;set;} 
	}

	public Account account;
	public Contact contact;
	public Cases cases;

	public static SOD_XS_ConsumeCreateFcomWrapper parse(String json){
		return (SOD_XS_ConsumeCreateFcomWrapper) System.JSON.deserialize(json,SOD_XS_ConsumeCreateFcomWrapper.class);
	}

}