import std.stdio;
import std.file;
import toml;

int main() {
    writeln("SMake starting...");

    try {
        auto text = readText("SMake.toml");
        auto document = parseTOML(text);

        writeln("TOML parsed!");
        return 0;
    }
    catch (Exception) {
        stderr.writefln("smake: error: couldn't find/read SMake.toml");
        return 1;
    }
}