public with sharing class AddressWrapper {
    public Id recordId;
    public String inputId;
    public String street;
    public String street2;
    public String secondary;
    public String city;
    public String state;
    public String postalCode;
    public String country;
    public String lastline;
    public Integer candidates;

    public AddressWrapper(Id recordId, String street, String city, String state, String postalCode, String country, String inputId, String street2, String secondary, String lastline, Integer candidates) {
        this.recordId = recordId;
        this.street = street;
        this.city = city;
        this.state = state;
        this.postalCode = postalCode;
        this.country = country;
        this.inputId = inputId;
        this.street2 = street2;
        this.secondary = secondary;
        this.lastline = lastline;
        this.candidates = candidates != null ? candidates : 10;
    }
}