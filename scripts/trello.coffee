#Description:
#	test script
#


Trello = require("node-trello")


module.exports = (robot) ->
    robot.hear /^todo (.*)/i, (msg) ->
        title = "#{msg.match[1]}"
        trello = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
        trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_TODO}, (err, data) ->
          if err 
            msg.send "保存に失敗しました"
            return
          msg.send "「#{title}」 をTrelloのToDoボードに保存しました"

