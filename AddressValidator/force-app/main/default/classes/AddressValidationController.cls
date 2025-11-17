public with sharing class AddressValidationController {
   
    @AuraEnabled
    public static ContactAddressValidationResponseWrapper validateAddress(List<String> recordIds) {
        ContactAddressValidationResponseWrapper responseCT = new ContactAddressValidationResponseWrapper();
        if(recordIds == null && recordIds.isEmpty()){
            responseCT.message = System.Label.No_record_Ids_provided;
            responseCT.success = false;
            return responseCT;
        }

        if(!Schema.sObjectType.Contact.isAccessible() || !Schema.sObjectType.Contact.isUpdateable()){
            responseCT.message = System.Label.No_access_to_Contact_object;
            responseCT.success = false;
            return responseCT;
        }

        List<Contact> contacts = [ SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, AddressValid__c FROM Contact WHERE Id IN :recordIds];
        if (contacts.isEmpty()) {
            responseCT.success = false;
            responseCT.message = System.label.No_contacts_found_with_provided_IDs;
            return responseCT;
        }

        List<AddressWrapper> addressesToValidate = new List<AddressWrapper>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();

        for(Contact contact : contacts){
            if(isValidContactAddress(contact)){
                AddressWrapper address = new AddressWrapper(contact.Id, contact.MailingStreet,  contact.MailingCity, contact.MailingState, contact.MailingPostalCode, contact.MailingCountry, null, null, null, null, null);
                addressesToValidate.add(address);
                contactMap.put(contact.Id, contact);
            }
        }
        if (addressesToValidate.isEmpty()) {
                responseCT.success = false;
                responseCT.message = System.label.No_contacts_have_valid_address_fields_to_validate;
                return responseCT;
        }

        // Get the Wrapper by country name
        Map<String, List<AddressWrapper>> addressesByCountry = new Map<String, List<AddressWrapper>>();
        for(AddressWrapper address: addressesToValidate){
            String countryName = contactMap.get(address.recordId).MailingCountry;
            if(!addressesByCountry.containsKey(countryName)){
                addressesByCountry.put(countryName, new List<AddressWrapper>{});
            }
            addressesByCountry.get(countryName).add(address);
        }

        List<AddressValidationResultWrapper> allResults = new List<AddressValidationResultWrapper>();
        // Automatically gets US or International provider based on country
        for (String country : addressesByCountry.keySet()) {
            IIntegrationsServiceProvider serviceProvider = AddressValidationProviderFT.getServiceProvider(country);
            List<AddressWrapper> countryAddresses = addressesByCountry.get(country);
            List<AddressValidationResultWrapper> countryResults = serviceProvider.validateAddresses(countryAddresses);
            allResults.addAll(countryResults);
        }

        List<ContactAddressValidationResponseWrapper.ContactValidationResult> validationResults = new List<ContactAddressValidationResponseWrapper.ContactValidationResult>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Integer validCount = 0;
        Integer invalidCount = 0; 
        for(AddressValidationResultWrapper result : allResults){
            ContactAddressValidationResponseWrapper.ContactValidationResult validationResult = new ContactAddressValidationResponseWrapper.ContactValidationResult();
            if(contactMap.containsKey(result.recordId)){
                Contact contact = contactMap.get(result.recordId);
                validationResult.contactId = contact.Id;
                validationResult.contactName = contact.Name;
                validationResult.isValid = result.isValid;
                if(result.isValid){
                    contact.AddressValid__c = true;
                    validCount++;
                }else{
                    contact.AddressValid__c = false;
                    invalidCount++;
                }
                validationResults.add(validationResult);
                contactsToUpdate.add(contact);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            Database.SaveResult[] saveResults = Database.update(contactsToUpdate, false);
            for (Integer i = 0; i < saveResults.size(); i++) {
                if (!saveResults[i].isSuccess()) {
                    validationResults[i].errorMessage = 'Update failed: ' +  saveResults[i].getErrors()[0].getMessage();
                }
            }
        }
        responseCT.totalProcessed = contactsToUpdate.size();
        responseCT.validCount = validCount;
        responseCT.invalidCount = invalidCount;
        responseCT.results = validationResults;
        return responseCT;
    }

    private static Boolean isValidContactAddress(Contact contact){
        return (contact.MailingStreet != null && contact.MailingCity != null && contact.MailingState != null && contact.MailingPostalCode != null && contact.MailingCountry != null);
    }

    @AuraEnabled
    public static List<Contact> getContacts(Integer pageNumber, Integer pageSize){
        try {
            if(!Schema.sObjectType.Contact.isAccessible()){
                return null;
            }
            Integer offset = (pageNumber - 1) * pageSize;
            return [ SELECT Id, Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, AddressValid__c FROM Contact ORDER BY AddressValid__c DESC LIMIT :pageSize OFFSET :offset]; 
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getTotalContactCount(){
        try {
            if(!Schema.sObjectType.Contact.isAccessible()){
                return 0;
            }
            return [SELECT COUNT() FROM Contact];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}