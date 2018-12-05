module tuna.app;

import tuna.api.discord;
import tuna.webhooks.discord : discord_webhook_url;
import tuna.webhooks.github : githubHookSecret;

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
	import std.process : environment;
	discord_token = environment["DISCORD_TOKEN"];
	discord_webhook_url = environment["DISCORD_WEBHOOK"];
	githubHookSecret = environment["GH_HOOK_SECRET"];
	import vibe.vibe;

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

	import discord.w.bot : makeBot;

	bot = makeBot!TunaDiscordGateway(discord_token);

	startDiscordGatewayLoop();

	import tuna.webserver : startWebServer;
	startWebServer(settings);

	//vibe-d final initialization
	lowerPrivileges();
	runEventLoop();
}