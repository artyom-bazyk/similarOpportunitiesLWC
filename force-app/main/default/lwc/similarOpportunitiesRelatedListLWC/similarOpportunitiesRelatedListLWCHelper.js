import { track } from 'lwc';
import deleteBookmarkMethod  from "@salesforce/apex/SimilarOpptyRelatedListController.deleteBookmark";
import {SimilarOpportunitiesUtilLWC} from "c/similarOpportunitiesUtilLWC";

export default class SimilarOpportunitiesRelatedListLWCHelper  {
    loadData(state, loadMethod){
        let jsonData = Object.assign({}, state)
        jsonData.allFields = state.allFields.join(',')
        jsonData = JSON.stringify(jsonData)        
        return loadMethod({jsonData})
            .then(response => {
                const data = JSON.parse(response)
                this.processRecords(data.records)   
  
                if(data.fieldDescriptionList){
                    data.columns = this.buildColumns(data.fieldDescriptionList)
                }                
                return data
            })
            .catch(error => {
                SimilarOpportunitiesUtilLWC.handleErrorResponse(error)
            })
    }

    removeRecord(state, fromId, toId){
        const jsonData = JSON.stringify({fromId, toId})
        return deleteBookmarkMethod({fromId, toId})
            .then(response => {
                const data = {
                    records:state.records, 
                    totalNumberOfRows:state.totalNumberOfRows
                }
                const rowIndex = data.records.findIndex(element => {
                  return element.Id === toId;
                })
                data.records.splice(rowIndex, 1);
                data.totalNumberOfRows--
                return data
            })
            .catch(error => {
                SimilarOpportunitiesUtilLWC.handleErrorResponse(error)
            })         
    }
    
    processRecords(records) {
        records.forEach(record => {
            record.LinkName = '/'+record.Id
            for (const col in record) {
                const curCol = record[col];
                if (typeof curCol === 'object') {
                    const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                    SimilarOpportunitiesUtilLWC.flattenStructure(record, col + '_', curCol);
                    if (newVal !== null) {
                        record[col+ '_LinkName'] = newVal;
                    }
                }
            }
        }); 
    }     
    buildColumns(fieldDescriptionList) {
        const columns = SimilarOpportunitiesUtilLWC.buildColumns(fieldDescriptionList)  
        const actions = {
            type: 'action', 
            typeAttributes: { rowActions: [{ label: 'Delete', name: 'delete' }] }
        }         
        columns.push(actions)
        return columns
	}    
}