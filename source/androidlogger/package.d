/++
 + Copyright: Copyright © 2017, Christian Köstlin
 + License: MIT
 + Authors: Christian Koestlin
 +/
module androidlogger;

@safe:
import colored : black, defaultColor, onDefaultColor, onRed, red, yellow;
import std.array : replace;
import std.concurrency : Tid;
import std.conv : text, to;
import std.format : format;
import std.logger : FileLogger;
import std.logger.core : Logger, LogLevel;
import std.process : execute, thisProcessID;
import std.stdio : File, stdout;
import std.string : indexOf, split;

class AndroidLogger : FileLogger
{

    private string[LogLevel] logLevel2String;
    private bool withColors;
    /// include timestamps, process id, threadid, loglevel (looks like regular android logcat output)
    private bool developerMode;

    this(File file = stdout, bool withColors = true, LogLevel level = LogLevel.all,
            bool developerMode = true) @system
    {
        super(file, level);
        this.withColors = withColors;
        this.developerMode = developerMode;
        initLogLevel2String();
    }

    static string tid2string(Tid id) @trusted
    {
        return text(id).replace("Tid(", "").replace(")", "");
    }

    override @safe void writeLogMsg(ref LogEntry payload)
    {
        // android logoutput looks lokes this:
        // 06-06 12:14:46.355 372 18641 D audio_hw_primary: disable_audio_route: reset and update
        // DATE  TIME         PID TID   LEVEL TAG           Message
        auto h = payload.timestamp.fracSecs.split!("msecs");
        string tag = ""; // "%s.%d".format(file, line),
        string text = "";
        auto idx = payload.msg.indexOf(':');
        if (idx == -1)
        {
            tag = "stdout";
            text = payload.msg;
        }
        else
        {
            tag = payload.msg[0 .. idx];
            text = payload.msg[idx + 1 .. $];
        }
        if (developerMode)
        {
            this.file.lockingTextWriter()
                .put(colorize("%02d-%02d %02d:%02d:%02d.%03d %d %s %s %s: %s".format(payload.timestamp.month, // DATE
                        payload.timestamp.day, payload.timestamp.hour, // TIME
                        payload.timestamp.minute,
                        payload.timestamp.second, h.msecs, thisProcessID, // PID
                        tid2string(payload.threadId), // TID
                        logLevel2String[payload.logLevel], tag, text), payload.logLevel).to!string
                        ~ "\n");
        }
        else
        {
            this.file.lockingTextWriter.put(colorize("%s".format(text),
                    payload.logLevel).to!string ~ "\n");
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
            return s.yellow.onDefaultColor;
        case LogLevel.error:
            return s.red.onDefaultColor;
        case LogLevel.critical:
            return s.black.onRed;
        case LogLevel.fatal:
            return s.yellow.onRed;
        default:
            import std.format : format;

            throw new Exception("Unknown loglevel: %s".format(logLevel));
        }
    }
}
