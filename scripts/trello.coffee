#Description:
#	test script
#

module.exports = (robot) ->
    Trello = require ("node-trello")
    trello = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)

    getOLists = (nm, args) ->
        url = "/1/boards"
        trello.get url, (err, data) ->
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
            for board in data
                if board.name.toLowerCase() is nm.envelope.room
                    args['boardID'] = board.id
                    return args['callbacks'].shift()(nm, args)
                msg.send('データがありません。')

    getBLists = (nm, args) ->
        url = "/1/boards/#{args['boardID']}/lists"
        trello.get url, (err, data) ->
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
            for board in data
                if list.name.toLowerCase() is args['listName']
                    args['listID'] = board.id
                    return args['callbacks'].shift()(nm, args)
                msg.send('データがありません。')

    putClists = (nm, args) ->
        url = "/1/cards/#{args['cardShort']}/idList"
        trello.put url, { value: args['listID']}, (err, data) ->
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return


    robot.hear /(.*)を追加(.*)/i, (msg) ->
        title = "#{msg.match[1]}"

        trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_TODO}, (err, data) ->
            if err
                msg.send "タスク登録に失敗しました。[errcode: #{err}]"
                return
            msg.send "タスク「#{title}」 をToDoリストに登録しました"

    robot.hear /今から(.*)/i, (msg) ->
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks:[getBLists,putClists] listName: title cardShort: ['Doing']})

        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DOING}, (err, data) ->
            #if err
                #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
                #return
            #msg.send "タスク「#{title}」 をDoingリストに登録しました"

    robot.hear /(.*)終わり(.*)/i, (msg) ->
        title = "#{msg.match[1]}"

        trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DONE}, (err, data) ->
            if err
                msg.send "タスク登録に失敗しました。[errcode: #{err}]"
                return
            msg.send "タスク「#{title}」 をDoneリストに登録しました"

