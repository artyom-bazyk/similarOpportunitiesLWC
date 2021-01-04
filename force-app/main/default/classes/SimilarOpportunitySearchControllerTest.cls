@isTest
public class SimilarOpportunitySearchControllerTest {
    
 	@isTest public static void testInit(){
        Opportunity opp = new Opportunity(
            Name = 'test',
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        insert opp;
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(SimilarOpportunitySearchController.RECORD_ID_PARAM, opp.Id);
        requestMap.put(SimilarOpportunitySearchController.ALL_FIELDS_PARAM, 'OwnerId');
                
        String jsonData = SimilarOpportunitySearchController.initData(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);      
        String oppJson = JSON.serialize(responseMap.get(SimilarOpportunitySearchController.OPPORTUNITY_PARAM));
        Opportunity oppRetrived = (Opportunity)JSON.deserialize(oppJson, Opportunity.class);        
        System.assertEquals(oppRetrived.OwnerId, UserInfo.getUserId());
        List<Object> fieldsDescriptionList = (List<Object>)responseMap.get(SimilarOpportunitySearchController.FIELD_DESCRIPTION_LIST_PARAM);
        System.assert(!fieldsDescriptionList.isEmpty());
    }
    
 	@isTest public static void testFindSimilarOpportunity(){
        Opportunity opp1 = new Opportunity(
            Name = 'test',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            OwnerId = UserInfo.getUserId()
        );
        
        Opportunity opp2 = opp1.clone();
        opp2.StageName = 'Closed Won';   
        insert new List<Opportunity>{opp1, opp2};
                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(SimilarOpportunitySearchController.RECORD_ID_PARAM, opp1.Id);
        requestMap.put(SimilarOpportunitySearchController.OPPORTUNITY_IDS_PARAM, new List<Id>{opp2.Id});        
        
        SimilarOpportunitySearchController.bookmarkOpportunities(JSON.serialize(requestMap));
        
        requestMap.clear();
        requestMap.put(SimilarOpportunitySearchController.OPPORTUNITY_PARAM, opp1);
        requestMap.put(SimilarOpportunitySearchController.ALL_FIELDS_PARAM, 'OwnerId');
        requestMap.put(SimilarOpportunitySearchController.SELECTED_FIELDS_PARAM, 'OwnerId');
        requestMap.put(SimilarOpportunitySearchController.LAST_N_MONTHS_PARAM, 3);
        requestMap.put(SimilarOpportunitySearchController.IS_STRICT_MODE_PARAM, true);
                
        String jsonData = SimilarOpportunitySearchController.findSimilarOpportunities(JSON.serialize(requestMap));
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);     
        List<Object> records = (List<Object>)responseMap.get(SimilarOpportunitySearchController.RECORDS_PARAM);
        List<Object> bookmarkedRecords = (List<Object>)responseMap.get(SimilarOpportunitySearchController.BOOKMARKED_RECORDS_PARAM);
        System.assert(!records.isEmpty());
        System.assert(!bookmarkedRecords.isEmpty());
    }    
}