module tuna.webserver;

import vibe.core.core;
import vibe.http.server;
import vibe.http.router;
import vibe.http.common;

import tuna.webhooks.github;

__gshared HTTPServerSettings settings = new HTTPServerSettings;

void startWebServer(HTTPServerSettings settings)
{
	import vibe.http.client : HTTPClient;
	HTTPClient.setUserAgentString("dlang-bot vibe.d/"~vibeVersionString);

	import vibe.http.fileserver;
	auto router = new URLRouter;
	router.get("/", (req, res) => res.render!"index.dt")
		.get("*", serveStaticFiles("public"))
		.post("/github_hook", &githubHook);

	auto listener = listenHTTP(settings, router);
}