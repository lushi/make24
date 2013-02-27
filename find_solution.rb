class FindSolution
	attr_reader :numbers
	def initialize(n1, n2, n3, n4)
		@numbers = [n1.to_f, n2.to_f, n3.to_f,n4.to_f]
	end

	def operators
		%w(+ - * /)
	end

	def apply_ops_seq(number, op)
		number[0].send(op[0], number[1]).
			send(op[1], number[2]).
			send(op[2], number[3])
	end

	def apply_ops_nonseq(number, op)
		number[0].send(op[0], number[1]).
			send(op[1], number[2].send(op[2], number[3]))
	end

	def good_permutation_seq?(nums, ops)
		24 == apply_ops_seq(nums, ops)
	rescue ZeroDivisionError
		false
	end

	def good_permutation_nonseq?(nums,ops)
		24 == apply_ops_nonseq(nums, ops)
	rescue ZeroDivisionError
		false
	end

	def solution
		numbers.permutation 4 do |nums|
			operators.repeated_permutation 3 do |ops|
				if good_permutation_seq?(nums, ops) || good_permutation_nonseq?(nums, ops)
					return [nums.map { |n| n.to_i }, ops, good_permutation_seq?(nums, ops)]
				end
			end
		end
		nil
	end
end