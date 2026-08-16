import std.stdio;
import std.file;
import std.path;
import std.process;
import std.array;
import std.typecons;
import toml;

enum VERSION = "pre-release 0.1.0";

struct Language
{
    string compiler;
    string[] flags;
}

struct Target
{
    string[] sources;
    string output;
    string linker;
}

struct Config
{
    Language[string] languages;
    Target[string] targets;
}

Nullable!Config readConfig(string filename)
{
    try
    {
        auto text = readText(filename);
        auto document = parseTOML(text);

        Config config;

        if ("languages" in document)
        {
            auto languages = document["languages"].table;

            foreach (name, value; languages)
            {
                auto language = value.table;

                Language lang;

                if ("compiler" in language)
                    lang.compiler = language["compiler"].str;

                if ("flags" in language)
                {
                    foreach (flag; language["flags"].array)
                        lang.flags ~= flag.str;
                }

                config.languages[name] = lang;
            }
        }

        if ("targets" in document)
        {
            auto targets = document["targets"].table;

            foreach (name, value; targets)
            {
                auto target = value.table;

                Target t;

                if ("sources" in target)
                {
                    foreach (source; target["sources"].array)
                        t.sources ~= source.str;
                }

                if ("output" in target)
                    t.output = target["output"].str;

                if ("linker" in target)
                    t.linker = target["linker"].str;

                config.targets[name] = t;
            }
        }

        return nullable(config);
    }
    catch (Exception)
    {
        return Nullable!Config.init;
    }
}

int buildTarget(Config config, Target target)
{
    string[] objects;

    foreach (source; target.sources)
    {
        auto extension = std.path.extension(source);

        if (extension.length > 0)
            extension = extension[1 .. $];

        if (extension !in config.languages)
        {
            stderr.writefln(
                "error: no language configured for '%s' files",
                extension
            );
            return 1;
        }

        auto language = config.languages[extension];
        auto object = source.stripExtension ~ ".o";

        string[] command;

        command ~= language.compiler;
        command ~= language.flags;
        command ~= source;
        command ~= "-o";
        command ~= object;

        writefln("[COMPILE] %s %s", language.compiler, source);

        auto result = execute(command);

        if (result.status != 0)
        {
            stderr.writefln("error: failed to compile %s", source);
            return 1;
        }

        objects ~= object;
    }

    writefln("[LINK]    %s %s", target.linker, objects.join(" "));

    string[] linkCommand;

    linkCommand ~= target.linker;
    linkCommand ~= objects;
    linkCommand ~= "-o";
    linkCommand ~= target.output;

    auto linkResult = execute(linkCommand);

    if (linkResult.status != 0)
    {
        stderr.writefln(
            "error: failed to link %s",
            target.output
        );
        return 1;
    }

    writeln("Built ", target.output, " successfully!");

    return 0;
}

void printHelp()
{
    writeln("SMake - Simple Make");
    writeln();
    writeln("Usage:");
    writeln("  smake <target>");
    writeln("  smake all");
    writeln("  smake clean");
    writeln("  smake --help");
    writeln("  smake --version");
}

void clean(Config config)
{
    foreach (target; config.targets.values)
    {
        if (exists(target.output))
            remove(target.output);

        foreach (source; target.sources)
        {
            auto object = source.stripExtension ~ ".o";

            if (exists(object))
                remove(object);
        }
    }

    writeln("Cleaned build files.");
}

int main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writefln("error: no target specified");
        stderr.writefln("Try 'smake --help' for more information.");
        return 1;
    }

    auto command = args[1];

    if (command == "--help" || command == "-h")
    {
        printHelp();
        return 0;
    }

    if (command == "--version" || command == "-v")
    {
        writeln("smake ", VERSION);
        return 0;
    }

    auto configResult = readConfig("SMake.toml");

    if (configResult.isNull)
    {
        stderr.writefln("error: couldn't find/read SMake.toml");
        return 1;
    }

    auto config = configResult.get;

    if (command == "clean")
    {
        clean(config);
        return 0;
    }

    if (command == "all")
    {
        foreach (target; config.targets.values)
        {
            if (buildTarget(config, target) != 0)
                return 1;
        }

        return 0;
    }

    if (command !in config.targets)
    {
        stderr.writefln("error: target '%s' not found", command);
        return 1;
    }

    return buildTarget(config, config.targets[command]);
}