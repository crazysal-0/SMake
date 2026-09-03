import std.stdio;
import std.file;
import std.path;
import std.process;
import std.array;
import std.typecons;
import toml;

enum VERSION = "SMake 0.1.0";

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
    string[] linkerFlags;
}

struct Config
{
    Language[string] languages;
    Target[string] targets;
}

Config readConfig()
{
    Config config;

    auto data = parseTOML(readText("SMake.toml"));

    // Languages
    if ("languages" in data)
    {
        auto languages = data["languages"].table;

        foreach (name, value; languages)
        {
            auto languageTable = value.table;

            Language language;

            if ("compiler" in languageTable)
                language.compiler = languageTable["compiler"].str;

            if ("flags" in languageTable)
            {
                foreach (flag; languageTable["flags"].array)
                    language.flags ~= flag.str;
            }

            config.languages[name] = language;
        }
    }

    // Targets
    if ("targets" in data)
    {
        auto targets = data["targets"].table;

        foreach (name, value; targets)
        {
            auto targetTable = value.table;

            Target target;

            if ("sources" in targetTable)
            {
                foreach (source; targetTable["sources"].array)
                    target.sources ~= source.str;
            }

            if ("output" in targetTable)
                target.output = targetTable["output"].str;

            if ("linker" in targetTable)
                target.linker = targetTable["linker"].str;

            if ("linkerFlags" in targetTable)
            {
                foreach (flag; targetTable["linkerFlags"].array)
                    target.linkerFlags ~= flag.str;
            }

            config.targets[name] = target;
        }
    }

    return config;
}

int buildTarget(Config config, Target target, string targetName)
{
    string[] objects;

    // Object files go into:
    // build/<target-name>/
    auto outputDir = buildPath("build", targetName);

    if (!exists(outputDir))
        mkdirRecurse(outputDir);

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

        auto sourceName = baseName(source);
        auto objectName = sourceName.stripExtension ~ ".o";
        auto object = buildPath(outputDir, objectName);

        string[] command;

        command ~= language.compiler;
        command ~= language.flags;
        command ~= source;
        command ~= "-o";
        command ~= object;

        writefln(
            "[COMPILE] %s %s",
            language.compiler,
            source
        );

        auto result = execute(command);

        if (result.status != 0)
        {
            stderr.writefln(
                "error: failed to compile %s",
                source
            );

            return 1;
        }

        objects ~= object;
    }

    // Create the output's parent directory if necessary.
    auto outputParent = dirName(target.output);

    if (outputParent.length > 0 && !exists(outputParent))
        mkdirRecurse(outputParent);

    writefln(
        "[LINK]    %s %s",
        target.linker,
        objects.join(" ")
    );

    string[] linkCommand;

    linkCommand ~= target.linker;
    linkCommand ~= target.linkerFlags;
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

    writeln(
        "Built ",
        target.output,
        " successfully!"
    );

    return 0;
}

void clean(Config config)
{
    foreach (name, target; config.targets)
    {
        // Remove the final executable.
        if (exists(target.output))
        {
            try
            {
                remove(target.output);
            }
            catch (Exception)
            {
                stderr.writefln(
                    "warning: could not remove %s",
                    target.output
                );
            }
        }

        // Remove build/<target-name>/
        auto outputDir = buildPath("build", name);

        if (exists(outputDir))
        {
            try
            {
                rmdirRecurse(outputDir);
            }
            catch (Exception)
            {
                stderr.writefln(
                    "warning: could not remove %s",
                    outputDir
                );
            }
        }
    }

    // Remove build/ if it is now empty.
    if (exists("build"))
    {
        try
        {
            rmdir("build");
        }
        catch (Exception)
        {
            // build/ is not empty.
        }
    }

    writeln("Cleaned build files.");
}

void printHelp()
{
    writeln("SMake - Simple Make");
    writeln();
    writeln("Usage:");
    writeln("  smake <target>");
    writeln("  smake all");
    writeln("  smake clean");
    writeln("  smake help");
    writeln("  smake version");
    writeln("  smake --help");
    writeln("  smake --version");
}

int main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writeln("error: no target specified");
        stderr.writeln("try 'smake help' for usage");

        return 1;
    }

    auto command = args[1];

    if (command == "help" || command == "--help")
    {
        printHelp();
        return 0;
    }

    if (command == "version" || command == "--version")
    {
        writeln(VERSION);
        return 0;
    }

    if (!exists("SMake.toml"))
    {
        stderr.writeln("error: SMake.toml not found");
        return 1;
    }

    Config config;

    try
    {
        config = readConfig();
    }
    catch (Exception e)
    {
        stderr.writefln(
            "error: failed to parse SMake.toml: %s",
            e.msg
        );

        return 1;
    }

    if (command == "clean")
    {
        clean(config);
        return 0;
    }

    if (command == "all")
    {
        foreach (name, target; config.targets)
        {
            auto result = buildTarget(
                config,
                target,
                name
            );

            if (result != 0)
                return result;
        }

        return 0;
    }

    if (command !in config.targets)
    {
        stderr.writefln(
            "error: unknown target '%s'",
            command
        );

        return 1;
    }

    return buildTarget(
        config,
        config.targets[command],
        command
    );
}
