public with sharing class AddressValidationProviderFT {
    // This method stores the metadata for each address validation provider
    public static Map<String, API_Service_Providers__mdt> apiServicepProviderCache;
    public static IIntegrationsServiceProvider getServiceProvider(String countryName){
        if (apiServicepProviderCache == null) {
            loadProviderCache();
        }
        API_Service_Providers__mdt activeProvider = getActiveProvider(); // Get the first active Service provider
        if (activeProvider == null) {
            throw new AddressValidationCustomException( System.Label.No_active_address_validation_provider );
        }
        Type providerType = Type.forName(activeProvider.API_Service_Provider_Class__c); // Dynamically get the class type for the provider
        if (providerType == null) {
            throw new AddressValidationCustomException( System.Label.Provider_class_not_found.replace('{0}', activeProvider.API_Service_Provider_Class__c));
        }
        
        return (IIntegrationsServiceProvider) providerType.newInstance();
    }
    // Overload method getServiceProvider
    public static IIntegrationsServiceProvider getServiceProvider(){
        return getServiceProvider(null);
    }

    // Loads Service provider configuration into memory
    public static void loadProviderCache() {
        apiServicepProviderCache = new Map<String, API_Service_Providers__mdt>();
        for (API_Service_Providers__mdt provider : [ SELECT Id, Name_of_the_Provider__c, API_End_Point_Url__c, Auth_ID__c, Auth_token__c, API_Credential_Name__c, Is_Active__c,Country__c, Timeout_Threshold__c, Service_Batch_Size__c, API_Service_Provider_Class__c FROM API_Service_Providers__mdt WHERE Is_Active__c = true ORDER BY Name_of_the_Provider__c]) {
            apiServicepProviderCache.put(provider.Name_of_the_Provider__c, provider);
        }
    }

    public static API_Service_Providers__mdt getProviderByCountry(String country) {
        if (apiServicepProviderCache == null || apiServicepProviderCache.isEmpty()) {
            return null;
        }
        
        if (String.isBlank(country)) {
            return getActiveProvider();
        }
        
        String countryName = country.trim().toUpperCase();
        Boolean isUS = countryName == 'US' || countryName == 'USA' || countryName == 'UNITED STATES';
        // Search for provider matching country preference
        for (API_Service_Providers__mdt provider : apiServicepProviderCache.values()) {
            if (String.isNotBlank(provider.Country__c)) {
                String providerCountry = provider.Country__c.trim().toUpperCase();
                if (isUS && (providerCountry == 'UNITED STATES' || providerCountry == 'US' || providerCountry == 'USA' || providerCountry.contains('UNITED STATES'))) {
                    return provider;
                }
                if (!isUS && (providerCountry == 'INTERNATIONAL' ||  providerCountry == 'INTL' ||  providerCountry.contains('INTERNATIONAL'))) { 
                    return provider;
                }
                if (providerCountry.contains(countryName)) {
                    return provider;
                }
            }
        }
        return getActiveProvider();
    }

    public static API_Service_Providers__mdt getActiveProvider() {
        if (apiServicepProviderCache == null || apiServicepProviderCache.isEmpty()) {
            return null;
        }
        return apiServicepProviderCache.values()[0]; // Get the first active provider;
    }
    
    
    //Gets provider configuration 
    public static API_Service_Providers__mdt getProviderConfig() {
        if (apiServicepProviderCache == null) {
            loadProviderCache();
        }
        return getActiveProvider();
    }
    // Overload method getProviderConfig
    public static API_Service_Providers__mdt getProviderConfig(String country) {
        if (apiServicepProviderCache == null) {
            loadProviderCache();
        }
        return getProviderByCountry(country);
    }
}