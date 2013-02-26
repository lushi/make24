#!/usr/bin/env ruby
class Make24
	STD_DECK = (1..10).to_a * 4 + [1, 1, 1] * 4

	def initialize
		@deck = STD_DECK
		@hand
		@player_answer
		@score = [0, 0]
	end

	def play
		intro
		until terminal?
			show_hand
			player_input
			check_player_answer
		end
		announce
	end

	def intro
		puts "--** Welcome to Make 24! **--"
		puts "Press 'r' to read the rules. Press any other key to play."
		print ">"
		r = gets.chomp.downcase
		if r == 'r' #put the following text in separate file intro.txt
			txt = File.open ("rules.txt")
			puts txt.read
			txt.close
			print "Press any key to continue.\n> "
			STDIN.gets
		else
			puts "Player 1's buzzer is 'a'. Player 2's buzzer is 'l'."
			puts "Press your buzzer when you're ready to answer."
			puts "Press 'n' if you think there is no solution."
		end
	end

	def show_hand
		@hand = draw_hand
		puts "Ready..."
		sleep(2)
		@hand.each { |n| print "|#{n}|   " }
		print "\n"
	end

	def draw_hand
		hand = Array.new(4)
		hand.map! do |n|
			n = @deck[rand(@deck.length)]
			@deck.delete_at(@deck.index(n))
		end
		return hand
	end

	def player_input
		buzzer_id = buzzer
		if buzzer_id == 'a'
			player_id = 1
		elsif buzzer_id == 'l'
			player_id = 2
		end

		if buzzer_id == 'n'
			@player_answer = nil
		else
			puts "Player #{player_id}, enter an equation to make 24:"
			player_input = gets.chomp
			player_input_num =player_input.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?).map(&:to_i)
			player_input_op = player_input.split(//).map(&:strip).reject(&:empty?).reject{ |char| char.match /\d/}

			until validated?(player_input, player_input_num, player_input_op)
				puts "Nope, try again: "
				player_input = gets.chomp.downcase
				player_input_num =player_input.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?).map(&:to_i)
				player_input_op = player_input.split(//).map(&:strip).reject(&:empty?).reject{ |char| char.match /\d/}
			end

			@player_answer = [player_input, player_id]
		end
		return @player_answer
	end

	def buzzer
		buzzer_id = gets.chomp
		until buzzer_id == 'n' || buzzer_id == 'a' || buzzer_id == 'l'
			puts "Invalid input. Press your buzzer or press 'n' if there's no solution."
			buzzer_id = gets.chomp
		end
		return buzzer_id
	end

	def validated?(player_input, player_input_num, player_input_op)
		reg = /\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/
		unless (player_input.match reg) && player_input_num.sort == @hand.sort
			return false
		else
			return true
		end
	end

	def check_player_answer
		if @player_answer
			if eval(@player_answer[0]) == 24
				@score[@player_answer[1] - 1] += 1
				puts "That's correct! Player #{@player_answer[1]} gets 1 point. The current score is #{@score}."
			else
				@score[@player_answer[1] - 1] -= 1
				puts "That's incorrect. Player #{@player_answer[1]} loses 1 point. The current score is #{@score}."
				puts "The correct answer is: #{find_solution}"
			end
		else
			puts find_solution
		end
	end


	def find_solution
		hand = @hand.sort.reverse # => [a, b, c, d] where [a-d] represent the value of a card in descending order
		combos_ab = ["#{hand[0]} + #{hand[1]}", "#{hand[0]} - #{hand[1]}", "#{hand[0]} * #{hand[1]}", "#{hand[0].to_f} / #{hand[1]}"]
		combos_cd = ["#{hand[2]} + #{hand[3]}", "#{hand[2]} - #{hand[3]}", "#{hand[2]} * #{hand[3]}", "#{hand[2].to_f} / #{hand[3]}"]

		combos_ac = ["#{hand[0]} + #{hand[2]}", "#{hand[0]} - #{hand[2]}", "#{hand[0]} * #{hand[2]}", "#{hand[0].to_f} / #{hand[2]}"]
		combos_bd = ["#{hand[1]} + #{hand[3]}", "#{hand[1]} - #{hand[3]}", "#{hand[1]} * #{hand[3]}", "#{hand[1].to_f} / #{hand[3]}"]

		combos_ad = ["#{hand[0]} + #{hand[3]}", "#{hand[0]} - #{hand[3]}", "#{hand[0]} * #{hand[3]}", "#{hand[0].to_f} / #{hand[3]}"]
		combos_bc = ["#{hand[1]} + #{hand[2]}", "#{hand[1]} - #{hand[2]}", "#{hand[1]} * #{hand[2]}", "#{hand[1].to_f} / #{hand[2]}"]

		solution = find_solution_3x1(combos_ab, hand[2], hand[3]) ||
			find_solution_3x1(combos_cd, hand[0], hand[1]) ||
			find_solution_3x1(combos_ac, hand[1], hand[3]) ||
			find_solution_3x1(combos_bd, hand[0], hand[2]) ||
			find_solution_3x1(combos_ad, hand[1], hand[2]) ||
			find_solution_3x1(combos_bc, hand[0], hand[3]) ||
			find_solution_2x2(combos_ab, combos_cd) ||
			find_solution_2x2(combos_ac, combos_bd) ||
			find_solution_2x2(combos_ad, combos_bc) ||
			"No solution"
	end

	def find_solution_2x2 (combos1, combos2)
		add(combos1, combos2) ||
		multiply(combos1, combos2) ||
		subtract(combos1, combos2) ||
		divide(combos1, combos2)
	end

	def add(combos1, combos2)
		combos1.find do |combo1|
			combos2.find do |combo2|
				if eval(combo1) + eval(combo2) == 24
					return "(#{combo1}) + (#{combo2}) = 24"
				end
			end
		end
	end

	def multiply(combos1, combos2)
		combos1.find do |combo1|
			combos2.find do |combo2|
				if eval(combo1) * eval(combo2) == 24
					return "(#{combo1}) * (#{combo2}) = 24"
				end
			end
		end
	end

	def subtract(combos1, combos2)
		combos1.find do |combo1|
			combos2.find do |combo2|
				if eval(combo1) - eval(combo2) == 24
					return "(#{combo1}) - (#{combo2}) = 24"
				end
			end
		end
	end

	def divide(combos1, combos2)
		combos1.find do |combo1|
			combos2.find do |combo2|
				if eval(combo2) != 0 && eval(combo1) / eval(combo2) == 24 && eval(combo1) % eval(combo2) == 00
					return "(#{combo1}) / (#{combo2}) = 24"
				end

			end
		end
	end

	def find_solution_3x1(combos, card1, card2)
		combos.find do |combo|
			c = eval(combo)

			if (c + card1) * card2 == 24
				return "(#{combo} + #{card1}) * #{card2} = 24"
			elsif (c + card1) / card2 == 24
				return "(#{combo} + #{card1}) / #{card2} = 24"
			elsif (c + card2) * card1 == 24
				return "(#{combo} + #{card2}) * #{card1} = 24"
			elsif (c + card2) / card1 == 24
				return "(#{combo} + #{card2}) / #{card1} = 24"
			elsif (c - card1) * card2 == 24
				return "(#{combo} - #{card1}) * #{card2} = 24"
			elsif (c - card1) / card2 == 24
				return "(#{combo} - #{card1}) / #{card2} = 24"
			elsif (c - card2) * card1 == 24
				return "(#{combo} - #{card2}) * #{card1} = 24"
			elsif (c - card2) / card1 == 24
				return "(#{combo} - #{card2}) / #{card1} = 24"
			elsif c * card1 - card2 == 24
				return "(#{combo}) * #{card1} - #{card2} = 24"
			elsif c * card1 + card2 == 24
				return "(#{combo}) * #{card1} + #{card2} = 24"
			elsif c * card2 - card1 == 24
				return "(#{combo}) * #{card2} - #{card1} = 24"
			elsif c * card2 + card1 == 24
				return "(#{combo}) * #{card2} + #{card1} = 24"
			elsif c / card1 - card2 == 24
				return "(#{combo}) / #{card1} - #{card2} = 24"
			elsif c / card1 + card2 == 24
				return "(#{combo}) / #{card1} + #{card2} = 24"
			elsif c / card2 - card1 == 24
				return "(#{combo}) / #{card2} - #{card1} = 24"
			elsif c / card2 + card1 == 24
				return "(#{combo}) / #{card2} + #{card1} = 24"
			elsif (card1 - c) * card2 == 24
				return "(#{card1} - (#{combo})) * #{card2} = 24"
			elsif (card1 - c) / card2 == 24
				return "(#{card1} - (#{combo})) / #{card2} = 24"
			elsif (card2 - c) * card1 == 24
				return "(#{card2} - (#{combo})) * #{card1} = 24"
			elsif (card2 - c) / card1 == 24
				return "(#{card2} - (#{combo})) / #{card1} = 24"
			elsif c != 0
				if card1 / c - card2 == 24
					return "#{card1} / (#{combo}) - #{card2} = 24"
				elsif card1 / c + card2 == 24
					return "#{card1} / (#{combo}) + #{card2} = 24"
				elsif card2 / c - card1 == 24
					return "#{card2} / (#{combo}) - #{card1} = 24"
				elsif card2 / c + card1 == 24
					return "#{card2} / (#{combo}) + #{card1} = 24"
				end
			end
		end
	end

	#def countdown
	#	puts "You have 10 seconds to enter a correct solution. (Refer to each card by letter)"
	#	@count = 10
	#	10.times do
	# 		print "#{count}..."
	# 		sleep(1)
	# 		@count -= 1
	# 		break if player_input
	# 	end
	# 	puts "Times up!"
	# 	@count
	# end

	def terminal?
		if @deck.length == 0
			return true
		else
			return false
		end
	end

	def announce
		puts "The final score is #{@score}."
		if @score[0] == @score[1]
			puts "You tied!"
		else
			if @game_mode == 1
				puts @score[0] > @score[1] ? "You win!" : "The computer wins!"
			else
				puts @score[0] > @score[1] ? "Player 1 wins!" : "Player 2 wins!"
			end
		end
	end
end

Make24.new.play