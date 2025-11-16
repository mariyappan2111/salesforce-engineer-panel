public with sharing class HttpCalloutBase {
    final static Integer DEFAULT_TIMEOUT = 60000; // Default timeout of 60 seconds
    final static Integer DEFAULT_BATCH_SIZE = 100; // Default batch size
    final static String DEFAULT_CONTENT_TYPE = 'application/json'; // Default content type
    final static Integer MAX_RETRY_ATTEMPTS = 3; // Maximum retry attempts for failed requests
    // Generic method to send HTTP requests
    // This method can be used by derived classes to send HTTP requests to external services
    // Bulkified to handle multiple requests input body
    public static HttpResponse sendRequest(String endpoint, String method, String body, Map<String, String> headers, Integer timeout) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        if (String.isNotBlank(body)) {
            req.setBody(body);
        }
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }
        req.setTimeout(timeout != null ? timeout : DEFAULT_TIMEOUT);
        Http http = new Http();
        return http.send(req);
    }

    // Overloaded method without body parameter
    // This method can be used for GET single requests.
    public static HttpResponse sendRequest(String endpoint, String method, Map<String, String> headers, Integer timeout) {
        return sendRequest(endpoint, method, null, headers, timeout);
    }

    public static void checkResponse(HttpResponse response, String providerName) {
        if (response.getStatusCode() < 200 || response.getStatusCode() >= 300) {
            throw new AddressValidationCustomException( providerName + ' is unavailable. API Error: ' + response.getStatus() +  ' (Code: ' + response.getStatusCode() + ')');
        }
    }
}