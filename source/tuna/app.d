module tuna.app;

shared static this()
{
	version (linux)
	{
		import std.process : environment;
		if ("DYNO" in environment)
		{
			import etc.linux.memoryerror : registerMemoryErrorHandler;
			registerMemoryErrorHandler();
		}
	}
}

version (unittest) {}
else void main(string[] args)
{
	import vibe.vibe;
	HTTPServerSettings settings = new HTTPServerSettings;

	settings.port = 8080;
	settings.bindAddresses = ["0.0.0.0"];

	readOption("port|p", &settings.port, "Sets the port used for serving HTTP.");
	readOption("bind-address|bind", &settings.bindAddresses[0], "Sets the address used for serving HTTP.");

	import tuna.webserver : tunaHTTPServerListener;
	auto listener = listenHTTP(settings, &tunaHTTPServerListener);

	import std.process : environment;
	import tuna.api.discord;
	import discord.w.bot : makeBot;
	import std.stdio;

	bot = makeBot!TunaDiscordGateway(environment["DISCORD_TOKEN"]);

	import core.thread : Thread;
	new Thread({
		while(bot.gateway.connected)
		{
			import vibe.core.core : sleep;
			import core.time : msecs;

			sleep(10.msecs);
		}
	}).start();

	runApplication();
}