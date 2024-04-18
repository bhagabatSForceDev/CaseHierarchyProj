/*
 * Created By: Bhagabat Sahoo
 * Created Date: 17th April, 2024
 * Description: Apex Controller class for CaseHierarchy Lightning component.
 */
public class CaseHierarchyController {

    /*
     * Method: getChildCases
	 * Params: recordId (Case)
	 * Purpose: Returns a wrapper list of child and grand-child case records	
     */
    @AuraEnabled(cacheable=true)
    public static CaseWrapper getChildCases(Id recordId){
       
       try{
       //Querying child, grand child cases based on parent case Id. 
       List<Case> childCases = [SELECT Id,CaseNumber,ParentId,Subject,Origin FROM Case WHERE ParentId=: recordId
                                OR Parent.ParentId =: recordId OR Parent.Parent.ParentId =: recordId
                                OR Parent.Parent.Parent.ParentId =: recordId OR Parent.Parent.Parent.Parent.ParentId =: recordId];
       
       //Map to store child case Id and its related CaseWrapper instance.
       Map<Id,CaseWrapper> csMap = new Map<Id,CaseWrapper>();
       
       //Creating a parent CaseWrapper instance to return.
       CaseWrapper retCaseWrp = new CaseWrapper();
       retCaseWrp.caseInst = new Case(Id=recordId);
       retCaseWrp.childCases = new List<CaseWrapper>();
       csMap.put(recordId,retCaseWrp);
           
       /*Looping over child cases, creating their wrapper instances and
       storing them in respective parent CaseWrapper instance's list property (childCases).*/
       for(Case cs: childCases){
           CaseWrapper cw = new CaseWrapper();
           cw.caseInst = cs;
           cw.childCases  = new List<CaseWrapper>();
           csMap.get(cs.ParentId).childCases.add(cw);
           csMap.put(cs.Id,cw);
       }
       
       //Returning parent case wrapper instance.
       system.debug('retCaseWrp:'+retCaseWrp);
       return retCaseWrp;
            
       }Catch(Exception e){
            throw new AuraHandledException(e.getMessage()+' -- '+e.getStackTraceString());
       } 
    }
    
    //Wrapper class: To store case record and its list of child case (wrapper) records.
    public class CaseWrapper{
        @AuraEnabled
        public Case caseInst;
        @AuraEnabled
        public List<CaseWrapper> childCases;
    }
    
}