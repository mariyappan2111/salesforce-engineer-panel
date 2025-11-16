public with sharing class AddressValidationResultWrapper {
    public List<AddressResult> results;
    public Id recordId;
    public String message;
    public Boolean isSuccess;
    public Integer inputIndex;
    public Integer candidateIndex;
    public Boolean isValid;
    public Integer confidence;
    public String errorMessage;
    
    public class AddressResult {
        public Integer input_index;
        public Integer candidate_index;
        public String delivery_line_1;
        public String last_line;
        public String delivery_point_barcode;
        public Components components;
        public Metadata metadata;
        public Analysis analysis;
    }

    public class Components {
        public String primary_number;
        public String street_name;
        public String street_suffix;
        public String city_name;
        public String default_city_name;
        public String state_abbreviation;
        public String zipcode;
        public String plus4_code;
        public String delivery_point;
        public String delivery_point_check_digit;
    }

    public class Metadata {
        public String record_type;
        public String zip_type;
        public String county_fips;
        public String county_name;
        public String carrier_route;
        public String building_default_indicator;
        public String rdi;
        public String elot_sequence;
        public String elot_sort;

        public Decimal latitude;
        public Decimal longitude;

        public String precision;
        public String time_zone;
        public Integer utc_offset;
        public Boolean dst;
    }

    public class Analysis {
        public String dpv_match_code;
        public String dpv_footnotes;
        public String active;
        public String footnotes;
    }
    // Constructor
    public AddressValidationResultWrapper(Id recordId) {
        this.recordId = recordId;
        this.isValid = false;
        this.confidence = 0;
    }
    public AddressValidationResultWrapper() {
        this.isValid = false;
        this.confidence = 0;
    }

}