/*
 * Created By: Bhagabat Sahoo
 * Created Date: 17th April, 2024
 * Description: Test class for CaseHierarchyController apex class.
 */
@isTest
public class CaseHierarchyControllerTest {

    @testSetup
    public static void createTestData(){
        Case parent1 = new Case();
        parent1.Origin = 'Web';
        parent1.Subject = 'Test Parent 1';
        insert parent1;
        
        Case child1 = new Case();
        child1.Origin = 'Web';
        child1.Subject = 'Test Child 1';
        child1.ParentId = parent1.Id;
        insert child1;
        
        Case child2 = new Case();
        child2.Origin = 'Web';
        child2.Subject = 'Test Child 2';
        child2.ParentId = child1.Id;
        insert child2;
    }
    
    @isTest
    public static void testMethod1(){
        Case cs  = [SELECT Id FROM Case WHERE Subject='Test Parent 1' LIMIT 1];
        CaseHierarchyController.CaseWrapper wrp = CaseHierarchyController.getChildCases(cs.Id);
        
        system.assert(wrp.childCases.size()>0);
    }
}