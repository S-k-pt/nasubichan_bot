# TrelloBoardCollection
# メンバーやチームのもつボード一覧を取得します。
#
# @getInstanceByMember        client, [memberId], callback
#   memberIdで指定されたメンバーのボードを取得します
#   memberIdを指定しなかった場合は"me"が指定されたものとして取得します
# @getInstanceByOrganization  client, orgId     , callback
#   orgIdで指定されたチームのボードを取得します
#
# new TrelloBoardCollection  client, data, orgId
#   コンストラクタは非推奨です。
#
# getBoard        boardId
#   boardIdで指定されたボードの情報を取得します
# getBoardByName  boardName
#   boardNameで指定されたボードの情報を取得します
#   同じ名前のボードが存在した場合、先に見つけられたボードが返却されます
# getAllBoards
#   コレクション内のすべてのボードを配列で返却します
# createBoard     boardName, [params], callback
#   コレクション内にボードを新しく生成します
#   コレクションをメンバーで取得した場合は、そのメンバーのものに、
#   チームで取得している場合は、チームのボードとして追加されます

Trello = require 'node-trello'

class TrelloBoardCollection
  @getInstanceByMember: (client, memberId, callback) ->
    unless callback? then callback = memberId; memberId = "me"
    url = "/1/members/#{memberId}/boards"
    options = {}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      collection = new TrelloBoardCollection client, data
      callback? err, collection

  @getInstanceByOrganization: (client, orgId, callback) ->
    url = "/1/organizations/#{orgId}/boards"
    options = {}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      collection = new TrelloBoardCollection client, data, orgId
      callback? err, collection

  constructor: (client, data, orgId) ->
    this.client = client
    this.data = data
    this.organizationId = orgId ? null

  getBoard: (boardId) ->
    for board in this.data
      if board.id is boardId
        return board
    return null

  getBoardByName: (boardName) ->
    for board in this.data
      if board.name is boardName
        return board
    return null

  getAllBoards: () ->
    return this.data

  createBoard: (boardName, params, callback) ->
    unless callback? then callback = params; params = {}
    url = "/1/boards"
    params.name = boardName
    params.defaultLists = "false"
    if this.organizationId?
      params.idOrganization = this.organizationId
      pramas.prefs_permissionLevel = params.prefs_permissionLevel ? "org"
    client.post url, params, callback


module.exports = TrelloBoardCollection
