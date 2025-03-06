@isTest
public with sharing class LeadTriggerHandlerTest {
    
    @isTest
    private static void testLeadTriggerHandler_handleTitleNormalization_insert() {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1', Title = 'vp'),
            new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2', Title = 'v.p.'),
            new Lead(LastName = 'Test Lead 3', Company = 'Test Company 3', Title = 'vice president'),
            new Lead(LastName = 'Test Lead 4', Company = 'Test Company 4', Title = 'mgr'),
            new Lead(LastName = 'Test Lead 5', Company = 'Test Company 5', Title = 'manage'),
            new Lead(LastName = 'Test Lead 6', Company = 'Test Company 6', Title = 'head of department'),
            new Lead(LastName = 'Test Lead 7', Company = 'Test Company 7', Title = 'exec'),
            new Lead(LastName = 'Test Lead 8', Company = 'Test Company 8', Title = 'chief'),
            new Lead(LastName = 'Test Lead 9', Company = 'Test Company 9', Title = 'head'),
            new Lead(LastName = 'Test Lead A', Company = 'Test Company A', Title = 'assist'),
            new Lead(LastName = 'Test Lead B', Company = 'Test Company B', Title = 'deputy'),
            new Lead(LastName = 'Test Lead C', Company = 'Test Company C', Title = 'jr'),
            new Lead(LastName = 'Test Lead C', Company = 'Test Company C')
        };

        insert leads;
        
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();
        
        System.assertEquals('Vice President', leads[0].Title);
        System.assertEquals('Vice President', leads[1].Title);
        System.assertEquals('Vice President', leads[2].Title);
        System.assertEquals('Manager', leads[3].Title);
        System.assertEquals('Manager', leads[4].Title);
        System.assertEquals('Manager', leads[5].Title);
        System.assertEquals('Executive', leads[6].Title);
        System.assertEquals('Executive', leads[7].Title);
        System.assertEquals('Executive', leads[8].Title);
        System.assertEquals('Assistant', leads[9].Title);
        System.assertEquals('Assistant', leads[10].Title);
        System.assertEquals('Assistant', leads[11].Title);
        System.assertEquals(null, leads[12].Title);

        for (Lead lead : leads) {
            System.debug('Lead: ' + lead);
        }        
    }  
}