require 'minitest/autorun'
require_relative './console_interface.rb'

class Make24Test < MiniTest::Unit::TestCase
	def test_score_variable_1_player
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		assert_equal(0, game.score)
	end

	def test_score_variable_2_players
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 2)
		assert_equal([0,0], game.score)
	end

	def test_draw_hand
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		assert_equal(4, game.draw_hand.length)
	end

	def test_right_num_bad
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.draw_hand
		game.player_answer = "6 * 7 +(8 - 9)"
		assert_equal(false, game.right_num?)
	end

	def test_right_num_good
		game = GameMechanics.new([1,2,3,4], 1)
		game.draw_hand
		game.player_answer = "1 * 2 +(3 -4)"
		assert_equal(true, game.right_num?)
	end

	def test_match_regexp_match_addition
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.player_answer = "1 + 2 + 3 + 4"
		refute_nil(game.match_regexp?)
	end

	def test_match_regexp_reject_junk_prefix
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.player_answer = "abcgd1 + 1 + 1 + 1"
		assert_equal(false, game.match_regexp?)
	end

	def test_match_regexp_match_paren
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.player_answer = "(2 + 2) * (3 + 3)"
		assert_equal(true, game.match_regexp?)
	end

	def test_complete_paren_bad
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.player_answer = "((1 + 2 + 3 + 4"
		assert_equal(false, game.complete_paren?)
	end

	def test_complete_paren_good
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		game.player_answer = "((1 + 2) + 3) + 4"
		assert_equal(true, game.complete_paren?)
	end

	def test_input_valid_good
		game = GameMechanics.new([2,2,3,3], 1)
		game.draw_hand
		game.player_answer = "(2 + 2) * (3 + 3)"
		assert_equal(true, game.input_valid?)
	end

	def test_input_valid_bad
		game = GameMechanics.new([1,2,3,4], 1)
		game.draw_hand
		game.player_answer = "((1 + 2 + 3) + 4fdja;fjkd"
		assert_equal(false, game.input_valid?)
	end

	def test_make24_not_valid
		game = GameMechanics.new([1,2,3,4], 1)
		game.draw_hand
		game.player_answer = "((1 + 2 + 3) + 4fdja;fjkd"
		assert_equal(false, game.make24?)
	end

	def test_make24_valid_wrong
		game = GameMechanics.new([1,2,3,4], 1)
		game.draw_hand
		game.player_answer = "(1 + 2 + 3) + 4"
		assert_equal(false, game.make24?)
	end

	def test_make24_valid_correct
		game = GameMechanics.new([2,2,3,3], 1)
		game.draw_hand
		game.player_answer = "(2 + 2) * (3 + 3)"
		assert_equal(true, game.make24?)
	end

	def test_find_solution_no_solution
		hand = [1,1,1,1]
		assert_nil(FindSolution.new(*hand).print_solution)
	end

	def test_find_solution_solution_seq
		hand = [10,10,2,2]
		assert_equal("((10 + 10) + 2) + 2", FindSolution.new(*hand).print_solution)
	end

	def test_find_solution_solution_non_seq
		hand = [1, 3, 8, 2]
		refute_equal("No solution", FindSolution.new(*hand).print_solution)
	end

	def test_terminate_false
		game = GameMechanics.new((1..10).to_a * 4 + [1, 1, 1] * 4, 1)
		assert_equal(false, game.terminal?)
	end

	def test_terminate_true
		game = GameMechanics.new([], 1)
		assert_equal(true, game.terminal?)
	end

	def test_consoleinterface_inherits_gamemechanics
		assert_equal(4, GameOnConsole.new(1,1).instance_variables.length)
	end

end