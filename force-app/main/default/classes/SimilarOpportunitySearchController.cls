public class SimilarOpportunitySearchController {
    public static final String COMMA_SPLITTER = ',';
    public static final String ALL_FIELDS_PARAM = 'allFields';
    public static final String OPPORTUNITY_PARAM = 'opportunity';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String FIELD_DESCRIPTION_LIST_PARAM = 'fieldDescriptionList';
    public static final String OPPORTUNITY_IDS_PARAM = 'opportunityIds';
    public static final String SELECTED_FIELDS_PARAM = 'selectedFields';
    public static final String LAST_N_MONTHS_PARAM = 'lastNMonths';
    public static final String IS_STRICT_MODE_PARAM = 'isStrictMode';
    public static final String RECORDS_PARAM = 'records';
    public static final String BOOKMARKED_RECORDS_PARAM = 'bookmarkedRecords';
    public static final String NAME_FIELD = 'Name';
    
    @AuraEnabled
    public static String initData(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);          
        Map<String, Object> responseMap = new Map<String, Object>(); 
        String allFieldsParam = ((String)requestMap.get(ALL_FIELDS_PARAM));
        List<String> allFields = String.isNotBlank(allFieldsParam) ? String.escapeSingleQuotes(allFieldsParam).split(COMMA_SPLITTER) : new List<String>();
        
        Set<String> fieldsForSelect = new Set<String>(allFields);
        Set<String> fieldsForWhere = new Set<String>(allFields);
        fieldsForSelect.addAll(SimilarOpportunityService.getLookupNames(fieldsForSelect));
        fieldsForSelect.add(NAME_FIELD);
        Id oppId = (Id)requestMap.get(RECORD_ID_PARAM);
        Opportunity opp = (Opportunity)Database.query('SELECT '+String.join(new List<String>(fieldsForSelect),COMMA_SPLITTER)+' FROM Opportunity WHERE Id=:oppId').get(0);
        
        responseMap.put(OPPORTUNITY_PARAM, opp);
        responseMap.put(FIELD_DESCRIPTION_LIST_PARAM, SimilarOpportunityService.getFieldsDescriptionList(new List<String>(fieldsForWhere), opp));
        return JSON.serialize(responseMap);       
    }
     
    
    @AuraEnabled    
    public static void bookmarkOpportunities(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData); 
        String opportunityIdsJson = JSON.serialize(requestMap.get(OPPORTUNITY_IDS_PARAM));
        List<Id> opportunityIds = (List<Id>)JSON.deserialize(opportunityIdsJson, List<Id>.class);        
        Id recordId = (Id)requestMap.get(RECORD_ID_PARAM);       
        SimilarOpportunityService.bookmarkOpportunities(recordId, opportunityIds);       
    }         
    
    @AuraEnabled
    public static String findSimilarOpportunities(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);       
        Map<String, Object> responseMap = new Map<String, Object>(); 
        String allFieldsParam = ((String)requestMap.get(ALL_FIELDS_PARAM));
        List<String> allFields = String.isNotBlank(allFieldsParam) ? String.escapeSingleQuotes(allFieldsParam).split(COMMA_SPLITTER) : new List<String>();
        String selectedFieldsParam = ((String)requestMap.get(SELECTED_FIELDS_PARAM));        
        List<String> selectedFields = String.isNotBlank(selectedFieldsParam) ? String.escapeSingleQuotes(selectedFieldsParam).split(COMMA_SPLITTER) : new List<String>();
        Set<String> fieldsForSelect = new Set<String>(allFields);
        fieldsForSelect.addAll(SimilarOpportunityService.getLookupNames(fieldsForSelect));        
        fieldsForSelect.add(NAME_FIELD);      
        Set<String> fieldsForWhere = new Set<String>(selectedFields);              
        String oppJson = JSON.serialize(requestMap.get(OPPORTUNITY_PARAM));
        Opportunity opp = (Opportunity)JSON.deserialize(oppJson, Opportunity.class);
        Integer lastNMonths = (Integer)requestMap.get(LAST_N_MONTHS_PARAM);
        Boolean isStrictMode = (Boolean)requestMap.get(IS_STRICT_MODE_PARAM);
        List<Opportunity> records = SimilarOpportunityService.findSimilarOpportunities(opp, lastNMonths, fieldsForSelect, fieldsForWhere, isStrictMode);
        responseMap.put(RECORDS_PARAM, records);
        responseMap.put(BOOKMARKED_RECORDS_PARAM, SimilarOpportunityService.getBookmarkedOpportunities(opp.Id, records));        
        return JSON.serialize(responseMap);            
    }

}