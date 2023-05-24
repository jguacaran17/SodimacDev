/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 26/10/2020
Description  : Wrapper class to manipulate the columns of a data table
History      : 
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos Oliva           ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO            26/10/2020      initial version
********************************************************************************/
public with sharing class SOD_XS_DataTableUtily{
    
    /**
    *  @Description: Declaration of static variables
    *  @Author:      ATO
    *  @Date:        26/10/2020
    */
    private static final String PVR_STR_TYPE_PCL;
    private static final String PVR_STR_TYPE_STR;
    private static final String PVR_STR_TYPE_RFC;
    private static final String PVR_STR_TYPE_TXT;
    private static final String PVR_STR_TYPE_DTM;
    private static final String PVR_STR_TYPE_DT;
    private static final String PVR_STR_TYPE_DTLOCAL;
    private static final String PVR_STR_TYPE_DTTMLOCAL;
    private static final String PVR_STR_TYPE_2DG;
    private static final String PVR_STR_TYPE_NUM;
    private static final String PVR_STR_COLON;
    private static final String PVR_STR_SMCOLON;
    
    /**
    *  @Description: Initialization of static variables
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    static {
        PVR_STR_TYPE_PCL = 'picklist';
        PVR_STR_TYPE_STR = 'string';
        PVR_STR_TYPE_RFC = 'reference';
        PVR_STR_TYPE_TXT = 'text';
        PVR_STR_TYPE_DTM = 'datetime';
        PVR_STR_TYPE_DT = 'date';
        PVR_STR_TYPE_DTLOCAL = 'date-local';
        PVR_STR_TYPE_DTTMLOCAL = 'datetime-local';
        PVR_STR_TYPE_2DG = '2-digit';
        PVR_STR_TYPE_NUM = 'numeric';
        PVR_STR_COLON = ':';
        PVR_STR_SMCOLON = ';';
    }
    
    /**
    *  @Description: Gets the type of data allowed in a data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    private static String getTypeOf(String str) {
        Map<String, String>  strMap = new Map<String, String>{
            PVR_STR_TYPE_PCL => PVR_STR_TYPE_TXT,
            PVR_STR_TYPE_STR => PVR_STR_TYPE_TXT,
            PVR_STR_TYPE_RFC => PVR_STR_TYPE_TXT,
            PVR_STR_TYPE_DTM => PVR_STR_TYPE_DT,
            PVR_STR_TYPE_DT => PVR_STR_TYPE_DTLOCAL
        };
        return strMap.containsKey(str) 
               ? strMap.get(str) 
               : str;
    }
    
    /**
    *  @Description: Wrapper used to create the columns of a data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class LabelDescriptionWrapper implements Comparable{
        public LabelDescriptionWrapper ldwo;
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public boolean sortable {get;set;}
        @AuraEnabled
        public boolean editable {get;set;}
        @AuraEnabled
        public Integer initialWidth {get;set;}
        @AuraEnabled
        public String objName {get;set;}
        public Integer order {get;set;}
        @AuraEnabled 
        public TypeAttributesWrapper typeAttributes {get;set;}
        @AuraEnabled 
        public CellAttributesWrapper cellAttributes {get;set;}
        // Constructor used to set the default value of the width of the columns
        public labelDescriptionWrapper() {
            this.initialWidth = 150;
        }
        // Constructor        
        public labelDescriptionWrapper(LabelDescriptionWrapper ld) {
            this.ldwo = ld;
        }
        
        // Compare LabelDescriptionWrapper based on the LabelDescriptionWrapper order.
        public Integer compareTo(Object compareTo) {
            // Cast argument to LabelDescriptionWrapper
            LabelDescriptionWrapper compareToLdwo = (LabelDescriptionWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (order > compareToLdwo.order) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (order < compareToLdwo.order) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }
    
    /**
    *  @Description: Wrapper used to set the attributes of a variable of the date type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class TypeAttributesWrapper {
        @AuraEnabled
        public String day {get; private set;}
        @AuraEnabled
        public String month {get; private set;}
        @AuraEnabled
        public String year {get; private set;}
        public typeAttributesWrapper() {
            this.day = PVR_STR_TYPE_2DG;
            this.month = PVR_STR_TYPE_2DG;
            this.year = PVR_STR_TYPE_NUM;
        }
    }

    /**
    *  @Description: Wrapper used to set column alignment
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class CellAttributesWrapper {
        @AuraEnabled
        public String alignment {get; private set;}
        public CellAttributesWrapper() {
            this.alignment = 'left';
        }
    }

    /**
    *  @Description: Wrapper used to set a button in the data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class ButtonDescriptionWrapper implements Comparable{
        public ButtonDescriptionWrapper bdwo;
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public String type {get; private set;}
        @AuraEnabled
        public Integer initialWidth {get;private set;}
        @AuraEnabled
        public Integer order {get;set;}
        @AuraEnabled
        public ButtonTypeAttributesWrapper typeAttributes {get;set;}
        // Constructor used to set the default value of the width of the columns and type
        public buttonDescriptionWrapper() {
            this.type = 'button';
            this.initialWidth = 135;
        }
        // Constructor        
        public buttonDescriptionWrapper(ButtonDescriptionWrapper bd) {
            this.bdwo = bd;
        }
        
        // Compare ButtonDescriptionWrapper based on the ButtonDescriptionWrapper order.
        public Integer compareTo(Object compareTo) {
            // Cast argument to LabelDescriptionWrapper
            ButtonDescriptionWrapper compareToLdwo = (ButtonDescriptionWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (order > compareToLdwo.order) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (order < compareToLdwo.order) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }

    /**
    *  @Description: Wrapper used to set the attributes of a button type
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public class ButtonTypeAttributesWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String title {get; set;}
    }

    /**
    *  @Description: Wrapper used to set actions in the data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/03/2021
    */
    public class StaticActionsDescriptionWrapper{
        @AuraEnabled
        public String type {get; private set;}
        @AuraEnabled
        public Integer order {get;set;}
        @AuraEnabled
        public ActionsTypeAttributesWrapper typeAttributes {get;set;}
        // Constructor used to set the default value of the width of the columns and type
        public staticActionsDescriptionWrapper() {
            this.type = 'action';
        }
    }

    /**
    *  @Description: Wrapper used to set the attributes of a action
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/03/2021
    */
    public class ActionsTypeAttributesWrapper {
        @AuraEnabled
        public List<ActionsWrapper> rowActions {get;set;}
    }

    /**
    *  @Description: Wrapper used to set the name and label of action
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        29/03/2021
    */
    public class ActionsWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String name {get; set;}
        @AuraEnabled
        public String iconName {get; set;}
    }
    
    /**
    *  @Description: Method used to set all the columns of a data table
    *  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */
    public static List<LabelDescriptionWrapper> setLabelDescriptionWrapper (List<String> lstSObjectType, String fieldNamesStr, String objNameStr) {
        List<LabelDescriptionWrapper> labelList = new List<LabelDescriptionWrapper>();
        List<String> fieldSet = new List<String>();
        Map<String, Integer> fieldNameSet = fillMap(fieldNamesStr);
        for (String objectName : lstSObjectType) { //Iteration over the list of received objects to get each field
            if (Schema.getGlobalDescribe().containsKey(objectName)) {
                sObject sObj = Schema.getGlobalDescribe().get(ObjectName).newSObject();                
                //get all the labels for sObject fields and put them in a map, keyed to the field api name
                Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
                for (String fieldName :  fieldNameSet.keySet()) { //Iteration on the field list of an object to create a list of the columns of a data table
                    if (fieldMap.containsKey(fieldName)) {
                        String fieldType = fieldMap.get(fieldName).getDescribe().getType().name().toLowerCase();
                        LabelDescriptionWrapper ldw = new LabelDescriptionWrapper();
                        ldw.typeAttributes = fieldType == PVR_STR_TYPE_DTM || fieldType == PVR_STR_TYPE_DT 
                                             ? new TypeAttributesWrapper() 
                                             : Null;
                        ldw.label = fieldMap.get(fieldName).getDescribe().getLabel();
                         
                        if(objectName == 'SOD_XS_CentroDeCosto__c' && fieldName == 'Name'){
                            ldw.label = Schema.getGlobalDescribe().get('SOD_XS_DocumentoDeVenta__c').getDescribe().fields.getMap().get('SOD_XS_TiendaQueVende__c').getDescribe().getLabel();
                        }
                        
                        ldw.fieldName = objNameStr == null 
                                        ? fieldName 
                                        : objNameStr + '_' + fieldName;
                        ldw.type = getTypeOf(fieldType);
                        ldw.sortable = true;
                        ldw.cellAttributes = ldw.sortable 
                                             ? new CellAttributesWrapper() 
                                             : Null;
                        ldw.objName = ObjectName;
                        ldw.order = fieldNameSet.get(fieldName);
                        labelList.add(ldw);
                    }
                }
            }
        }        
        return labelList;
    }

    /**
    *  @Description: Method used to set all the columns of a data table from Label
    *  @Autor:       Eilhert Andrade, Deloitte, eandradea@deloitte.com
    *  @Date:        04/01/2021
    */
    public static List<LabelDescriptionWrapper> setLabelDescriptionFromLabel (String fieldNames) {
        List<LabelDescriptionWrapper> labelList = new List<LabelDescriptionWrapper>();
        Map<String, String> fieldNameSet = fillMapString(fieldNames);
        for (String fieldName :  fieldNameSet.keySet()) { //Iteration on the field list of an object to create a list of the columns of a data table
                LabelDescriptionWrapper ldw = new LabelDescriptionWrapper();
                ldw.label = fieldName;
                ldw.fieldName = fieldNameSet.get(fieldName);
                ldw.type = PVR_STR_TYPE_TXT;
                ldw.sortable = true;
                ldw.cellAttributes = ldw.sortable 
                                     ? new CellAttributesWrapper() 
                                     : Null;
                labelList.add(ldw);
        } 
        return labelList;
    }


    /**
    *  @Description: Fill map
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */    
    private static Map<String, Integer> fillMap(String fields) {
        Map<String, Integer>  str = new Map<String, Integer>();
        if (!String.isEmpty(fields)) {
            String[] splitStr = fields.Split(PVR_STR_SMCOLON);
            for (String c : splitStr) {
                str.put(c.Split(PVR_STR_COLON)[0], Integer.valueOf(c.Split(PVR_STR_COLON)[1]));
            }
        }
        return str;
    }

    /**
    *  @Description: Fill map
    *  @Autor:       Abdon Tejos, atejoso@deloitte.com
    *  @Date:        26/10/2020
    */    
    private static Map<String, String> fillMapString(String fields) {
        Map<String, String>  str = new Map<String, String>();
        if (!String.isEmpty(fields)) {
            String[] splitStr = fields.Split(PVR_STR_SMCOLON);
            for (String c : splitStr) {
                str.put(c.Split(PVR_STR_COLON)[0], c.Split(PVR_STR_COLON)[1]);
            }
        }
        return str;
    }
}