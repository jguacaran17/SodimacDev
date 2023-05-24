/*********************************************************************************
Project      : Sodimac Salesforce Service Cloud
Created By   : Deloitte
Created Date : 27/10/2020
Description  : JS Utility library for the data table
History                                                            
--------------------------ACRONYM OF AUTHORS-------------------------------------
AUTHOR                      ACRONYM
AbdÃ³n Tejos Oliva			ATO
---------------------------------------------------------------------------------
VERSION  AUTHOR         DATE            Description
1.0      ATO			27/10/2020		initial version
********************************************************************************/
	/**
	*  @Description: Loops through each object within the array and passes it to the object flattener
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        27/10/2020
	*/
	window.jsFlattenEach = function(obj)
	{
		//this is the final array into which the flattened response will be pushed.
		var flatObject = [];
		// get keys of a single row
		for (var key in obj) {
			//push all the flattened rows to the final array
			flatObject.push(jsFlattenObjData(obj[key]));
		}
		return flatObject;
	},
	/**
	*  @Description: Flattens each complex object into a simple object
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        27/10/2020
	*/
	window.jsFlattenObjData = function(obj) {
		// this const stroes a single flattened row. 
		var newObj = {};
		for (var key in obj) {
			//if this typeof is an object, we need to flatten again
			if (typeof obj[key] === 'object' && obj[key] !== null) {
				var temp = jsFlattenObjData(obj[key])
				for (var key2 in temp) {
					if (isNaN(key)) {
						newObj[key+"_"+key2] = temp[key2];
					} else {
						newObj[key2] = temp[key2];
					}
				}
			}//if it’s a normal string push it to the flattenedRow array
			else {
				newObj[key] = obj[key];
			}
		}
		return newObj;
	},
	/**
	*  @Description: Used to sort the columns
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        27/10/2020
	*/
	window.jsSortBy = function(field, reverse, primer) {
		var key = primer
            ? function(x)
			{
				return primer(x[field]);
			}
			: function(x)
			{
				return x[field];
			};
		return function(a, b) {
			a = key(a);
			b = key(b);
			return reverse * ((a > b) - (b > a));
		};
	},
	/**
	*  @Description: Used to handle jsSortBy method
	*  @Autor:       Abdon Tejos, Deloitte, atejoso@deloitte.com
	*  @Date:        27/10/2020
	*/
	window.jsHandleSort = function(component, event) {
		var sortedBy = event.getParam('fieldName');
		var sortDirection = event.getParam('sortDirection');

		var cloneData = component.get('v.data').slice(0);
		cloneData.sort((jsSortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));

		component.set('v.data', cloneData);
		component.set('v.sortDirection', sortDirection);
		component.set('v.sortedBy', sortedBy);
	}