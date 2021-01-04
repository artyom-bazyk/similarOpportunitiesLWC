import { LightningElement, track, api } from 'lwc';
import findSimilarOpportunitiesMethod  from "@salesforce/apex/SimilarOpportunitySearchController.findSimilarOpportunities";
import bookmarkOpportunitiesMethod  from "@salesforce/apex/SimilarOpportunitySearchController.bookmarkOpportunities";
import {SimilarOpportunitiesUtilLWC} from "c/similarOpportunitiesUtilLWC";

export default class SimilarOpportunityResultsLWCHelper{
    findSimilarOpportunities(state){
        let jsonData = Object.assign({}, state)
        jsonData.allFields = state.allFields.join(',')
        jsonData.selectedFields = state.selectedFields.join(',')
        jsonData.lastNMonths = state.selectedMonth
        jsonData.recordId = state.opportunity.Id
        jsonData = JSON.stringify(jsonData)     

        return findSimilarOpportunitiesMethod({jsonData})
            .then(response => { 
                const data = JSON.parse(response)
                this.processRecords(state, data)  
                data.allRecords = [...data.records]
                data.records = this.fetchData(state.rowsToLoad, data.records, [])
                return data
            })
            .catch(error => {
                SimilarOpportunitiesUtilLWC.handleErrorResponse(error)
            })
    }

    bookmarkOpportunities(state){
        const newSelectedRows = new Set(state.selectedRows)
        state.preselectedRows.forEach(record =>{
	        newSelectedRows.delete(record)            
        })
        const jsonData = JSON.stringify({
            recordId: state.opportunity.Id, 
            opportunityIds: Array.from(newSelectedRows)
        })
        return bookmarkOpportunitiesMethod({jsonData})
            .catch(error => {
                SimilarOpportunitiesUtilLWC.handleErrorResponse(error)
            })
    }

    buildColumns(fieldDescriptionList) {
        const columns = SimilarOpportunitiesUtilLWC.buildColumns(fieldDescriptionList)
        columns.push({ label: 'Relevancy', fieldName: 'relevancy', type: 'text'})
        return columns
    }
    
    fetchData (rowsToLoad, allRecords, records){        
        const newData = allRecords.slice(records.length, records.length + rowsToLoad)
		records = records.concat(newData)
        return records
        
    }    
    
    processRecords (state, data) {
        const preselectedRows = new Set(state.preselectedRows)
        const bookmarkedIdsSet = new Set(data.bookmarkedRecords)
		const maxRelevancyScore = state.fieldDescriptionList.length       
        data.records.forEach(record => {
            record.LinkName = '/'+record.Id
            record.relevancyScore = 0;
            state.allFields.forEach(field => {
                if(record[field] === state.opportunity[field] && record[field] != null){
                    record.relevancyScore++
                }
            })
            record.relevancy = record.relevancyScore + '/' + maxRelevancyScore
            if(bookmarkedIdsSet.has(record.Id)){
                preselectedRows.add(record.Id)
            }
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
        data.records.sort((a, b) => {return b.relevancyScore - a.relevancyScore});
        data.preselectedRows = Array.from(preselectedRows)
    }      
}