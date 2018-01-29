/++
 + Copyright: Copyright © 2017, Christian Köstlin
 + License: MIT
 + Authors: Christian Koestlin
 +/

module androidlogger;

import std.experimental.logger;

class AndroidLogger : FileLogger
{
    import std.stdio;
    import std.string;
    import std.concurrency;
    import std.process;
    import colored;

    private string[LogLevel] logLevel2String;
    private bool withColors;

    this(bool withColors = true, LogLevel level = LogLevel.all) @system
    {
        super(stdout, level);
        this.withColors = withColors;
        initLogLevel2String();
    }

    static string tid2string(Tid id) @trusted
    {
        import std.conv : text;

        return text(id).replace("Tid(", "").replace(")", "");
    }

    override void writeLogMsg(ref LogEntry payload) @trusted
    {
        with (payload)
        {
            // android logoutput looks lokes this:
            // 06-06 12:14:46.355 372 18641 D audio_hw_primary: disable_audio_route: reset and update
            // DATE  TIME         PID TID   LEVEL TAG           Message
            auto h = timestamp.fracSecs.split!("msecs");
            auto idx = msg.indexOf(':');
            string tag = ""; // "%s.%d".format(file, line),
            string text = "";
            if (idx == -1)
            {
                tag = "stdout";
                text = msg;
            }
            else
            {
                tag = msg[0 .. idx];
                text = msg[idx + 1 .. $];
            }
            this.file.lockingTextWriter()
                .put(colorize("%02d-%02d %02d:%02d:%02d.%03d %d %s %s %s: %s\n".format(timestamp.month, // DATE
                        timestamp.day, timestamp.hour, // TIME
                        timestamp.minute, timestamp.second,
                        h.msecs, std.process.thisProcessID, // PID
                        tid2string(threadId), // TID
                        logLevel2String[logLevel], tag, text), logLevel).toString);

        }
    }

    private void initLogLevel2String()
    {
        logLevel2String[LogLevel.trace] = "T";
        logLevel2String[LogLevel.info] = "I";
        logLevel2String[LogLevel.warning] = "W";
        logLevel2String[LogLevel.error] = "E";
        logLevel2String[LogLevel.critical] = "C";
        logLevel2String[LogLevel.fatal] = "F";
    }

    private auto colorize(string s, LogLevel logLevel)
    {
        if (!withColors)
        {
            return s.defaultColor.onDefaultColor;
        }

        switch (logLevel)
        {
        case LogLevel.trace:
            return s.black.onDefaultColor;
        case LogLevel.info:
            return s.defaultColor.onDefaultColor;
        case LogLevel.warning:
            return s.green.onDefaultColor;
        case LogLevel.error:
            return s.yellow.onDefaultColor;
        case LogLevel.critical:
            return s.black.onRed;
        case LogLevel.fatal:
            return s.yellow.onRed;
        default:
            assert(0);
        }
    }
}
