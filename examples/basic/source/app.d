/++
 + Copyright: Copyright © 2017, Christian Köstlin
 + License: MIT
 + Authors: Christian Koestlin
 +/

import androidlogger : AndroidLogger;
import std.logger : trace, info, warning, error, critical, fatal, sharedLog;
import std.stdio : stderr;

int main(string[] args)
{
    // dfmt off
    sharedLog = cast(shared) new AndroidLogger(
        file : stderr,
        withColors: args.length < 2 || args[1] == "true",
        developerMode: args.length < 3 || args[2] == "true"
    );
    // dfmt on
    trace("trace logmessage");
    info("info logmessage");
    warning("warning logmessage");
    error("error logmessage");
    critical("critical logmessage");
    fatal("fatal logmessage");
    return 0;
}
