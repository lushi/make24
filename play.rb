
##--------------MAKE 24 GAME: Console Interface-----------------##
##--First parameter is value of cards in the deck to be played--##
##--------Second parameter is the number of players-------------##

require_relative './game_on_console.rb'

STD_DECK = (1..10).to_a * 4 + [1, 1, 1] * 4

game = GameOnConsole.new(STD_DECK, 1)
game.play