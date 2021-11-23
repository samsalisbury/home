// Use https://finicky-kickstart.now.sh to generate basic configuration
// Learn more about configuration options: https://github.com/johnste/finicky/wiki/Configuration

module.exports = {
	defaultBrowser: "Safari",
	handlers: [
		{
			match: ({ url }) => url.host.endsWith("hashicorp.slack.com"),
			browser: "Slack",
			url: ({ urlString }) => {
				let re = /https:\/\/hashicorp\.slack\.com\/archives\/([A-Z0-9]+)\/p([0-9]{10})([0-9]{6})\?thread_ts=([0-9\.]+).*/
				let matches = re.exec(urlString)
				if (matches != null && matches.length == 5 ) {
					let id, m1, m2, ts
					[ _, id, m1, m2, ts ] = matches
					return `slack://channel?team=T024UT03C&id=${id}&message=${m1}.${m2}&thread_ts=${ts}`
				}
				re = /https:\/\/hashicorp\.slack\.com\/archives\/([A-Z0-9]+)/
				matches = re.exec(urlString)
				if (matches != null && matches.length == 2) {
					let channelId = matches[1]
					return `slack://channel?team=T024UT03C&id=${channelId}`
				}
				return urlString
			}
		}
	],
}
