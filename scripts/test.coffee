module.exports = (robot) ->

	robot.respond /疲れた/i, (msg) ->
		msg.send "がんばれ +:heart: がんばれ +:heart: "
