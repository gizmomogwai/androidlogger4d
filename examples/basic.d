/++
 + Copyright: Copyright © 2017, Christian Köstlin
 + License: MIT
 + Authors: Christian Koestlin
 +/

import androidlogger;
import std.experimental.logger;
import std.stdio;

int main(string[] args)
{
    sharedLog = new AndroidLogger(stderr, args.length == 2 ? args[1] == "true" : true);
    trace("trace");
    info("info");
    warning("warning");
    error("error");
    critical("critical");
    fatal("fatal");
    return 0;
}
