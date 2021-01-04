import initDataMethod from "@salesforce/apex/SimilarOpportunitySearchController.initData";
import {SimilarOpportunitiesUtilLWC} from "c/similarOpportunitiesUtilLWC";

export default class SimilarOpportunitySearchLWCHelper {
    initData(state){
        let jsonData = Object.assign({}, state)
        jsonData.allFields = state.allFields.join(',')
        jsonData = JSON.stringify(jsonData)  
        return initDataMethod({jsonData})
            .then( response => {
                return JSON.parse(response)
            })
            .catch(error => {
                SimilarOpportunitiesUtilLWC.handleErrorResponse(error)
            })            
    }
}