/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 16/02/2021
Description  : Trigger Handler class for ContentDocument object
History      : CMRSC 5037
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
Pablo L�pez B�rquez	      PLB

---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      PLB	     16/02/2021		Initial definition of the class.
********************************************************************************/

public with sharing class SOD_XS_ContentDocTriggerHandler extends SOD_XS_AbstractTriggerHandler{
   
    /**
*  @description Before insert preparations
*  @Author:      Nelson Lepiqueo, Deloitte
*  @Date:        16/02/2021
*/
    public override void beforeUpdate(){
        if(Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE) {
            
            List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                                               FROM ContentDocumentLink
                                               WHERE ContentDocumentId=:Trigger.newMap.keySet()];
            
            List<FeedItem> feeds = new List<FeedItem>();
            for(ContentDocumentLink contDocLink : links) {
                if(contDocLink.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                    feeds.add(new FeedItem(
                        ParentId=contDocLink.LinkedEntityId,
                        Type='TextPost',
                        Body='El archivo <b>'+contDocLink.ContentDocument.Title+'</b> se ha cargado',
                        isRichText=true
                    ));
                }
            }
            if(feeds.size()>0) insert feeds;
        }
        
        /**
*  @description Before delete preparations
*  @Author:      Nelson Lepiqueo, Deloitte
*  @Date:        16/02/2021
*/        
        
    }
    public override void beforeDelete(){
        
        if(Trigger.operationType == System.TriggerOperation.BEFORE_DELETE) {
            List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title 
                                               FROM ContentDocumentLink
                                               WHERE ContentDocumentId=:Trigger.oldMap.keySet()];
            List<FeedItem> feeds = new List<FeedItem>();
            for(ContentDocumentLink contDocLink : links) {
                if(contDocLink.LinkedEntityId.getSObjectType() == Case.SObjectType) {
                    feeds.add(new FeedItem(
                        ParentId=contDocLink.LinkedEntityId,
                        Type='TextPost',
                        Body='El archivo <b>'+contDocLink.ContentDocument.Title+'</b> se ha eliminado',
                        isRichText=true
                    ));
                }
            }
            if(feeds.size()>0) insert feeds;
        }
    }
    
}