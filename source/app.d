import std.stdio;
import std.file;
import std.typecons;
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

                if ("sourceFlag" in language)
                    lang.sourceFlag = language["sourceFlag"].str;

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

int main()
{
    auto config = readConfig("SMake.toml");

    if (config.isNull)
    {
        stderr.writefln("error: couldn't find/read SMake.toml");
        return 1;
    }

        

    return 0;
}