require 'minitest/autorun'
require_relative './find_solution'

class Make24Test < MiniTest::Unit::TestCase
	def test_find_solution_no_solution
		cards = [1,1,1,1]
		assert_equal(FindSolution.new(*cards).solution, nil)
	end

	def test_find_solution_solution_seq
		cards = [10,10,2,2]
		assert_equal(FindSolution.new(*cards).solution, [[10,10,2,2], ['+','+','+'], true])
	end

	def test_find_solution_solution_non_seq
		cards = [1, 3, 8, 2]
		refute_nil(FindSolution.new(*cards).solution)
	end

end