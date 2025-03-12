@isTest
public with sharing class LeadTriggerHandlerTest {

    private static final List<String> TITLE_LIST = new List<String> {
        'vp', 'v.p.', 'vice president', 
        'mgr', 'manage', 'head of department', 
        'exec', 'chief', 'head', 
        'assist', 'deputy', 'jr'
    };

    @testSetup
    static void setup() {        
        List<Lead> leads = new List<Lead>();
        Integer numberOfLeads = 30;
        for (Integer i=0; i<numberOfLeads; i++) {
            leads.add(new Lead(LastName = 'Test Lead ' + i, Company = 'Test Company ' + i));
        }
        insert leads;
    }
    
    @isTest
    private static void testLeadTriggerHandler_handleTitleNormalization() {

        // Set up the titles
        List<String> titles = new List<String>();
        titles.addAll(TITLE_LIST);
        
        List<Lead> leads = [SELECT Id, LastName, Company, Title FROM Lead];

        Integer x = 0; // index for titles
        for (Integer i=0; i<leads.size(); i++) {

            // 0-11, Rotate through the titles
            if (i < titles.size()) {
                x = Math.mod(i, titles.size());  
            }

            // Assign titles based on the index
            if (i < 3) {  
                leads[i].Title = titles[x];  // 0, 1, 2 - for Vice President
            } else if (i < 6) {  
                leads[i].Title = titles[x];  // 3, 4, 5 - for Manager
            } else if (i < 9) {
                leads[i].Title = titles[x];  // 6, 7, 8 - for Executive
            } else if (i < 12) {
                leads[i].Title = titles[x];  // 9, 10, 11 - for Assistant
            } else if (i < 15) {
                leads[i].Title = 'Other';    // 12, 13, 14 - Other
            } else {
                leads[i].Title = null;       // the rest is null
            }
        }

        update leads;

        Test.startTest();
        LeadTriggerHandler.handleTitleNormalization(leads);        
        Test.stopTest();

        for (Integer i=0; i<leads.size(); i++) {
            if (i < 3) {
                Assert.areEqual('Vice President', leads[i].Title, 'Expected Title to be Vice President');
            } else if (i < 6) {
                Assert.areEqual('Manager', leads[i].Title, 'Expected Title to be Manager');
            } else if (i < 9) {
                Assert.areEqual('Executive', leads[i].Title, 'Expected Title to be Executive');
            } else if (i < 12) {
                Assert.areEqual('Assistant', leads[i].Title, 'Expected Title to be Assistant');
            } else if (i < 15) {
                Assert.areEqual('Other', leads[i].Title, 'Expected Title to be Other');
            } else {
                Assert.areEqual(null, leads[i].Title, 'Expected Title to be null');
            }
        }

        for (Lead lead : leads) {
            System.debug('Lead: ' + lead);
        }
        System.debug('leads.size() >>' + leads.size());
    }  


    @isTest
    private static void testLeadTriggerHandler_handleAutoLeadScoring() {

        List<Lead> leads = [SELECT Id, LastName, Company, Title, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead];

        for (Integer i=0; i<leads.size(); i++) {
            if (i < 3) {  // 18
                leads[i].LeadSource = 'Web';
                leads[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leads[i].Phone = '123456789' + i;
                leads[i].Industry = 'Technology';
            } else if (i < 6) {  // 15
                leads[i].Industry = 'Technology';
                leads[i].Phone = '123456789' + i;
            } else if (i < 9) {  // 13
                leads[i].LeadSource = 'Web';
                leads[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leads[i].Industry = 'Technology';
            } else if (i < 12) { // 10
                leads[i].Industry = 'Technology';
            } else if (i < 15) { // 8
                leads[i].LeadSource = 'Web';
                leads[i].Email = 'lead' + i + '@testcompany' + i + '.com';
                leads[i].Phone = '12345678' + i;
            } else if (i < 18) { // 5
                leads[i].Phone = '12345678' + i;                
            } else if (i < 21) { // 3
                leads[i].LeadSource = 'Web';
                leads[i].Email = 'lead' + i + '@testcompany' + i + '.com';
            }
        }

        update leads;

        Test.startTest();
        LeadTriggerHandler.handleAutoLeadScoring(leads);
        Test.stopTest();

        leads = [SELECT Id, LastName, Title, Company, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead];

        // Assertions
        for (Integer i=0; i<leads.size(); i++) {
            if (i < 3) {
                System.assertEquals(18, leads[i].Lead_Score__c);
            } else if (i < 6) {
                System.assertEquals(15, leads[i].Lead_Score__c);
            } else if (i < 9) {
                System.assertEquals(13, leads[i].Lead_Score__c);
            } else if (i < 12) {
                System.assertEquals(10, leads[i].Lead_Score__c);
            } else if (i < 15) {
                System.assertEquals( 8, leads[i].Lead_Score__c);
            } else if (i < 18) {
                System.assertEquals( 5, leads[i].Lead_Score__c);
            } else if (i < 21) {
                System.assertEquals( 3, leads[i].Lead_Score__c);
            } else {
                System.assertEquals( 0, leads[i].Lead_Score__c);
            }
        }

        for (Lead lead : [SELECT Id, LastName, Company, Title, LeadSource, Email, Phone, Industry, Lead_Score__c FROM Lead WHERE Id IN :leads]) {
            System.debug('Lead: ' + lead);
        }
        System.debug('Leads.size() >>' + leads.size());
    }


    @isTest
    private static void testLeadTriggerHandler_handleLeadAutoConvert() {    
        // Test Account
        Account acc = TestDataFactory.createAccount('Test Account');
        insert acc;  // insert is here
        
        // Test Contact with the same email as the Lead
        TestDataFactory.createContact(acc.Id, 'testcontact@example.com', true);  // while here, insert (true) is on the TestDataFactory

        // Create a new Lead, email not matching contact yet
        Integer numberOfLeads = 400;
        List<Lead> leads = TestDataFactory.createLeads(numberOfLeads, 'testcontact@example.com', false);

        Test.startTest();        
        insert leads;
        Test.stopTest();

        // Query the lead again to check if it was converted
        Lead[] convertedLeads = [SELECT Id, IsConverted, Email FROM Lead WHERE Id IN :leads];

        Assert.isTrue(convertedLeads.size() ==  numberOfLeads, 'Lead should be converted.');
        
        for (Lead lead : convertedLeads) {
            Assert.isTrue(lead.IsConverted, 'Lead should be converted.');
            System.debug('Lead: ' + lead);
        }
        System.debug('convertedLeads.size() >> ' + convertedLeads.size());
    }
}