@isTest
public class SimilarOpptyRelatedListControllerTest {
    public static Opportunity opp1;
    public static Opportunity opp2;
    public static Bookmark bookmark;
    
    private static void setup() {
        opp1 = new Opportunity(
            Name = 'test',
            StageName = 'Prospecting',
            CloseDate = System.today(),
            OwnerId = UserInfo.getUserId()
        );        
        opp2 = opp1.clone();
        opp2.StageName = 'Closed Won';
            
        insert new List<Opportunity>{opp1, opp2};
        bookmark = new Bookmark(
            FromId = opp1.Id,
            ToId = opp2.Id
        );    
        insert bookmark;     
    }    
    
	@isTest public static void testLoadMore(){
		setup();                
        Map<String, Object> requestMap = new Map<String, Object>(); 
        requestMap.put(SimilarOpptyRelatedListController.RECORD_ID_PARAM, opp1.Id);
        requestMap.put(SimilarOpptyRelatedListController.ALL_FIELDS_PARAM, 'OwnerId');
        requestMap.put(SimilarOpptyRelatedListController.ROWS_TO_LOAD_PARAM, 10);
        requestMap.put(SimilarOpptyRelatedListController.ROWS_TO_SKIP_PARAM, 0);
                
        String jsonData = SimilarOpptyRelatedListController.initData(JSON.serialize(requestMap));        
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        
        Integer totalNumberOfRows = (Integer)responseMap.get(SimilarOpptyRelatedListController.TOTAL_NUMBER_OF_ROWS_PARAM);
        System.assertEquals(1, totalNumberOfRows);
        List<Object> records = (List<Object>)responseMap.get(SimilarOpptyRelatedListController.RECORDS_PARAM);
        System.assert(!records.isEmpty());
        List<Object> fieldsDescriptionList = (List<Object>)responseMap.get(SimilarOpptyRelatedListController.FIELD_DESCRIPTION_LIST_PARAM);
        System.assert(!fieldsDescriptionList.isEmpty());
        
        requestMap.put(SimilarOpptyRelatedListController.ROWS_TO_SKIP_PARAM, 1);        
        jsonData = SimilarOpptyRelatedListController.loadMoreData(JSON.serialize(requestMap));     
        responseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);       
        records = (List<Object>)responseMap.get(SimilarOpptyRelatedListController.RECORDS_PARAM);
        System.assert(records.isEmpty());        
    }
    
	@isTest public static void testDeleteBookmark(){
		setup();                                
        SimilarOpptyRelatedListController.deleteBookmark(bookmark.FromId, bookmark.ToId);                
        List<Bookmark> bookmarks = [SELECT Id FROM Bookmark];
        System.assert(bookmarks.isEmpty());
    }    
}