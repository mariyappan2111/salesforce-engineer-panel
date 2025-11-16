public interface IIntegrationsServiceProvider {
    // Method to get the name of the service provider
    String getServiceProvider();
    // Method to validate a list of addresses and return a list of results
    List<AddressValidationResultWrapper> validateAddresses(List<AddressWrapper> addresses);
}