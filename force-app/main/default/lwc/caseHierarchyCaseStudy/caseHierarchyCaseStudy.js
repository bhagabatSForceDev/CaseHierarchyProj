import { api,wire,LightningElement } from 'lwc';
import getChildCases from '@salesforce/apex/CaseHierarchyController.getChildCases';
import {loadStyle} from 'lightning/platformResourceLoader';
import caseHierarchyCss from '@salesforce/resourceUrl/CaseHierarchy';

const NO_CHILD_MESSAGE = 'No child cases are available for this case';
const ERROR_MESSAGE = 'Unexpected error occured while component load. Please contact your Administrator.';

export default class CaseHierarchyCaseStudy extends LightningElement {

        @api recordId;

        isLoading = true;
        isError = false;

        get noChildCases(){
            if(!this.isError && (!this.caseItems || this.caseItems.length == 0)){
                return true;
            }else{
                return false;
            }
        }

        get userMessage(){
            if(this.noChildCases){
                return NO_CHILD_MESSAGE;
            }else if(this.isError){
                return ERROR_MESSAGE;
            }
        }

        //newItems= [{"label":"00001030","name":"5002w00000rO6bUAAS","expanded":false,"items":[{"label":"00001029","name":"5002w00000rO6bKAAS","expanded":false,"items":[]}]},{"label":"00001026","name":"5002w00000rO6alAAC","expanded":false,"items":[]}];

        columns = [{label: 'Case Number',fieldName: 'caseLink',type: 'url',typeAttributes: {
            label: { fieldName: 'caseNumber' },
        }},
        {label: 'Subject',fieldName: 'subject',type: 'text'},
        {label: 'Origin',fieldName: 'origin',type: 'text'}];

        renderedCallback(){
            console.log('Called RENDEREDCALLBACK');
            loadStyle(this, caseHierarchyCss).then(()=>{
                console.log('CSS LOADED');
            });
        }
        
        @wire(getChildCases,{recordId: '$recordId'}) wiredCall(result){
            if(result.data){
            console.log('RESULT>DATA: '+JSON.stringify(result.data));
            this.caseItems = result.data.childCases.map((ele)=>{
                return this.handleItemCreation(ele);
            });
            console.log('Case Item Data: '+JSON.stringify(this.caseItems));
            this.isLoading=false;
            }else if(result.error){
                console.error(JSON.stringify(result.error));
                this.isError = true;
                this.isLoading=false;
            }
            
        }

        handleItemCreation(item){
            console.log('INSIDE Item->'+JSON.stringify(item));
            let retItem = {caseNumber: item.caseInst.CaseNumber, caseLink: '/'+item.caseInst.Id, subject: item.caseInst.Subject, origin: item.caseInst.Origin, Id: item.caseInst.Id};
            if(item.childCases && item.childCases.length != 0){
                console.log()
                retItem = {...retItem, _children: item.childCases.map((ele)=>{
                    return this.handleItemCreation(ele);
                })};
            }else{
                retItem = {...retItem, items: []};
            }
            console.log('Finally Ret Item: '+JSON.stringify(retItem));
            return retItem;
        }


}