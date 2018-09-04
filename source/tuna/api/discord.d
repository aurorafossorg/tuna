module tuna.api.discord;

import discord.w.gateway : DiscordGateway;
import discord.w.types : Message, Snowflake;
import discord.w.bot : DiscordBot;

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