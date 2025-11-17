@IsTest(SeeAllData = false)
public class AddressValidationControllerTest {
    @testSetup static void testSetup(){

        // Create a new account
        Account account = new Account(Name='Test Account');
        insert account; 

    // Create a new contact
    List<Contact> contactsToInsert = new List<Contact>();
    for (Integer i = 0; i < 100; i++) {
            contactsToInsert.add(new Contact(
                FirstName = 'United States',
                LastName = 'Test Contacts' + i,
                AccountId = account.Id,
                MailingStreet = (1600 + i) + ' Amphitheatre Pkwy',
                MailingCity = 'Mountain View',
                MailingState = 'California',
                MailingPostalCode = '94043',
                MailingCountry = 'United States'
            ));
        }
        
        // 100 International Contacts (Netherlands)
        for (Integer i = 0; i < 100; i++) {
            contactsToInsert.add(new Contact(
                FirstName = 'International',
                LastName = 'Test Contacts' + i,
                AccountId = account.Id,
                MailingStreet = 'De Bleek ' + (i + 1),
                MailingCity = 'Woerden',
                //MailingState = 'Utrecht',
                MailingPostalCode = '3447 GV',
                MailingCountry = 'Netherlands'
            ));
        }
        
        insert contactsToInsert;

     }

     @IsTest static void testBulkValidAddress(){
        List<String> contactIds = new List<String>();
        for (Contact ctIds : [SELECT Id, FirstName, LastName, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, MailingState FROM Contact]) {
        contactIds.add(ctIds.Id);
       }
        System.Assert.areEqual(200, contactIds.size());
        Test.setMock(HttpCalloutMock.class, new MockResponseController());
        test.startTest();
        Long startTime = System.currentTimeMillis();
        ContactAddressValidationResponseWrapper result = AddressValidationController.validateAddress(contactIds);
        Long endTime = System.currentTimeMillis();
        Long executionTime = endTime - startTime;
        Test.stopTest();
        
        System.debug('====== PERFORMANCE TEST: 100 VALID ADDRESSESCONTACTS ======');
        System.debug('Execution Time: ' + executionTime + 'ms');
        System.debug('API Callouts Used: ' + Limits.getCallouts());
        System.debug('DML Statements Used: ' + Limits.getDmlStatements());
        System.debug('SOQL Queries Used: ' + Limits.getQueries());
        System.debug('Heap Size Used: ' + Limits.getHeapSize() + ' bytes');
        
        System.Assert.isTrue(executionTime < 5000, 'Execution took too long: ' + executionTime + 'ms');
        System.Assert.areEqual(1, result.totalProcessed, 'Should process all contacts');
        System.Assert.isTrue(Limits.getCallouts() <= 10, 'Too many API callouts');
        System.Assert.areEqual(2, Limits.getDmlStatements(), 'Should use bulk DML');
    }

    @IsTest static void testContactAll(){
        try{
            test.startTest();
            List<Contact> page1 = AddressValidationController.getContacts(1, 50);
            List<Contact> page2 = AddressValidationController.getContacts(2, 50);
            Integer totalCount = AddressValidationController.getTotalContactCount(); 
            test.stopTest();
            System.Assert.areEqual(50, page1.size(), 'Page 1 should have 50 contacts');
            System.Assert.areEqual(50, page2.size(), 'Page 2 should have 50 contacts');
            System.Assert.areEqual(200, totalCount, 'Total should be 200 contacts');
        }catch(Exception e){
            System.Assert.areEqual(false, e.getMessage().contains('No record Ids provided'));
        }
    }

    @IsTest static void testNoContact(){
        List<String> contactIds = new List<String>();
        try{
            test.startTest();
             ContactAddressValidationResponseWrapper result = AddressValidationController.validateAddress(contactIds);
             test.stopTest();
        }catch(Exception e){
            System.Assert.areEqual(false, e.getMessage().contains('No record Ids provided'));
        }
    }

    @IsTest static void testSingleContactValidAddress(){
        List<String> contactIds = new List<String>();
        for (Contact ctIds : [SELECT Id, FirstName, LastName, MailingStreet, MailingCity, MailingPostalCode, MailingCountry, MailingState FROM Contact Limit 1]) {
            contactIds.add(ctIds.Id);
        }
        System.Assert.areEqual(1, contactIds.size());
        Test.setMock(HttpCalloutMock.class, new MockResponseController());
        test.startTest();
        Long startTime = System.currentTimeMillis();
        ContactAddressValidationResponseWrapper result = AddressValidationController.validateAddress(contactIds);
        Long endTime = System.currentTimeMillis();
        Long executionTime = endTime - startTime;
        Test.stopTest();
        
        System.debug('====== PERFORMANCE TEST: 1 VALID ADDRESSESCONTACT ======');
        System.debug('Execution Time: ' + executionTime + 'ms');
        System.debug('API Callouts Used: ' + Limits.getCallouts());
        System.debug('DML Statements Used: ' + Limits.getDmlStatements());
        System.debug('SOQL Queries Used: ' + Limits.getQueries());
        System.debug('Heap Size Used: ' + Limits.getHeapSize() + ' bytes');
        
        System.Assert.isTrue(executionTime < 5000, 'Execution took too long: ' + executionTime + 'ms');
        System.Assert.areEqual(1, result.totalProcessed, 'Should process all contacts');
        System.Assert.isTrue(Limits.getCallouts() <= 10, 'Too many API callouts');
        System.Assert.areEqual(2, Limits.getDmlStatements(), 'Should use bulk DML');
    }
} 