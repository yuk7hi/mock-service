import ballerina/cache;
import ballerina/http;
import ballerina/log;

final cache:Cache logsCache = new ();

service / on new http:Listener(9090) {

    resource function get logs(http:Request req) returns string[]|error {
        log:printInfo("Received request for logs");
        
        log:printInfo("Request headers: " + ", ".'join(...req.getHeaderNames()));

        string[] logs =
            from string logKey in logsCache.keys()
            select check logsCache.get(logKey).ensureType();
        return logs;
    }
}
