#Description:
#	test script
#


cheerio = require 'cheerio-httpcli'

module.exports =(robot) ->
	
	robot.hear /電車/i, (msg) ->
	
		baseUrl = 'http://transit.loco.yahoo.co.jp/traininfo/gc/27'

		cheerio.fetch baseUrl, (err, $, res) ->
			if $('.elmTblLstLine.trouble').find('a').length == 0
				msg.send "遅延情報はありません"
				return
			$('.elmTblLstLine.trouble a').each ->
				url = $(this).attr('href')
				cheerio.fetch url, (err, $, res) ->
					title = " #{$('h1').text()} #{$('.subText').text()}"
					result = ""
					$('.trouble').each ->
						trouble = $(this).text().trim()
						resulr += "- " + trouble + "\r\n"
					msg.send "#{title}\r\n#{result}"
