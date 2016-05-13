module.exports = (robot) ->

	robot.respond /疲れた/i, (msg) ->
		msg.send "がんばれ :heart: がんばれ :heart: "

	robot.respond /ウサギガイナイ/i, (msg) ->
		msg.send "なんだこの客..."

	robot.hear /こんにちは/i, (msg) ->
		msg.send "こんにちは:grinning:"

	robot.hear /おはよう/i, (msg) ->
		msg.send "おはようございます:grinning:"

	robot.hear /こんばんは/i, (msg) ->
		msg.send "こんばんは:grinning:"
