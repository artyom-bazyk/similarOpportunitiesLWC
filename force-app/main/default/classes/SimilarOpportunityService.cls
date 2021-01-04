public class SimilarOpportunityService {
    public static final String OR_CLAUSE = 'OR';
    public static final String AND_CLAUSE = 'AND';
    public static final Integer ROWS_TO_LOAD = 300;
    
    public static final String DOT_SPLITTER = '.';
    public static final String COMMA_SPLITTER = ',';
    
    public static final String YYYMMDD_FORMAT = 'yyy-MM-dd';
    public static final Integer CLOSE_DATE_RANGE = 3;    
    public static final String DEFAULT_EXPRESSION = 'expr0';    
    
    public static List<Opportunity> getBookmarkedOpportunities(Id oppId, Set<String> fieldsForSelect, Integer rowsToLoad, Integer rowsToSkip){
        List<Bookmark> bookmarkedOppties = [SELECT Id, FromId, ToId FROM Bookmark WHERE FromId =:oppId AND IsDeleted = false LIMIT :rowsToLoad OFFSET :rowsToSkip];
        List<Id> oppIds = new List<Id>();
        for(Bookmark bookmark : bookmarkedOppties){
            oppIds.add(bookmark.ToId);
        }
        String query = 'SELECT '+String.join(new List<String>(fieldsForSelect),COMMA_SPLITTER)+' FROM Opportunity WHERE Id IN :oppIds ';
		return Database.query(String.escapeSingleQuotes(query));
    }     
    
    public static Integer getBookmarkedOpportunitiesAmount(Id oppId){
        List<AggregateResult> aggrResult = [SELECT count(Id) FROM Bookmark WHERE FromId =:oppId AND IsDeleted = false];
    	return (Integer)aggrResult.get(0).get(DEFAULT_EXPRESSION);
    }        
    
    public static List<Sobject> findSimilarOpportunities(Opportunity opp, Integer lastNMonths, Set<String> fieldsForSelect, 
                                                         Set<String> fieldsForWhere, Boolean isStrictMode){
		String query = getSimilarOpportunitiesQuery(opp, lastNMonths, fieldsForSelect, fieldsForWhere, isStrictMode);
        query += ' ORDER BY Name LIMIT :ROWS_TO_LOAD ';
        return Database.query(query);
	} 
    
    public static List<Id> getBookmarkedOpportunities(Id oppId, List<Opportunity> optyList){
        List<Bookmark> bookmarkedOppties = [SELECT Id, FromId, ToId FROM Bookmark WHERE FromId =:oppId AND ToId IN :optyList AND IsDeleted = false];
        List<Id> oppIds = new List<Id>();
        for(Bookmark bookmark : bookmarkedOppties){
            oppIds.add(bookmark.ToId);
        }    
        return oppIds;
    }           
    
    public static void bookmarkOpportunities(Id recordId, List<Id> opportunityIds){
        List<Bookmark> bookmarkList = new List<Bookmark>();
        
        for(Id oppId : opportunityIds){
            Bookmark bookmark = new Bookmark(
                FromId = recordId,
                ToId = oppId
            );            
            bookmarkList.add(bookmark);
        }
        insert bookmarkList;        
    }      
    
    private static String getSimilarOpportunitiesQuery(Opportunity opp, Integer lastNMonths, Set<String> fieldsForSelect, Set<String> fieldsForWhere, Boolean isStrictMode){
        Date lowerRange = System.today().addMonths(-lastNMonths);
        String lowerRangeFormatted = Datetime.newInstance(lowerRange.year(), lowerRange.month(), lowerRange.day()).format(YYYMMDD_FORMAT); 
        Date upperRange = System.today().addMonths(-(lastNMonths - CLOSE_DATE_RANGE));
        String upperRangeFormatted = Datetime.newInstance(upperRange.year(), upperRange.month(), upperRange.day()).format(YYYMMDD_FORMAT); 
        
        String query = 'SELECT '+String.join(new List<String>(fieldsForSelect),COMMA_SPLITTER)
            		 +' FROM Opportunity'
            		 +' WHERE Id != \''+opp.Id+'\''
					 +' AND StageName = \'Closed Won\''
            		 +' AND CloseDate >= ' +lowerRangeFormatted 
            		 +' AND CloseDate <= '+upperRangeFormatted;
        if(!fieldsForWhere.isEmpty()){
            query += +' AND (';
            Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
            String clause = isStrictMode ? AND_CLAUSE : OR_CLAUSE;
            for(String field : fieldsForWhere){
                Schema.DescribeFieldResult descField = fieldMap.get(field).getDescribe();
                if(opp.get(field) != null){
                    if(descField.getType() == Schema.DisplayType.DATE){
                        Date d = (Date)opp.get(field);
                        String dateFormatted = Datetime.newInstance(d.year(), d.month(), d.day()).format(YYYMMDD_FORMAT);                  
                        query += ' ' +field + ' = ' + dateFormatted + ' ' + clause;                                    
                    }else if(descField.getType() == Schema.DisplayType.BOOLEAN
                             || descField.getType() == Schema.DisplayType.PERCENT
                             || descField.getType() == Schema.DisplayType.CURRENCY){
                                 query += ' ' +field + ' = ' + opp.get(field) + ' ' + clause;                                    
					}else{
                        query += ' ' +field + ' = \'' + opp.get(field) + '\' ' + clause;                                    
                    }
                }
            }
            query = query.removeEnd(clause) + ')  ';
            
        }
        return query;
    }        
    
    public static List<FieldDescription> getFieldsDescriptionList(List<String> fields){       
        return getFieldsDescriptionList(fields, null);
    }     
    
    public static List<FieldDescription> getFieldsDescriptionList(List<String> fields, Opportunity opp){       
        List<FieldDescription> fieldDescriptionList = new List<FieldDescription>();
        Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
        for (String fieldName: fields){
            FieldDescription fieldDescription = new FieldDescription();
            Schema.DescribeFieldResult descField = fieldMap.get(fieldName).getDescribe();
            fieldDescription.label = descField.getLabel();
            fieldDescription.apiName = descField.getName();
            fieldDescription.type = descField.getType().name();
            if(descField.getType() == Schema.DisplayType.REFERENCE){
                Map<String, Schema.SObjectField> parentFieldMap = descField.getReferenceTo().get(0).getDescribe().fields.getMap();
                for (String parentFieldName: parentFieldMap.keySet()){
                    Schema.DescribeFieldResult parentDescField = parentFieldMap.get(parentFieldName).getDescribe();
                    if(parentDescField.isAutoNumber() || parentDescField.isNameField()){
                        Sobject parent = opp == null ? null : opp.getSobject(descField.getRelationshipName()); 
                        fieldDescription.value = parent == null ? null : (String)parent.get(parentDescField.getName());
                        fieldDescription.apiRelationshipName = descField.getRelationshipName();
                        fieldDescription.apiNameOnParent = parentDescField.getName();
                        break;
                    }
                }
            }else{
                fieldDescription.value =  opp == null ? null : opp.get(fieldName);                
            }
            fieldDescriptionList.add(fieldDescription);                
        }        
        return fieldDescriptionList;
    }
    
    public static List<String> getLookupNames(Set<String> fields){
        List<String> lookupFields = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Opportunity.SObjectType.getDescribe().fields.getMap();
        for(String field : fields){
            Schema.DescribeFieldResult descField = fieldMap.get(field).getDescribe();
            if( descField.getType() == Schema.DisplayType.REFERENCE){
                Map<String, Schema.SObjectField> parentFieldMap = descField.getReferenceTo().get(0).getDescribe().fields.getMap();
                for (String parentFieldName: parentFieldMap.keySet()){
                    Schema.DescribeFieldResult parentDescField = parentFieldMap.get(parentFieldName).getDescribe();
                    if(parentDescField.isAutoNumber() || parentDescField.isNameField()){
                        lookupFields.add(descField.getRelationshipName()+ DOT_SPLITTER + parentDescField.getName());                    
                        break;
                    }
                }            
            }
        }        
        return lookupFields;
    }           
}