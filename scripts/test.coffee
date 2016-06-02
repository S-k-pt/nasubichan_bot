#Description:
#	test script
#

module.exports = (robot) ->

	robot.respond /疲れた/i, (msg) ->
		msg.send "がんばれ :heart: がんばれ :heart: "

	robot.respond /ウサギガイナイ/i, (msg) ->
		msg.send "なんだこの客..."

	robot.hear /こんにちは/i, (msg) ->
		msg.reply "こんにちは:grinning:"

	robot.hear /おはよう/i, (msg) ->
		msg.reply "おはようございます:grinning:"

	robot.hear /こんばんは/i, (msg) ->
		msg.reply "こんばんは:grinning:"
