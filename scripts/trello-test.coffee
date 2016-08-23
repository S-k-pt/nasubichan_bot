# Description:
#   hubot-trello-tools.coffeeをテストするスクリプトです。
#
# Commadns:
#   createKanbanのテスト tretes kanban   <ボード名>
#   addCardのテスト      tretes addtask  <ボード名> <タスク名>
#   cardMoveToのテスト   tretes motetask <ボード名> <タスク名> <移動先リスト名>
#   printKanbanのテスト  tretes show     <ボード名>

Trello = require 'node-trello'
TrelloBoard = require './module/trello-board'
TrelloTools = require './module/hubot-trello-tools'

BOARD_ID = "5791b6f247501b7202d6f9c7"
BOARD_NAME = "slackbot-test"
KANBAN_NAME = "test-kanban"
ORGANIZATION_ID = "igakilab1"
echoData = (err, data) ->
  if err then console.log "ERROR"; console.log err; return
  console.log data

assertError = (err) ->
  if err
    console.log "ERROR"
    console.log err
    return true
  else
    return false

boardGet = (callback) ->
  client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN
  TrelloBoard.getBoardDataByName client, BOARD_NAME, (err, board) ->
    if assertError err then return
    callback board

module.exports = (robot) ->
  robot.hear /tretes boardget/i, (msg) ->
    client = new Trello process.env.HUBOT_TRELLO_KEY, process.env.HUBOT_TRELLO_TOKEN
    TrelloBoard.getBoardDataByName client, "slackbot-test", echoData

  robot.hear /tretes lists/i, (msg) ->
    boardGet (board) ->
      console.log board.getAllLists()

  robot.hear /tretes cards/i, (msg) ->
    boardGet (board) ->
      console.log board.getAllCards()

  robot.hear /tretes card (.*)/i, (msg) ->
    cardName = msg.match[1]
    boardGet (board) ->
      list = board.getAllLists()[0]
      if list? then board.createCard list.id, cardName, echoData
      #if list? then board.createCard list.id, cardName, {due: new Date()}, echoData

  robot.hear /tretes list (.*)/i, (msg) ->
    listName = msg.match[1]
    boardGet (board) ->
      board.createList listName, {pos: "bottom"}, echoData

  robot.hear /tretes kanban (.*)/i, (msg) ->
    boardName = msg.match[1]
    TrelloTools.createKanban boardName, ORGANIZATION_ID, msg

  robot.hear /tretes addtask (.*) (.*)/i, (msg) ->
    boardName = msg.match[1]
    cardName = msg.match[2]
    TrelloTools.addCard boardName, cardName, msg

  robot.hear /tretes movetask (.*) (.*) (.*)/i, (msg) ->
    boardName = msg.match[1]
    cardName = msg.match[2]
    listName = msg.match[3]
    TrelloTools.cardMoveTo boardName, cardName, listName, msg

  robot.hear /tretes show (.*)/i, (msg) ->
    boardName = msg.match[1]
    TrelloTools.printKanban boardName, ORGANIZATION_ID, msg
