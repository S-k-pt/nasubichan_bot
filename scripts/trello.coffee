#Description:
#	test script
#

module.exports = (robot) ->
    robot.hear /(.*)を追加(.*)/i, (msg) ->
        title = "#{msg.match[1]}"

        Trello = require ("node-trello")
        trello = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
        trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_TODO}, (err, data) ->
            if err
                msg.send "タスク登録に失敗しました。[errcode: #{err}]"
                return
            msg.send "タスク「#{title}」 をToDoリストに登録しました"

