/*
    TestDataFactory class is a utility class that provides methods to create test data for unit tests.
    This class is used to create test data for Account and Contact objects.
    You can supply additional data/field needed as parameters to create an Account and Contact object.
*/

public with sharing class TestDataFactory {

    public static Account createAccount(String name) {
        Account account = new Account();
        account.Name = name;
        account.Industry = 'Technology';
        account.Type = 'Customer - Direct';
        return account;
    }

    public static Contact createContact(Id accountId, String email, Boolean doInsert) {
        Contact contact = new Contact();
        contact.AccountId = accountId;
        contact.Email = email;
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Fax = '123-456-7890';  // example only, add fields as needed
        if (doInsert) {
            insert contact;
        }
        return contact;
    }

    // Bulk create leads with the same email
    public static List<Lead> createLeads(Integer numLeads, String email, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for (Integer i=0; i<numLeads; i++) {
            Lead lead = createLead(email, false);
            leads.add(lead);
        }
        if (doInsert) {
            insert leads;
        }
        return leads;
    }

    public static Lead createLead(String email, Boolean doInsert) {
        Lead lead = new Lead();
        lead.Email = email;
        lead.FirstName = 'Test';
        lead.LastName = 'Lead';
        lead.Company = 'Test Company';
        return lead;
    }
}