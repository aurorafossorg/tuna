module tuna.webserver;

import vibe.core.core;
import vibe.http.server;
import vibe.http.router;
import vibe.http.common;

__gshared HTTPServerSettings settings = new HTTPServerSettings;

void startWebServer(HTTPServerSettings settings)
{
	import vibe.http.client : HTTPClient;
	HTTPClient.setUserAgentString("dlang-bot vibe.d/"~vibeVersionString);

	import vibe.http.fileserver;
	auto router = new URLRouter;
	router.get("/", (req, res) => res.render!"index.dt")
		.get("*", serveStaticFiles("public"));

	auto listener = listenHTTP(settings, router);
}