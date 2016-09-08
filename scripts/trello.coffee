#Description:
#	Trello add/move/createboard　&assign scripts
#

module.exports = (robot) ->
    request = require('request')
    Trello = require ("node-trello")
    TrelloBoard = require './module/trello-board'
    TrelloTools = require './module/hubot-trello-tools'
    org = process.env.HUBOT_TRELLO_BOARD
    trello = new Trello(process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN)
    MEMBER = []


    getOLists = (msg, args) -> #所属組織検索
        url = "/1/organizations/#{org}/boards"
        trello.get url, (err, data) =>
            if err
                msg.send "エラーが発生しました[errcode: #{err}]"
                return
            for board in data
                if board.name.toLowerCase() is msg.envelope.room
                    args['boardID'] = board.id
                    console.log "BD:#{board.id}"
                    return args['callbacks'].shift()(msg, args)
            msg.send "指定されたボードが存在しません"

    getBLists = (msg, args) -> #リスト検索(移動先検索)
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

    getBBLists = (msg, args) -> #リスト検索(移動元検索)
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

    getCLists = (msg, args) -> #カード検索
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

    postCLists = (msg, args) -> #カード登録(新規登録用)
        url = "/1/lists/#{args['listID']}/cards"
        trello.post url, { name: args['cardName'] }, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return
        msg.send "タスク「#{args['cardName']}」 を#{args['listName']}リストに登録しました"

    putClists = (msg, args) -> #カード登録(移動用)
        url = "/1/cards/#{args['cardShort']}/idList"
        trello.put url, { value: args['listID'] }, (err, data) =>
            if err
                msg.send "エラーが発生しました。。[errcode: #{err}]"
                return
        msg.send "タスク「#{args['cardName']}」 を#{args['listName']}リストに登録しました"
   
    getMemberID = (msg, args) -> #メンバー検索(配列経由)
        url = "/1/organizations/#{org}/members"
        trello.get url, (err, data) =>
            if err
               msg.send "エラーが発生しました。[errcode: #{err}]"
               return
            for member in data
               if member.fullName is args['name']
                   args['memberID'] = member.id
                   return args['callbacks'].shift()(msg, args)
            msg.send "指定されたメンバーが無効です。"

    getMemberIDs = (msg, name, args) -> #メンバー検索(name経由)
        url = "/1/organizations/#{org}/members"
        console.log "GID:#{name}"
        trello.get url, (err, data) =>
            if err
               msg.send "エラーが発生しました。[errcode: #{err}]"
               return
            for member in data
               console.log "GID::#{member.fullname}"
               if member.fullName is name
                   console.log "GID:::#{member.id}"
                   id = member.id
                   console.log "GID::::#{id}"
                   inviteMem(msg, id, args)
                   return
            msg.send "指定されたメンバーが無効です。"

    setAuthor = (msg, args) -> #自動アサイン
        url = "/1/cards/#{args['cardShort']}/idMembers"
        trello.post url, { value: args['memberID'] }, (err, data) =>
            if err
                msg.send "エラーが発生しました。[errcode: #{err}]"
                return

    seachMem = (msg, args) -> #SlackID->TrelloID読替
        url = "https://slack.com/api/channels.list?token=#{process.env.HUBOT_SLACK_TOKEN}"
        request url, (err, res, body) =>
           json = JSON.parse(body).channels          
           channel = seachCH(msg, json, msg.message.room)
           members = channel.members
           for mem in members
              url3 = "https://slack.com/api/users.info?token=#{process.env.HUBOT_SLACK_TOKEN}&user=#{mem}"
              request url3, (err, res, body) =>
                  json3 = JSON.parse(body).user.name
                  id = getMemberIDs(msg, json3, args)
                  console.log "main::#{id}"
           return

    seachCH = (msg, channels, name) -> #Slackチャンネル検索
        for channel in channels
            if channel.name is name
              return channel
        return

    IdtoName = (msg, members, tgt) -> #不使用
        for member in members
            if member.id is tgt
              msg.send "#{member.name}"
              return member.name
        return

    inviteMem = (msg, id, args) -> #自動メンバー登録
        url = "/1/boards/#{args['boardID']}/members/#{id}"
        console.log "INV:#{id}"
        console.log "INV:#{args['boardID']}"
        trello.put url, { idMember : "5791a4142b2bcb075a3f5874", type : "admin" },(err, data) =>
            if err
              msg.send "エラーが発生しました。.[errcode: #{err}]"
              return              

    robot.hear /(.*)を追加(.*)/i, (msg) -> #todo登録
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks: [getBLists, postCLists], listName: 'todo', cardName: title})
        #msg.send "タスク「#{title}」 をToDoリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_TODO}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        
    robot.respond /今から(.*)/i, (msg) -> #todo->doing & 自動アサイン
        title = "#{msg.match[1]}"
        userName = "#{msg.message.user.name}"
        msg.send "#{msg.message.user.name}"
        getOLists(msg,{callbacks: [getBBLists, getCLists, getMemberID, setAuthor], listName2: 'todo', cardName: title, name: userName})
        getOLists(msg,{callbacks: [getBLists, getBBLists, getCLists, putClists], listName: 'doing', listName2: 'todo', cardName: title})
        #msg.send "タスク「#{title}」 をDoingリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DOING}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        
    robot.respond /testadd(.*)/i, (msg) -> #自動アサインテスト用
        title = "#{msg.match[1]}"
        userName = "#{msg.message.user.name}"
        msg.send "#{msg.message.user.name}"
        getOLists(msg,{callbacks: [getOLists, getBBLists, getCLists, getMemberID, setAuthor], listName2: 'doing', cardName: title, name: userName})  

    robot.hear /(.*)終わり(.*)/i, (msg) -> #doing->done
        title = "#{msg.match[1]}"
        getOLists(msg,{callbacks: [getBLists, getBBLists,getCLists, putClists], listName: 'done', listName2: 'doing', cardName: title})
        #msg.send "タスク「#{title}」 をDoneリストに登録しました"
        #trello.post "/1/cards", {name: title, idList: process.env.HUBOT_TRELLO_DONE}, (err, data) ->
        #if err
            #msg.send "タスク登録に失敗しました。[errcode: #{err}]"
            #return
        #msg.send "タスク「#{title}」 をDoneリストに登録しました"

    robot.hear /かんばんを作成(.*)/i, (msg) -> #かんばん生成 & 自動メンバー登録
        title = "#{msg.envelope.room}"
        TrelloTools.createKanban(title, org, msg)
        msg.send "チャンネル内のメンバーを登録します。"
        getOLists(msg,{callbacks: [seachMem]})

    robot.hear /testinv(.*)/i, (msg) -> #自動メンバー登録テスト用
        getOLists(msg,{callbacks: [seachMem]})


