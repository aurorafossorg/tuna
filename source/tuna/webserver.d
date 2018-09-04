module tuna.webserver;

import vibe.vibe;

void tunaHTTPServerListener(HTTPServerRequest req, HTTPServerResponse res)
{
	import tuna.api.discord : bot;
	import discord.w.bot : DiscordBot;
	if(bot == DiscordBot())
		res.writeBody("");
}