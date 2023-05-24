/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 08/07/2020
Description  : JSON - Client integration(BUC)
History      : CMRSC-3784
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			08/07/2020		initial version
********************************************************************************/
public without sharing class SOD_XS_JSONClientsBUC {
    
    /**
    *  @Description: JSON identification section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */
    public class Cls_identification {
        public String value;
        public String type;
        public String country;
    }
    /**
    *  @Description: JSON personalData section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_personalData {
        public String name;
        public String lastName;
        public String fantasyName;
        public cls_gender gender;
        public String occupation;
        public String birthday;
    }
    /**
    *  @Description: JSON gender section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_gender {
        public String description;
        public Integer idGender;
    }
    /**
    *  @Description: JSON contacts section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_contacts {
        public String names;
        public String lastNames;
        public String jobTitle;
        public String phone;
        public String mail;
    }
    /**
    *  @Description: JSON contactMethod section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_contactMethods {
        public Integer id;
        public String code;
        public String value;
        public boolean haveSubscription;
        public boolean isPrincipal;
    }
    /**
    *  @Description: JSON principalLocation section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_principalLocation {
        public Integer id;
        public cls_address address;
    }
    /**
    *  @Description: JSON address section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_address {
        public String addressType;
        public Integer idAddressType;
        public String street;
        public String administrativeArea;
        public String locality;
        public String subAdministrativeArea;
        public String reference;
    }
    /**
    *  @Description: JSON locations section
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public class Cls_locations {
        public Integer id;
        public cls_address address;
    }

    /**
    *  @Description: parse method
    *  @Autor:       ATO, Deloitte, atejoso@deloitte.com
    *  @Date:        08/07/2020
    */    
    public static SOD_XS_JSONClientsBUC parse(String json){
        return (SOD_XS_JSONClientsBUC) System.JSON.deserialize(json, SOD_XS_JSONClientsBUC.class);
    }
}