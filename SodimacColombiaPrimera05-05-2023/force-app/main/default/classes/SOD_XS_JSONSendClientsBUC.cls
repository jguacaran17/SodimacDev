/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/01/2020
Description  : JSON for sending a Client - Client integration(BUC)
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			05/01/2020		initial version
********************************************************************************/
public with sharing class SOD_XS_JSONSendClientsBUC {
    
    public Long id;
    public String customerType;
    public String customerCategory;
    public SOD_XS_JSONClientsBUC.Cls_identification identification;
    public SOD_XS_JSONClientsBUC.Cls_personalData personalData;
    public SOD_XS_JSONClientsBUC.Cls_contacts[] contacts;
    public SOD_XS_JSONClientsBUC.Cls_contactMethods[] contactMethods;
    public SOD_XS_JSONClientsBUC.Cls_principalLocation principalLocation;
    public SOD_XS_JSONClientsBUC.Cls_locations[] locations;
    public boolean isSubscribedToMessaging;
    public String comercialState;
    public boolean employee;
    public String status;

    /**
    *  @Description: parse method
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        05/01/2020
    */    
    public static SOD_XS_JSONSendClientsBUC parse(String json){
        return (SOD_XS_JSONSendClientsBUC) System.JSON.deserialize(json, SOD_XS_JSONSendClientsBUC.class);
    }
}