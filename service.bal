import ballerina/cache;
import ballerina/http;
import ballerina/log;
import ballerina/time;

final cache:Cache logsCache = new ();

service / on new http:Listener(9090) {

    resource function get logs(http:Request req) returns string[]|error {
        string|error reqCorrelationId = req.getHeader("X-Correlation-ID");
        string correlationId = "";
        if reqCorrelationId is error {
            log:printWarn("Missing X-Correlation-ID header.", reqCorrelationId);
        } else {
            correlationId = reqCorrelationId;
        }

        log:printInfo("Received request for logs", correlationId = correlationId);
        string[] logs =
            from string logKey in logsCache.keys()
            select check logsCache.get(logKey).ensureType();

        log:printInfo("Successfully retrieved logs", correlationId = correlationId);
        return logs;
    }

    resource function post logs(http:Request req, string message) returns error? {
        string|error reqCorrelationId = req.getHeader("X-Correlation-ID");
        string correlationId = "";
        if reqCorrelationId is error {
            log:printWarn("Missing X-Correlation-ID header.", reqCorrelationId);
        } else {
            correlationId = reqCorrelationId;
        }

        log:printInfo(string `Received request to add log: ${message}`, correlationId = correlationId);
        string logKey = "log-" + time:utcNow()[0].toString();
        check logsCache.put(logKey, message);

        log:printInfo(string `Successfully added log with key: ${logKey}`, correlationId = correlationId);
    }
}
