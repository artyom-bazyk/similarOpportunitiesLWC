global class SimilarOpportunityCriteriaPickList extends VisualEditor.DynamicPickList{
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Name', 'Name');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
        VisualEditor.DynamicPickListRows  plValues = new VisualEditor.DynamicPickListRows();
        for (Schema.SObjectField field: fieldMap.values()){
            Schema.DescribeFieldResult descField = field.getDescribe();
            if(descField.isUpdateable() && descField.isFilterable()){
                VisualEditor.DataRow value = new VisualEditor.DataRow(descField.getLabel(), descField.getName());
                plValues.addRow(value);
            }
        }        
        return plValues;
    }
}