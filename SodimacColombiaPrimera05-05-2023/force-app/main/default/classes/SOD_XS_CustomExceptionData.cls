/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/12/2020
Description  : Wrapper class for throw exception data
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdón Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            17/12/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_CustomExceptionData {
    
    public String name;
    public String message;
    public Integer code;
 
    /**
    * @description: Definition of fields
    * @Autor       Abdón Tejos, Deloitte, atejoso@deloitte.com
    * @date        26/03/2021
    */
    public SOD_XS_CustomExceptionData(String name, String message, Integer code) {
        this.name = name;
        this.message = message;
        this.code = code;
    }
}