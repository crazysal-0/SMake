import std.stdio;
import std.file;
import toml;

struct Language
{
    string compiler;
    string[] flags;
    string sourceFlag;
}

struct Target
{
    string[] sources;
    string output;
}

int main() {
    writeln("SMake starting...");

    try {
        auto text = readText("SMake.toml");
        auto document = parseTOML(text);

        writeln("TOML parsed!");

        return 0;
    }
    catch (Exception) {
        stderr.writefln("error: couldn't find/read SMake.toml");
        return 1;
    }
}