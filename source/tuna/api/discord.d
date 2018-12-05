module tuna.api.discord;

import discord.w.gateway : DiscordGateway;
import discord.w.types : Message, Snowflake;
import discord.w.bot : DiscordBot;

string discord_token;
__gshared DiscordBot bot;

class TunaDiscordGateway : DiscordGateway
{
	this(string token)
	{
		super(token);
	}

	override void onMessageCreate(Message m) @trusted
	{
		super.onMessageCreate(m);

		if (m.author.id == this.info.user.id)
			return;
		
		sendTemporary(m.channel_id, "message received!");
	}

	void sendTemporary(Snowflake channel, string text)
	{
		auto m = bot.channel(channel).sendMessage(text);
		
		import vibe.core.core : runTask, sleep;
		import core.time : seconds;
		runTask({ sleep(10.seconds); bot.channel(channel).deleteMessage(m.id); });
	}
}

void startDiscordGatewayLoop()
{
	import core.thread : Thread;
	new Thread({
		while(bot.gateway.connected)
		{
			import vibe.core.core : sleep;
			import core.time : msecs;

			sleep(10.msecs);
		}
	}).start();
}