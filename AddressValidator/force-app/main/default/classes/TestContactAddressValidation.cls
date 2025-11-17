@IsTest
public class TestContactAddressValidation {
	@IsTest
    public static void testValidAddressUS() {
        Contact contact = new Contact(LastName='Doe', FirstName='Joe', MailingStreet='1428 Post Aly', MailingCity='Seattle', MailingPostalCode='98101', MailingCountry='United States', MailingState='Washington');
        insert contact;
        Test.startTest();
        Long startTime = System.currentTimeMillis();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockValidAddressUS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Long endTime = System.currentTimeMillis();
        Long executionTime = endTime - startTime;
        contact = ContactAddressValidation.validateAddress(contact.Id);
        Test.stopTest();

        System.debug('====== PERFORMANCE TEST: 100 VALID ADDRESSESCONTACTS ======');
        System.debug('Execution Time: ' + executionTime + 'ms');
        System.debug('API Callouts Used: ' + Limits.getCallouts());
        System.debug('DML Statements Used: ' + Limits.getDmlStatements());
        System.debug('SOQL Queries Used: ' + Limits.getQueries());
        System.debug('Heap Size Used: ' + Limits.getHeapSize() + ' bytes');
        
    }
    
    @IsTest
    public static void testValidAddressITL() {
        Contact contact = new Contact(LastName='Doe', FirstName='John', MailingStreet='De Bleek 7', MailingCity='Woerden', MailingPostalCode='3447 GV', MailingCountry='Netherlands');
        insert contact;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockValidAddressITL');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        contact = ContactAddressValidation.validateAddress(contact.Id);
        Test.stopTest();
        
        Assert.areEqual(true, contact.AddressValid__c);
    }
    
    @IsTest
    public static void testInvalidAddressUS() {
        Contact contact = new Contact(LastName='Doe', FirstName='Joe', MailingStreet='Teststraat 1', MailingCity='Teststad', MailingPostalCode='1234 QA', MailingCountry='United States', MailingState='Washington');
        insert contact;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockInvalidAddressUS');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        contact = ContactAddressValidation.validateAddress(contact.Id);
        Test.stopTest();
        
        Assert.areEqual(false, contact.AddressValid__c);
    }
    
    @IsTest
    public static void testInvalidAddressITL() {
        Contact contact = new Contact(LastName='Doe', FirstName='Joe', MailingStreet='Teststraat 1', MailingCity='Teststad', MailingPostalCode='1234 QA', MailingCountry='Netherlands');
        insert contact;
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MockInvalidAddressITL');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        contact = ContactAddressValidation.validateAddress(contact.Id);
        Test.stopTest();
        
        Assert.areEqual(false, contact.AddressValid__c);
    }
} 