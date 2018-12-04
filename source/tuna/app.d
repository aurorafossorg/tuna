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
	import std.process : environment;
	if (environment.get("DYNO") !is null)
	{
		HTTPClient.setTLSSetupCallback((ctx) {
			ctx.useTrustedCertificateFile("/etc/ssl/certs/ca-certificates.crt");
		});
	}

	import tuna.webserver;
	settings.port = 8080;
	settings.bindAddresses = ["0.0.0.0"];

	readOption("port|p", &settings.port, "Sets the port used for serving HTTP.");
	readOption("address|a", &settings.bindAddresses[0], "Sets the address used for serving HTTP.");
	if (!finalizeCommandLineOptions())
		return;

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

	import tuna.webserver : startWebServer;
	startWebServer(settings);

	//vibe-d final initialization
	lowerPrivileges();
	runEventLoop();
}