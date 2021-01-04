import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SimilarOpportunityResultsLWCHelper from "./similarOpportunityResultsLWCHelper";
import { CurrentPageReference } from "lightning/navigation";
import { registerListener, unregisterAllListeners } from "c/pubsub";
import {loadStyle} from 'lightning/platformResourceLoader';
import similarOpportunitiesResource from '@salesforce/resourceUrl/similarOpportunitiesResource';

export default class SimilarOpportunityResultsLWC extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;    
    @track state = {
        records:[],
        columns:[],
        rowsToLoad: 20,
        allFields:[],
        selectedFields:[],
        opportunity:{},
        isStrictMode:false,
        allRecords:[],
        preselectedRows:[],
        selectedRows:[]
    }
    @api allFields
    @api selectedMonth
    @api selectedFields

    helper = new SimilarOpportunityResultsLWCHelper()


    @api get fieldDescriptionList(){
        return this.state.fieldDescriptionList
    }
    set fieldDescriptionList(value){
        this.state.fieldDescriptionList = value
        this.init();
    }

    @api get opportunity(){
        return this.state.opportunity
    }
    set opportunity(value){
        this.state.opportunity = value
        this.init();
    }    

    connectedCallback() {
        registerListener('criteriaChange', this.handleCriteriaChange, this);
    }   

    disconnectedCallback() {
        unregisterAllListeners(this);
    }     

    renderedCallback() {
        loadStyle(this, similarOpportunitiesResource + '/similarOpportunities.css')
    }   

    @api
    async init(){
        if( !(this.fieldDescriptionList
            && this.opportunity
            && this.opportunity.Id
            && this.allFields
            && this.selectedMonth
            && this.selectedFields)){
            return
        }
        this.state.fieldDescriptionList = this.fieldDescriptionList
        this.state.opportunity = this.opportunity
        this.state.allFields = this.allFields
        this.state.selectedMonth = this.selectedMonth
        this.state.selectedFields = this.selectedFields

        const data = await this.helper.findSimilarOpportunities(this.state)
        this.state.records = data.records
        this.state.allRecords = data.allRecords
        this.state.preselectedRows = data.preselectedRows
        this.state.selectedRows = data.preselectedRows
        this.state.columns = this.helper.buildColumns(this.fieldDescriptionList)
    }

    get showMore(){
        return this.state.records && this.state.allRecords.length > this.state.records.length
    }

    get hasRecords(){
        return this.state.records && this.state.records.length > 0
    }    

    async handleCriteriaChange(event) {
        this.state.selectedMonth = event.selectedMonth
        this.state.selectedFields = event.selectedFields
        this.state.isStrictMode = event.isStrictMode

        const data = await this.helper.findSimilarOpportunities(this.state)
        this.state.records = data.records
        this.state.allRecords = data.allRecords
        this.state.preselectedRows = data.preselectedRows
        this.state.selectedRows = data.preselectedRows        
    }

    handleShowMore() {
        this.state.records = this.helper.fetchData(this.state.rowsToLoad, this.state.allRecords, this.state.records)
        this.state.preselectedRows = [...this.state.preselectedRows]
        this.state.selectedRows = [...this.state.selectedRows]
    }    

    handleRowSelection (event) {
        const selectedRowSet = new Set(this.state.preselectedRows)
        event.detail.selectedRows.forEach(row => {
            selectedRowSet.add(row.Id)
        })
        this.state.selectedRows = Array.from(selectedRowSet)        
    }    

    async handleBookmarkButton(){
        await this.helper.bookmarkOpportunities(this.state)
        this.navigateToOpportunity(this.state.opportunity.Id)
    }

    handleCancelButton() {
        this.navigateToOpportunity(this.state.opportunity.Id)     
    }    

    navigateToOpportunity(oppId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: oppId,
                actionName: 'view'
            }
        });
    }    
}