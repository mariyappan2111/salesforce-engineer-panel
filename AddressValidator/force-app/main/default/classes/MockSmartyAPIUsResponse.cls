public class MockSmartyAPIUsResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            String mockResponseString = '[{' +
                '"input_index": 0,' +
                '"candidate_index": 0,' +
                '"delivery_line_1": "1600 Amphitheatre Pkwy",' +
                '"last_line": "Mountain View CA 94043-1351",' +
                '"components": {' +
                    '"primary_number": "1600",' +
                    '"street_name": "Amphitheatre",' +
                    '"street_suffix": "Pkwy",' +
                    '"city_name": "Mountain View",' +
                    '"state_abbreviation": "CA",' +
                    '"zipcode": "94043"' +
                '},' +
                '"analysis": {' +
                    '"dpv_match_code": "Y",' +
                    '"active": "Y"' +
                '}' +
            '}]';
            response.setBody(mockResponseString);
            return response;
        }
}