/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 17/11/2020
Description  : Test Class SOD_XS_DataTableUtily
History
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Abdon Tejos O.			    ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			17/11/2020		initial version
1.0      EAA			07/01/2021		update table columns
********************************************************************************/
@isTest
public with sharing class SOD_XS_DataTableUtily_TEST {

    /**
    * @description Test all the methods of the SOD_XS_DataTableUtily class
    * @Autor       ATO, Deloitte, atejoso@deloitte.com
    * @date        17/11/2020
    */ 
    @isTest static void allMethodsTest() {
        String objName = Schema.SObjectType.Account.getName();
        String columns =' FirstName:1;LastName:2;PersonEmail:3;PersonBirthdate:4';
        Test.startTest();
        // Loading table columns
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> labelsTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        labelsTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionWrapper(new List<String>{objName}, columns, Null));
        labelsTable.sort();
        List<SOD_XS_DataTableUtily.LabelDescriptionWrapper> labelsPrdTable = new List<SOD_XS_DataTableUtily.LabelDescriptionWrapper>();
        labelsPrdTable.addAll(SOD_XS_DataTableUtily.setLabelDescriptionFromLabel(columns));
        labelsPrdTable.sort();
        // Loading button in data table
        List<SOD_XS_DataTableUtily.ButtonDescriptionWrapper> bttList = new List<SOD_XS_DataTableUtily.ButtonDescriptionWrapper>();
        SOD_XS_DataTableUtily.ButtonDescriptionWrapper btt = new SOD_XS_DataTableUtily.ButtonDescriptionWrapper();
        btt.label = 'Nuevo';
        btt.order = 0; 
        btt.typeAttributes = new SOD_XS_DataTableUtily.ButtonTypeAttributesWrapper();
        btt.typeAttributes.label = 'Nuevo';
        btt.typeAttributes.name =  'action_new';
        btt.typeAttributes.title = 'Click para crear una nueva cuenta';
		SOD_XS_DataTableUtily.ButtonDescriptionWrapper bttTwo = new SOD_XS_DataTableUtily.ButtonDescriptionWrapper();
        bttTwo.label = 'Modificar';
        bttTwo.order = 1; 
        bttTwo.typeAttributes = new SOD_XS_DataTableUtily.ButtonTypeAttributesWrapper();
        bttTwo.typeAttributes.label = 'Modificar';
        bttTwo.typeAttributes.name =  'action_modify';
        bttTwo.typeAttributes.title = 'Click para modificar una cuenta';
        bttList.add(btt);
        bttList.add(bttTwo);
        bttList.sort();
        SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper act = new SOD_XS_DataTableUtily.StaticActionsDescriptionWrapper();
        act.order = 0; 
        act.typeAttributes = new SOD_XS_DataTableUtily.ActionsTypeAttributesWrapper();
        act.typeAttributes.rowActions = new List<SOD_XS_DataTableUtily.ActionsWrapper>();
        SOD_XS_DataTableUtily.ActionsWrapper actions = new SOD_XS_DataTableUtily.ActionsWrapper();
        actions.label = 'Ver Proyecto';
        actions.name = 'view_projectDetail';
        actions.iconName = 'utility:zoomin';
        act.typeAttributes.rowActions.add(actions);
        System.assertEquals(!labelsTable.isEmpty(), true, 'The columns of the data table has been returned');
        System.assertEquals(!labelsPrdTable.isEmpty(), true, 'The columns of the data table product has been returned');
        System.assertEquals(btt != null, true, 'The button has been created');
        System.assertEquals(bttTwo != null, true, 'The button Two has been created');
        System.assertEquals(!bttList.isEmpty(), true, 'The list of buttons has been returned');
        System.assertEquals(!act.typeAttributes.rowActions.isEmpty(), true, 'The list of actions has been returned');
        Test.stopTest();
    }
    
}