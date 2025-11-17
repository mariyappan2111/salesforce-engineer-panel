public with sharing class MockSmartyAPIINTResponse {
    public HTTPResponse respond(HTTPRequest req) {
            HttpResponse responseInt = new HttpResponse();
            responseInt.setHeader('Content-Type', 'application/json');
            responseInt.setStatusCode(200);
            String mockResponseInt = '[{' +
                '"input_index": 0,' +
                '"candidate_index": 0,' +
                '"delivery_line_1": "De Bleek 7",' +
                '"last_line": "3447 GV Woerden",' +
                '"components": {' +
                    '"primary_number": "7",' +
                    '"street_name": "De Bleek",' +
                    '"city_name": "Woerden",' +
                    '"zipcode": "3447 GV"' +
                '},' +
                '"analysis": {' +
                    '"dpv_match_code": "Y",' +
                    '"active": "Y"' +
                '}' +
            '}]';
            
            responseInt.setBody(mockResponseInt);
            return responseInt;
        }
}