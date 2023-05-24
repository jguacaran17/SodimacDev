/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 05/11/2020
Description  : Javascript Helper - 360 view of a client: Panel for Reserves Lists
History      : CMRSC-3930
**************************ACRONYM OF AUTHORS************************************
AUTHOR                      ACRONYM
Rodrigo Salinas Oye			RSO
********************************************************************************
VERSION  AUTHOR         DATE            Description
1.0      RSO			05/11/2020		initial version
********************************************************************************/
({
   /**
    *  @Description: Object Definition for Component Data
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    getComponentDataObject: function(component, helper, lstData) {
        let obj = {
            navigation: [],              // Array[]
            selectedItem: '',             // String

            getNavigationObject : function () {
                return this.navigation;
            },

            getSelectedItem : function () {
                return this.selectedItem;
            },

            setSelectedItem: function (strName) {
                let strIcon = 'utility:chevronright';
                this.navigation.forEach( function (s) {
                    s.items.forEach(function (i) {
                        if (strName.localeCompare(i.getName()) == 0) {
                            i.setIcon(strIcon);
                            this.selectedItem = i.getName();
                        }
                        else {
                            i.setIcon(null);
                        }
                    }, this);
                }, this);
            }
        }

        // constructor del objeto
        let labelObject = component.get('v.labelObject');
        let objSection = helper.getSectionObject(component, helper, labelObject.panel.title );
        lstData.forEach( function (d) {
            let objItem = helper.getItemObject(component, helper, d, d, null);
            objSection.addItem(objItem);
        })
        obj.navigation.push(objSection);
        obj.setSelectedItem(objSection.getItem(0).getName());

        return obj;
    },

   /**
    *  @Description: Object Definition for Section object
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   getSectionObject: function(component, helper, strLabel) {
        let obj = {
            label: '',              // String
            items: [],             // Array[]

            addItem : function( objItem ) {
                this.items.push(objItem);
            },

            getItem : function (intIndex) {
                return this.items[intIndex];
            }
        }

        // constructor del objeto
        obj.label = strLabel;
        return obj;
    },

   /**
    *  @Description: Object Definition for Item object
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   getItemObject: function(component, helper, strName, strLabel, strIcon) {
        let obj = {
            name: '',            // String
            label: '',           // String
            icon: null,             // String

            getName : function () {
                return this.name;
            },

            setIcon : function ( str ) {
                this.icon = str;
            }
        }

        // constructor del objeto
        obj.name = strName;
        obj.label = strLabel;
        obj.icon = strIcon;
        return obj;
    },

    /**
    *  @Description: Initialize the list of Reserves Numbers to show in the panel
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
    setPanelAttributes: function(component, objComponentData) {
        component.set("v.objComponentData", objComponentData);
    },

    /**
    *  @Description: Fire the event to communicate the reserve number selected
    *  @Autor:       Rodrigo Salinas Oye, Deloitte, rosalinas@deloitte.com
    *  @Date:        05/11/2020
    */
   fireSelectEvent: function(component, strSelection) {
        var cmpEvent = component.getEvent("onPanelSelectionFired");   // getting the Instance of event  
        cmpEvent.setParams({ "reserveNumber" : strSelection });              // setting the attribute of event
        cmpEvent.fire();  
   }
})