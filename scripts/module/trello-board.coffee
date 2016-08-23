class TrelloBoard
  @getInstance: (client, boardId, callback) ->
    url = "/1/boards/#{boardId}"
    options = {lists: "all", cards:"all"}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      board = new TrelloBoard client, data
      callback? err, board

  @getInstanceByName: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = if idOrg? then "/1/organizations/#{idOrg}/boards"
    else "/1/members/me/boards"
    options = {fields: "name"}
    client.get url, options, (err, boards) ->
      if err then callback? err, null; return
      for board in boards
        if board.name is boardName
          TrelloBoard.getInstance client, board.id, callback
          return
      callback "board not found : #{boardName}", null

  @createBoard: (client, boardName, idOrg, callback) ->
    unless callback? then callback = idOrg; idOrg = null
    url = "/1/boards"
    options =
      name: boardName
      defaultLists: "false"
      prefs_permissionLevel: "org"
    if idOrg? then options.idOrganization = idOrg
    client.post url, options, callback

  constructor: (client, data) ->
    this.client = client
    this.data = data

  reload: (callback) ->
    url = "/1/boards/#{this.data.id}"
    options = {lists: "all", cards:"all"}
    client.get url, options, (err, data) ->
      if err then callback? err, null; return
      this.data = data
      callback? err, board

  getList: (listId) ->
    for list in this.data.lists
      if list.id is listId
        return list
    return null

  getListByName: (listName) ->
    for list in this.data.lists
      if list.name is listName
        return list
    return null

  getAllLists: () ->
    return this.data.lists

  createList: (listName, params, callback) ->
    unless callback? then callback = params; params = null
    url = "/1/boards/#{this.data.id}/lists"
    params = params ? {}
    params.name = listName
    this.client.post url, params, callback

  getCard: (cardId) ->
    for card in this.data.cards
      if card.id is cardId
        return card
    return null

  getCardByName: (cardName) ->
    for card in this.data.cards
      if card.name is cardName
        return card
    return null

  getCardsByListId: (listId) ->
    hit = []
    for card in this.data.cards
      if card.idList is listId
        hit.push card
    return hit

  getAllCards: () ->
    return this.data.cards

  createCard: (listId, cardName, params, callback) ->
    unless callback? then callback = params; params = null
    url = "/1/cards"
    params = params ? {}
    params.name = cardName
    params.idList = listId
    this.client.post url, params, callback

  cardMoveTo: (cardId, listId, callback) ->
    url = "/1/cards/#{cardId}"
    options = {idList: listId}
    this.client.put url, options, callback

module.exports = TrelloBoard
