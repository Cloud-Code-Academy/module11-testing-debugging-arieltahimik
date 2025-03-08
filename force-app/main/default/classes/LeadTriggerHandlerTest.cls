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
        
        System.assertEquals('Vice President', leads[0].Title, 'Expected Title to be Vice President');
        System.assertEquals('Vice President', leads[1].Title, 'Expected Title to be Vice President');
        System.assertEquals('Vice President', leads[2].Title, 'Expected Title to be Vice President');
        System.assertEquals('Manager', leads[3].Title, 'Expected Title to be Manager');
        System.assertEquals('Manager', leads[4].Title, 'Expected Title to be Manager');
        System.assertEquals('Manager', leads[5].Title, 'Expected Title to be Manager');
        System.assertEquals('Executive', leads[6].Title, 'Expected Title to be Executive');
        System.assertEquals('Executive', leads[7].Title, 'Expected Title to be Executive');
        System.assertEquals('Executive', leads[8].Title, 'Expected Title to be Executive');
        System.assertEquals('Assistant', leads[9].Title, 'Expected Title to be Assistant');
        System.assertEquals('Assistant', leads[10].Title, 'Expected Title to be Assistant');
        System.assertEquals('Assistant', leads[11].Title, 'Expected Title to be Assistant');
        System.assertEquals(null, leads[12].Title, 'Expected Title to be null');

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
            new Lead(LastName = 'Test Lead 1', Company = 'Test Company 1', Phone = '8887777777', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 2', Company = 'Test Company 2', LeadSource = 'Web', Email = 'lead2@testcompany2.com', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 3', Company = 'Test Company 3', Industry = 'Technology'),
            new Lead(LastName = 'Test Lead 4', Company = 'Test Company 4', LeadSource = 'Web', Email = 'lead4@testcompany4.com', Phone = '5678901234'),
            new Lead(LastName = 'Test Lead 5', Company = 'Test Company 5', Phone = '5678901234'),
            new Lead(LastName = 'Test Lead 6', Company = 'Test Company 6', LeadSource = 'Web', Email = 'lead7@testcompany7.com'),
            new Lead(LastName = 'Test Lead 7', Company = 'Test Company 7')
        };

        insert leads;

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        System.assertEquals(18, leads[0].Lead_Score__c);
        System.assertEquals(15, leads[1].Lead_Score__c);
        System.assertEquals(13, leads[2].Lead_Score__c);
        System.assertEquals(10, leads[3].Lead_Score__c);
        System.assertEquals( 8, leads[4].Lead_Score__c);
        System.assertEquals( 5, leads[5].Lead_Score__c);
        System.assertEquals( 3, leads[6].Lead_Score__c);
        System.assertEquals( 0, leads[7].Lead_Score__c);

        for (Lead lead : [SELECT Id, LastName, Company, Title, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads]) {
            System.debug('Lead: ' + lead);
        }
    }

    @isTest
    private static void testLeadTriggerHandler_handleAutoLeadScoring_update() {
        List<Lead> leads = new List<Lead>{
            new Lead(LastName = 'Test Lead 0', Company = 'Test Company 0'), 
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
            new Lead(LastName = 'Test Lead D', Company = 'Test Company D'),
            new Lead(LastName = 'Test Lead E', Company = 'Test Company E'),
            new Lead(LastName = 'Test Lead F', Company = 'Test Company F'),
            new Lead(LastName = 'Test Lead G', Company = 'Test Company G'),
            new Lead(LastName = 'Test Lead H', Company = 'Test Company H'),
            new Lead(LastName = 'Test Lead I', Company = 'Test Company I'),
            new Lead(LastName = 'Test Lead J', Company = 'Test Company J'),
            new Lead(LastName = 'Test Lead K', Company = 'Test Company K'),
            new Lead(LastName = 'Test Lead L', Company = 'Test Company L'),
            new Lead(LastName = 'Test Lead M', Company = 'Test Company M'),
            new Lead(LastName = 'Test Lead N', Company = 'Test Company N')
        };
        insert leads;

        List<Lead> leadsToUpdate = [SELECT Id, LeadSource, Email, Phone, Industry, Title, Lead_Score__c FROM Lead WHERE Id IN :leads];

        for (Integer i=0; i<leadsToUpdate.size(); i++) {
            if (i < 3) {  // 18
                leadsToUpdate[i].LeadSource = 'Web';
                leadsToUpdate[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leadsToUpdate[i].Phone = '123456789' + i;
                leadsToUpdate[i].Industry = 'Technology';
            } else if (i < 6) {  // 15
                leadsToUpdate[i].Industry = 'Technology';
                leadsToUpdate[i].Phone = '123456789' + i;
            } else if (i < 9) {  // 13
                leadsToUpdate[i].LeadSource = 'Web';
                leadsToUpdate[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leadsToUpdate[i].Industry = 'Technology';
            } else if (i < 12) { // 10
                leadsToUpdate[i].Industry = 'Technology';
            } else if (i < 15) { // 8
                leadsToUpdate[i].LeadSource = 'Web';
                leadsToUpdate[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leadsToUpdate[i].Phone = '12345678' + i;
            } else if (i < 18) { // 5
                leadsToUpdate[i].Phone = '12345678' + i;                
            } else if (i < 21) { // 3
                leadsToUpdate[i].LeadSource = 'Web';
                leadsToUpdate[i].Email = 'lead' + i + '@testcompany' + i + '.com';
            }
        }
        update leadsToUpdate;

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leadsToUpdate);
        Test.stopTest();

        leadsToUpdate = [SELECT Id, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads];

        System.assertEquals(24, leadsToUpdate.size(), 'Expected 24 leads to be updated');
        for (Integer i=0; i<leadsToUpdate.size(); i++) {
            if (i < 3) {
                System.assertEquals(18, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 6) {
                System.assertEquals(15, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 9) {
                System.assertEquals(13, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 12) {
                System.assertEquals(10, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 15) {
                System.assertEquals( 8, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 18) {
                System.assertEquals( 5, leadsToUpdate[i].Lead_Score__c);
            } else if (i < 21) {
                System.assertEquals( 3, leadsToUpdate[i].Lead_Score__c);
            } else {
                System.assertEquals( 0, leadsToUpdate[i].Lead_Score__c);
            }
            
        }

        for (Lead lead : [SELECT Id, LastName, Company, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads]) {                         
            System.debug('Lead: ' + lead);
        }
    }
}