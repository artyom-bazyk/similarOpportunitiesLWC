public class SimilarOpptyRelatedListController {
    public static final String COMMA_SPLITTER = ',';
    public static final String NAME_FIELD = 'Name';

    public static final String ALL_FIELDS_PARAM = 'allFields';
    public static final String RECORD_ID_PARAM = 'recordId';    
    public static final String ROWS_TO_LOAD_PARAM = 'rowsToLoad';    
    public static final String ROWS_TO_SKIP_PARAM = 'rowsToSkip';    
    public static final String TOTAL_NUMBER_OF_ROWS_PARAM = 'totalNumberOfRows';    
    public static final String RECORDS_PARAM = 'records';    
    public static final String FIELD_DESCRIPTION_LIST_PARAM = 'fieldDescriptionList';

    @AuraEnabled
    public static String initData(String jsonData){
		Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);         
        Map<String, Object> responseMap = loadMoreData(requestMap); 
        String allFields = ((String)requestMap.get(ALL_FIELDS_PARAM));
        List<String> fields = String.isNotBlank(allFields) ? String.escapeSingleQuotes(allFields).split(COMMA_SPLITTER) : new List<String>();

        responseMap.put(FIELD_DESCRIPTION_LIST_PARAM, SimilarOpportunityService.getFieldsDescriptionList(fields));
        return JSON.serialize(responseMap);       
    }    

    @AuraEnabled
    public static String loadMoreData(String jsonData){
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);          
        Map<String, Object> responseMap = loadMoreData(requestMap);
        return JSON.serialize(responseMap);       
    }    
    
    private static Map<String, Object> loadMoreData(Map<String, Object> requestMap){
        Map<String, Object> responseMap = new Map<String, Object>(); 
        String allFields = ((String)requestMap.get(ALL_FIELDS_PARAM));
        List<String> fields = String.isNotBlank(allFields) ? String.escapeSingleQuotes(allFields).split(COMMA_SPLITTER) : new List<String>();
        
        Set<String> fieldsForSelect = new Set<String>(fields);
        Set<String> fieldsForWhere = new Set<String>(fields);
        fieldsForSelect.addAll(SimilarOpportunityService.getLookupNames(fieldsForSelect));
        fieldsForSelect.add(NAME_FIELD);
        Id oppId = (Id)requestMap.get(RECORD_ID_PARAM);
        Integer rowsToLoad = (Integer)requestMap.get(ROWS_TO_LOAD_PARAM);
        Integer rowsToSkip = (Integer)requestMap.get(ROWS_TO_SKIP_PARAM);
        Integer totalNumberOfRows = SimilarOpportunityService.getBookmarkedOpportunitiesAmount(oppId);
        responseMap.put(TOTAL_NUMBER_OF_ROWS_PARAM, totalNumberOfRows);
        responseMap.put(RECORDS_PARAM, (List<Opportunity>)SimilarOpportunityService.getBookmarkedOpportunities(oppId, fieldsForSelect, rowsToLoad, rowsToSkip));
        return responseMap;       
    }    
    
    @AuraEnabled    
    public static void deleteBookmark(String fromId, String toId){
        delete [Select Id From Bookmark Where FromId = :fromId AND ToId = :toId];
    }                  
}