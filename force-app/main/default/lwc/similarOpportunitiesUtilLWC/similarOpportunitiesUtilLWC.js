
const SimilarOpportunitiesUtilLWC = {
    buildColumns : function (fieldDescriptionList) {
        const columns = [ { label: 'Name', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} }]
        fieldDescriptionList.forEach(fieldDescription => {
            if(fieldDescription.apiName != 'Name'){                
                const column = {label: fieldDescription.label, fieldName: fieldDescription.apiName, type: fieldDescription.type.toLowerCase()}
                if(column.type === 'currency'
                || column.type === 'percent'){
                    column.cellAttributes = { alignment: 'left' }
                }else if(column.type === 'date'){
                    column.typeAttributes = {month:"2-digit", day:"2-digit"}
                    column.type = 'date-local'
                }else if(column.type === 'reference'){
                    const linkName = fieldDescription.apiRelationshipName + '_' + fieldDescription.apiNameOnParent
                    const fieldName = fieldDescription.apiRelationshipName + '_LinkName'
                    column.typeAttributes = {label: { fieldName: linkName }, target: '_top'}
                    column.type = 'url'
                    column.fieldName = fieldName
                }
                columns.push(column)
            }            
        })    
        return columns
    },  
        
    flattenStructure : function (topObject, prefix, toBeFlattened)  {
        for (const propertyName in toBeFlattened) {
            const propertyValue = toBeFlattened[propertyName];
            if (typeof propertyValue === 'object') {
                this.flattenStructure(topObject, prefix + propertyName + '_', propertyValue);
            } else {
                topObject[prefix + propertyName] = propertyValue;
            }
        }
    },

    handleErrorResponse : function(error) {   
        if (error) {
            if (error.message) {
                console.log("Error message: " + error.message)
            }
        } else {
            console.log("Unknown error")
        }     
    },    

}
export {SimilarOpportunitiesUtilLWC}
