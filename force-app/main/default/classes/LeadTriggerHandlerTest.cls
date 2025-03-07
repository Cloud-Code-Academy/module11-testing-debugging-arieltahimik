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
            new Lead(LastName = 'Test Lead D', Company = 'Test Company D')
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

    @isTest
    private static void testLeadTriggerHandler_handleTitleNormalization_update() {
        
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1'),
            new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2'),
            new Lead(LastName = 'Test Lead 3', Company = 'Test Company 3'),
            new Lead(LastName = 'Test Lead 4', Company = 'Test Company 4'),
            new Lead(LastName = 'Test Lead 5', Company = 'Test Company 5'),
            new Lead(LastName = 'Test Lead 6', Company = 'Test Company 6'),
            new Lead(LastName = 'Test Lead 7', Company = 'Test Company 7'),
            new Lead(LastName = 'Test Lead 8', Company = 'Test Company 8'),
            new Lead(LastName = 'Test Lead 9', Company = 'Test Company 9'),
            new Lead(LastName = 'Test Lead A', Company = 'Test Company A'),
            new Lead(LastName = 'Test Lead B', Company = 'Test Company B'),
            new Lead(LastName = 'Test Lead C', Company = 'Test Company C'),
            new Lead(LastName = 'Test Lead D', Company = 'Test Company D')
        };

        insert leads;

        List<Lead> leadsToUpdate = [SELECT Id, Title FROM Lead WHERE Id IN :leads];

        for (Integer i=0; i<leadsToUpdate.size(); i++) {
            if (i < 3) {
                leadsToUpdate[i].Title = 'vp';
            } else if (i < 6) {
                leadsToUpdate[i].Title = 'mgr';
            } else if (i < 9) {
                leadsToUpdate[i].Title = 'exec';
            } else if (i < 12) {
                leadsToUpdate[i].Title = 'assist';
            } else {
                leadsToUpdate[i].Title = null;
            }
        }

        update leadsToUpdate;
        
        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);
        Test.stopTest();

        List<Lead> vpLeads = [SELECT Id, Title FROM Lead WHERE Id IN :leadsToUpdate AND Title = 'Vice President'];
        System.assertEquals(3, vpLeads.size(), 'Expected 3 leads to be updated to Vice President');

        List<Lead> mgrLeads = [SELECT Id, Title FROM Lead WHERE Id IN :leadsToUpdate AND Title = 'Manager'];
        System.assertEquals(3, mgrLeads.size(), 'Expected 3 leads to be updated to Manager');

        List<Lead> execLeads = [SELECT Id, Title FROM Lead WHERE Id IN :leadsToUpdate AND Title = 'Executive'];
        System.assertEquals(3, execLeads.size(), 'Expected 3 leads to be updated to Executive');

        List<Lead> astLeads = [SELECT Id, Title FROM Lead WHERE Id IN :leadsToUpdate AND Title = 'Assistant'];
        System.assertEquals(3, astLeads.size(), 'Expected 3 leads to be updated to Assistant');

        List<Lead> nulLeads = [SELECT Id, Title FROM Lead WHERE Id IN :leadsToUpdate AND Title = null];
        System.assertEquals(1, nulLeads.size(), 'Expected 1 lead to be null');

        leadsToUpdate = [SELECT Id, Title FROM Lead WHERE Id IN :leads];
        for (Lead lead : leadsToUpdate) {
            System.debug('Lead: ' + lead);
        }        
    }

    @isTest
    private static void testLeadTriggerHandler_handleAutoLeadScoring_insert() {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test Lead 0', Company = 'Test Company 0', LeadSource = 'Web', Email = 'lead0@testcompany0.com', Phone = '1234567890', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1', LeadSource = 'Web', Email = 'lead1@testcompany1.com'),
            new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2', Phone = '1234567890'),
            new Lead(LastName = 'Test Lead 3', Company = 'Test Company 3', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 4', Company = 'Test Company 4', LeadSource = 'Web', Email = 'lead4@testcompany4.com', Phone = '5678901234'),
            new Lead(LastName = 'Test Lead 5', Company = 'Test Company 5', LeadSource = 'Web', Email = 'lead5@testcompany5.com', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 6', Company = 'Test Company 6'),
            new Lead(LastName = 'Test Lead 7', Company = 'Test Company 7', Title = 'vp', LeadSource = 'Web', Email = 'lead7@testcompany7.com', Phone = '8887777777', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 8', Company = 'Test Company 8', Title = 'exec', LeadSource = 'Web', Email = 'lead8@testcompany8.com'),
            new Lead(LastName = 'Test Lead 9', Company = 'Test Company 9', Title = 'mgr', Phone = '8888888888'),
            new Lead(LastName = 'Test Lead A', Company = 'Test Company A', Title = 'jr', Industry = 'Technology')

        };

        insert leads;

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        System.assertEquals(18, leads[0].Lead_Score__c);
        System.assertEquals( 3, leads[1].Lead_Score__c);
        System.assertEquals( 5, leads[2].Lead_Score__c);
        System.assertEquals(10, leads[3].Lead_Score__c);
        System.assertEquals( 8, leads[4].Lead_Score__c);
        System.assertEquals(13, leads[5].Lead_Score__c);
        System.assertEquals( 0, leads[6].Lead_Score__c);
        System.assertEquals(18, leads[7].Lead_Score__c);

        Lead l = [SELECT Id, Title FROM Lead WHERE Id = :leads[6].Id LIMIT 1];
        System.assertEquals(null, l.Title);
        
        Lead vp = [SELECT Id, Title FROM Lead WHERE Id = :leads[7].Id LIMIT 1];
        System.assertEquals('Vice President', vp.Title);

        Lead exec = [SELECT Id, Title FROM Lead WHERE Id = :leads[8].Id LIMIT 1];
        System.assertEquals('Executive', exec.Title);

        Lead mgr = [SELECT Id, Title FROM Lead WHERE Id = :leads[9].Id LIMIT 1];
        System.assertEquals('Manager', mgr.Title);

        Lead jr = [SELECT Id, Title FROM Lead WHERE Id = :leads[10].Id LIMIT 1];
        System.assertEquals('Assistant', jr.Title);

        for (Lead lead : [SELECT Id, LastName, Company, Title, Website, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads]) {
            System.debug('Lead: ' + lead);
        }
    }
}