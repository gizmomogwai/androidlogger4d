/++
 + Copyright: Copyright © 2017, Christian Köstlin
 + License: MIT
 + Authors: Christian Koestlin
 +/

import androidlogger;
import std.experimental.logger;

int main(string[] args)
{
    sharedLog = new AndroidLogger(args[1] == "true");
    trace("trace");
    info("info");
    warning("warning");
    error("error");
    critical("critical");
    fatal("fatal");
    return 0;
}
