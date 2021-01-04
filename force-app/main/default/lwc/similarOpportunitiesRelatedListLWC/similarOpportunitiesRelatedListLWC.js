import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import SimilarOpportunitiesRelatedListLWCHelper from "./similarOpportunitiesRelatedListLWCHelper";
import initDataMethod from "@salesforce/apex/SimilarOpptyRelatedListController.initData";
import loadMoreData from "@salesforce/apex/SimilarOpptyRelatedListController.loadMoreData";
import {loadStyle} from 'lightning/platformResourceLoader';
import similarOpportunitiesResource from '@salesforce/resourceUrl/similarOpportunitiesResource';

export default class SimilarOpportunitiesRelatedListLWC extends NavigationMixin(LightningElement) {
    @track state = {
        records:[],
        columns:[],
        recordId:'',
        rowsToLoad: 6,
        totalNumberOfRows:0        
    }
    @api recordId
    @api field1 
    @api field2 
    @api field3 
    @api field4
    @api field5

    helper = new SimilarOpportunitiesRelatedListLWCHelper()

    connectedCallback() {
        this.init();
    }
    
    renderedCallback() {
        loadStyle(this, similarOpportunitiesResource + '/similarOpportunities.css')
    }    

    get showShowMore(){
        return this.state.totalNumberOfRows > this.state.records.length
    }

    get hasRecords(){
        return this.state.records && this.state.records.length > 0
    }    

    async init(){
        this.state.recordId = this.recordId
        this.state.rowsToSkip = 0
        this.state.allFields = Array.from(new Set([this.field1, this.field2, this.field3, this.field4, this.field5]))
        const data = await this.helper.loadData(this.state, initDataMethod)
        this.state.records =  this.state.records.concat(data.records)
        this.state.totalNumberOfRows = data.totalNumberOfRows          
        this.state.columns = data.columns          
    }

	async handleShowMore() {
        this.state.rowsToSkip = this.state.records.length
        const data = await this.helper.loadData(this.state, loadMoreData)     
        this.state.records =  this.state.records.concat(data.records) 
        this.state.totalNumberOfRows = data.totalNumberOfRows  
    }    
    
    async handleRowAction(event){
        const data = await this.helper.removeRecord(this.state, this.state.recordId, event.detail.row.Id)
        this.state.records =  [...data.records]
        this.state.totalNumberOfRows = data.totalNumberOfRows  
    }
    
    hanldeFindButton(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Similar_Opportunity_Search',
            },
            state: {
                c__id: this.state.recordId,
                c__allFields: JSON.stringify(this.state.allFields)
            }
        })
    }
}