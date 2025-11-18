public class SmartyAPIServiceProvider implements IIntegrationsServiceProvider{
    private API_Service_Providers__mdt apiConfiguration; // Provider configuration record
    private static final String SINGLE_ADDRESS_ENDPOINT = System.label.Default_Smarty_Address_End_point;
    private static final String BATCH_ADDRESS_ENDPOINT = System.label.Default_Smarty_Batch_Adress_Endpoint;
    private static final Integer DEFAULT_BATCH_SIZE = Integer.valueOf(System.label.Default_Batch_Size);
    private static final String PROVIDER_NAME = System.label.API_Provider_Name;

    public SmartyAPIServiceProvider() {
        this.apiConfiguration = AddressValidationProviderFT.getActiveProvider();

        // Enable this section to maintain the custoservice for particular time
        // can be worked start and End Date
        // sample code
        // if (apiConfiguration.Start_Date__c != null && apiConfiguration.End_Date__c != null) {
        //     Date today = Date.today();
        //     if (today < apiConfiguration.Start_Date__c || today > apiConfiguration.End_Date__c) {
        //         throw new AuraHandledException('Provider configuration is not active for today.');
        //     }
        // }
    }

    public String getServiceProvider() {
        return PROVIDER_NAME;
    }

    public List<AddressValidationResultWrapper> validateAddresses(List<AddressWrapper> addresses) {
        List<AddressValidationResultWrapper> results = new List<AddressValidationResultWrapper>();
        if (addresses == null || addresses.isEmpty()) {
                return results;
        }
        Integer batchSize = apiConfiguration.Service_Batch_Size__c != null ? Integer.valueOf(apiConfiguration.Service_Batch_Size__c) : DEFAULT_BATCH_SIZE;
        
        for (Integer i = 0; i < addresses.size(); i += batchSize) { // Set the batch size
            Integer endIndex = Math.min(i + batchSize, addresses.size());
            List<AddressWrapper> addressList = new List<AddressWrapper>();
            for (Integer j = i; j < endIndex; j++) {
                addressList.add(addresses[j]);
            }
            if (addressList.size() == 1) { // Added a check to see if the batch size is 1, if so, call the single address endpoint
                results.addAll(validateSingleAddress(addressList[0]));
            } else { // Otherwise, call the batch endpoint
                results.addAll(validateBulkAddress(addressList));
            }
        }
        return results;
    }

    private List<AddressValidationResultWrapper> validateSingleAddress(AddressWrapper address) {
        try {
            String endpoint = buildSingleAddressEndpoint(address);
            HttpResponse response = HttpCalloutBase.sendRequest(endpoint, 'GET', new Map<String, String>{'Content-Type' => 'application/json'}, Integer.valueOf(apiConfiguration.Timeout_Threshold__c));
            HttpCalloutBase.checkResponse(response, getServiceProvider()); // Validate the response
            return parseResponse(response.getBody(), new List<AddressWrapper>{address}); // Parse the response
        } catch (Exception e) {
            return handleError(new List<AddressWrapper>{address}, e.getMessage());
        }
    }

    private List<AddressValidationResultWrapper> validateBulkAddress(List<AddressWrapper> bulkAddressList) {
        try {
            String endpoint = buildBulkAddressEndpoint();
            String requestBody = buildBulkAddressRequest(bulkAddressList);
            HttpResponse response = HttpCalloutBase.sendRequest(endpoint, 'POST', requestBody, new Map<String, String>{'Content-Type' => 'application/json'}, Integer.valueOf(apiConfiguration.Timeout_Threshold__c));
            HttpCalloutBase.checkResponse(response, getServiceProvider()); // Validate the response
            return parseResponse(response.getBody(), bulkAddressList); // Parse the response
        } catch (Exception e) {
            return handleError(bulkAddressList, e.getMessage());
        }
    }
    // this method will be enabled when using named Crdentials with multiple providers
    // psuedo code
    // private String buildBulkAddressEndpoint() {
    //    return 'callout:' + apiConfiguration.API_Credential_Name__c + SINGLE_ADDRESS_ENDPOINT;
    // }

    private String buildBulkAddressEndpoint() {
        return apiConfiguration.API_End_Point_Url__c + SINGLE_ADDRESS_ENDPOINT + '?auth-id=' + apiConfiguration.Auth_ID__c + '&auth-token=' + apiConfiguration.Auth_token__c;
    }

    private String buildSingleAddressEndpoint(AddressWrapper address) {
        // String endpoint = 'callout:' + apiConfiguration.API_Credential_Name__c + SINGLE_ADDRESS_ENDPOINT + '?';  // Base URL    
        //this above line will be enabled when using named Crdentials with multiple providers 
        String endpoint =  apiConfiguration.API_End_Point_Url__c+SINGLE_ADDRESS_ENDPOINT + '?auth-id='+apiConfiguration.Auth_ID__c+'&auth-token='+apiConfiguration.Auth_token__c+'&';  // Base URL     
        List<String> params = new List<String>();  // Add address parameters (URL encoded)
        if (String.isNotBlank(address.street)) {
            params.add('street=' + EncodingUtil.urlEncode(address.street, 'UTF-8'));
        }
        if (String.isNotBlank(address.street2)) {
            params.add('street2=' + EncodingUtil.urlEncode(address.street2, 'UTF-8'));
        }
        if (String.isNotBlank(address.secondary)) {
            params.add('secondary=' + EncodingUtil.urlEncode(address.secondary, 'UTF-8'));
        }
        if (String.isNotBlank(address.city)) {
            params.add('city=' + EncodingUtil.urlEncode(address.city, 'UTF-8'));
        }
        if (String.isNotBlank(address.state)) {
            params.add('state=' + EncodingUtil.urlEncode(address.state, 'UTF-8'));
        }
        if (String.isNotBlank(address.postalCode)) {
            params.add('zipcode=' + EncodingUtil.urlEncode(address.postalCode, 'UTF-8'));
        }
        if (String.isNotBlank(address.lastline)) {
            params.add('lastline=' + EncodingUtil.urlEncode(address.lastline, 'UTF-8'));
        }
        if (address.candidates != null) {
            params.add('candidates=' + address.candidates);
        }
        endpoint += String.join(params, '&');
        return endpoint;
    }

    private String buildBulkAddressRequest(List<AddressWrapper> addressList) {
        List<Map<String, Object>> addreList = new List<Map<String, Object>>();
        for (AddressWrapper addr : addressList) {
            Map<String, Object> addressMap = new Map<String, Object>();
            
            if (String.isNotBlank(addr.inputId)) {
                addressMap.put('input_id', addr.inputId);
            }
            if (String.isNotBlank(addr.street)) {
                addressMap.put('street', addr.street);
            }
            if (String.isNotBlank(addr.street2)) {
                addressMap.put('street2', addr.street2);
            }
            if (String.isNotBlank(addr.secondary)) {
                addressMap.put('secondary', addr.secondary);
            }
            if (String.isNotBlank(addr.city)) {
                addressMap.put('city', addr.city);
            }
            if (String.isNotBlank(addr.state)) {
                addressMap.put('state', addr.state);
            }
            if (String.isNotBlank(addr.postalCode)) {
                addressMap.put('zipcode', addr.postalCode);
            }
            if (String.isNotBlank(addr.lastline)) {
                addressMap.put('lastline', addr.lastline);
            }
            if (addr.candidates != null) {
                addressMap.put('candidates', addr.candidates);
            }
            addreList.add(addressMap);
        }
        return JSON.serialize(addreList);
    }
    // chec the (analysis.dpv_match_code == 'Y') then it is valid address
    private List<AddressValidationResultWrapper> parseResponse(String responseBody, List<AddressWrapper> addressList) {
         List<AddressValidationResultWrapper.AddressResult> results = new List<AddressValidationResultWrapper.AddressResult>();
         results = (List<AddressValidationResultWrapper.AddressResult>) System.JSON.deserialize(responseBody, List<AddressValidationResultWrapper.AddressResult>.class);
        List<AddressValidationResultWrapper> finalResults = new List<AddressValidationResultWrapper>();
            Integer i = 0;
            for (AddressValidationResultWrapper.AddressResult r : results) {
                Integer inputIndex = (r.input_index != null) ? r.input_index : i;
                 AddressWrapper inputAddr = (inputIndex < addressList.size()) ? addressList[inputIndex] : null;
                // Assign the recordIds to the results
                AddressValidationResultWrapper wrapper = new AddressValidationResultWrapper(inputAddr != null ? inputAddr.recordId : null);
                wrapper.isSuccess = true;
                wrapper.isValid = true;
                wrapper.inputIndex = r.input_index;
                wrapper.candidateIndex = r.candidate_index;
                wrapper.results = new List<AddressValidationResultWrapper.AddressResult>{ r };
                finalResults.add(wrapper);
                i++;
            }
         return finalResults;
    }

    private List<AddressValidationResultWrapper> handleError(List<AddressWrapper> addressList, String errorMessage) {
        List<AddressValidationResultWrapper> results = new List<AddressValidationResultWrapper>();
        for(AddressWrapper addr : addressList) {
            AddressValidationResultWrapper result = new AddressValidationResultWrapper(addr.recordId);
            result.errorMessage = errorMessage;
            result.isValid = false;
            results.add(result);
        }
        return results;
    }
}