#Description:
#	test scripts
#

module.exports = (robot) ->
    Trello = require ("node-trello")
    org = process.env.HUBOT_TRELLO_BOARD
    trello = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)


    getOLists = (msg, args) ->
        url = "/1/organizations/#{org}/boards"
        trello.get url, (err, data) =>
            if err
                msg.send "エラーが発生しました[errcode: #{err}]"
                return
            for board in data
                if board.name.toLowerCase() == "slackbot-test"
                    args['boardID'] = board.id
                    return args['callbacks'].shift()(msg, args)
            msg.send "ボードが存在しません"

    getBLists = (msg, args) ->
        url = "/1/boards/#{args['boardID']}/lists"
        trello.get url, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
            for list in data
                if list.name.toLowerCase() is args['listName']
                    args['listID'] = list.id
                    return args['callbacks'].shift()(msg, args)
            msg.send "ボード内に#{args['listName']}リストが存在しません"

    getBBLists = (msg, args) ->
        url = "/1/boards/#{args['boardID']}/lists"
        trello.get url, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
            for list in data
                if list.name.toLowerCase() is args['listName2']
                    args['listID2'] = list.id
                    return args['callbacks'].shift()(msg, args)
            msg.send "ボード内に#{args['listName2']}リストが存在しません"

    getCLists = (msg, args) ->
        url = "/1/lists/#{args['listID2']}/cards"
        trello.get url, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
            for card in data
                if card.name.toLowerCase() is args['cardName']
                    args['cardShort'] = card.id
                    return args['callbacks'].shift()(msg, args)
            msg.send "指定されたカードが#{args['listName2']}リスト内にありません"

    postCLists = (msg, args) ->
        url = "/1/lists/#{args['listID']}/cards"
        trello.post url, { name: args['cardName'] }, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
        msg.send "タスク「#{args['cardName']}」 を#{args['listName']}リストに登録しました"

    putClists = (msg, args) ->
        url = "/1/cards/#{args['cardShort']}/idList"
        trello.put url, { value: args['listID'] }, (err, data) =>
            if err
                msg.send "エラーが発生しました。。[errcode: #{err}]"
                return
        msg.send "タスク「#{args['cardName']}」 を#{args['listName']}リストに登録しました"


    robot.hear /(.*)を追加(.*)/i, (msg) ->
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks: [getBLists, postCLists], listName: 'todo', cardName: title})
        #msg.send "タスク「#{title}」 をToDoリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_TODO}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        

    robot.hear /今から(.*)/i, (msg) ->
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks: [getBLists, getBBLists,getCLists, putClists], listName: 'doing', listName2: 'todo', cardName: title})
        #msg.send "タスク「#{title}」 をDoingリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DOING}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        

    robot.hear /(.*)終わり(.*)/i, (msg) ->
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks: [getBLists, getBBLists,getCLists, putClists], listName: 'done', listName2: 'doing', cardName: title})
        #msg.send "タスク「#{title}」 をDoneリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DONE}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        #msg.send "タスク「#{title}」 をDoneリストに登録しました"


