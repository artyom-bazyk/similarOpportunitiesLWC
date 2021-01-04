import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent } from "c/pubsub";

export default class SimilarOpportunityCriteriaLWC extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api fieldDescriptionList
    @api selectedMonth  

    @track state = {
        monthsRange : [
            { label: 'Last 3 months', value: 3 },
            { label: 'Last 3-6 months', value: 6 },
            { label: 'Last 6-9 months', value: 9 },
            { label: 'Last 9-12 months', value: 12 }
        ],
        selectedMonth:3
    }


    handleSelectChange(event){
        this.state.selectedMonth = parseInt(event.detail.value) 
        this.handleCriteriaChange()
    }
    
    handleCriteriaChange(){
        const allFields = []
        let selectedFields = []
        const criteriaCheckboxes = Array.from(this.template.querySelectorAll('lightning-input'))
        criteriaCheckboxes.forEach(element => {
            if(element.checked){
                selectedFields.push(element.value)
            }
            allFields.push(element.value)
        })
        const isStrictMode = selectedFields.length > 0
        selectedFields = selectedFields.length > 0 ? selectedFields : allFields
        const eventDetail = {
            selectedFields : selectedFields,
            isStrictMode:isStrictMode,
            selectedMonth:this.state.selectedMonth
           }
        fireEvent(this.pageRef, 'criteriaChange', eventDetail);
    }
}