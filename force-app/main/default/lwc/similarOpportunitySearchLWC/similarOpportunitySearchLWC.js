import { LightningElement, track } from 'lwc';
import SimilarOpportunitySearchLWCHelper from "./similarOpportunitySearchLWCHelper";

export default class SimilarOpportunitySearchLWC extends LightningElement {
    @track state = {
        recordId:'',
        allFields:[],
        selectedFields:{},
        lastNMonths:3,
        opportunity:{}
    }
    helper = new SimilarOpportunitySearchLWCHelper()

    constructor(){
        super()
        this.init()
    }

    async init(){
        this.state.recordId = this.getUrlParamValue(window.location.href, 'c__id')
        this.state.allFields = JSON.parse(this.getUrlParamValue(window.location.href, 'c__allFields'))
        this.state.selectedFields = [...this.state.allFields]

        const data = await this.helper.initData(this.state)
        this.state.opportunity = data.opportunity
        this.state.fieldDescriptionList = data.fieldDescriptionList
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
}
