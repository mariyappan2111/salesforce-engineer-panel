public with sharing class ContactAddressValidationResponseWrapper {
    @AuraEnabled public Boolean success;
    @AuraEnabled public String message;
    @AuraEnabled public String errorMessage;
    @AuraEnabled public Integer totalProcessed;
    @AuraEnabled public Integer validCount;
    @AuraEnabled public Integer invalidCount;
    @AuraEnabled public List<ContactValidationResult> results;
    
    public ContactAddressValidationResponseWrapper() {
        this.success = false;
        this.totalProcessed = 0;
        this.validCount = 0;
        this.invalidCount = 0;
        this.results = new List<ContactValidationResult>();
    }

    public class ContactValidationResult {
        @AuraEnabled public String contactId;
        @AuraEnabled public String contactName;
        @AuraEnabled public Boolean isValid;
        @AuraEnabled public String originalAddress;
        @AuraEnabled public String validatedAddress;
        @AuraEnabled public Decimal confidence;
        @AuraEnabled public String errorMessage;
    }
}