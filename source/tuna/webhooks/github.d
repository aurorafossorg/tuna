module tuna.webhooks.github;

import vibe.http.server;
import vibe.data.json;
import vibe.stream.operations : readAllUTF8;

string githubHookSecret;

enum HookColor {
	Default = 0,
	Success = 3066993,
	Pending = 16765696,
	Failure = 15158332,
	Unknown = 11053224
}

auto getSignature(string data)
{
	import std.digest.digest, std.digest.hmac, std.digest.sha;
	import std.string : representation;

	auto hmac = HMAC!SHA1(githubHookSecret.representation);
	hmac.put(data.representation);
	return hmac.finish.toHexString!(LetterCase.lower);
}

Json verifyRequest(string signature, string data)
{
	import std.exception : enforce;
	import std.string : chompPrefix;

	enforce(getSignature(data) == signature.chompPrefix("sha1="),
			"Hook signature mismatch");
	return parseJsonString(data);
}

void githubHook(HTTPServerRequest req, HTTPServerResponse res)
{
	Json json = verifyRequest(req.headers.get("X-Hub-Signature"), req.bodyReader.readAllUTF8);
	HookColor hookcolor = HookColor.Default;
	switch(req.headers["X-Github-Event"])
	{
		case "ping":
			res.writeBody("pong");
			break;
		
		case "pull_request":
			switch(json["action"].get!string)
			{
				//Green Color
				case "assigned":
				case "opened":
					hookcolor = HookColor.Success;
					break;

				//Red Color
				case "unassigned":
				case "review_request_removed":
					hookcolor = HookColor.Failure;
					break;
				case "closed":
					hookcolor = HookColor.Failure;
					break;

				//Yellow Color
				case "review_requested":
				case "labeled":
				case "unlabeled":
					hookcolor = HookColor.Pending;
					break;

				//Gray Color
				case "edited":
					hookcolor = HookColor.Unknown;
					break;

				//Default Color
				default: break;
			}
			break;

		default: break;
	}
}