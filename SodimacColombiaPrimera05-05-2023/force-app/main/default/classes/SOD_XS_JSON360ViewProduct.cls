/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 26/10/2020
Description  : JSON - 360 view of a product
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Eilhert Andrade Alviárez    EAA
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      EAA            15/12/2020      initial version
********************************************************************************/
public without sharing class SOD_XS_JSON360ViewProduct {

    public List<ArrayOfSkuReserveEvents> arrayOfSkuReserveEvents;

    /**
    *  @Description: JSON ArrayOfSkuReserveEvents section
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        16/12/2020
    */
    public class ArrayOfSkuReserveEvents {
        public String productSku;
        public String eventDate;
        public String user;
        public Integer eventTypeCode;
        public String eventType;
        public Integer roadmap;
        public ReasonForReturn reasonForReturn;
        public String data;
        public State state;
        public Courier courier;
    }

    /**
    *  @Description: JSON ReasonForReturn section
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        16/12/2020
    */
    public class ReasonForReturn {
        public Integer reasonCode;
        public String reason;
    }

    /**
    *  @Description: JSON State section
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        16/12/2020
    */
    public class State {
        public Integer id;
        public String name;
    } 

    /**
    *  @Description: JSON Courier section
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        16/12/2020
    */
    public class Courier {
        public String os;
        public String state;
        public String observation;
    }
 
    /**
    *  @Description: parse method
    *  @Autor:       EAA, Deloitte, eandradea@deloitte.com
    *  @Date:        16/12/2020
    */
    public static SOD_XS_JSON360ViewProduct parse(String json){
        return (SOD_XS_JSON360ViewProduct) System.JSON.deserialize(json, SOD_XS_JSON360ViewProduct.class);
    }
}