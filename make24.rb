#!/usr/bin/env ruby

require_relative './find_solution'

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
		rules = File.open ("rules.txt")
		if r == 'r' #put the following text in separate file intro.txt
			print rules.read
			STDIN.gets
		else
			line_num = 0
			rules.each_line do |line|
				puts line.chomp if line_num >=3 && line_num <= 5
				line_num += 1
			end
		end
		rules.close
	end

#Select 4 random cards from the deck, delete these cards from the deck and show hand
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

#Get player's answer, validate answer structure, and keep track of which player using buzzer key
	def buzzer
		buzzer_id = gets.chomp
		until buzzer_id == 'n' || buzzer_id == 'a' || buzzer_id == 'l'
			puts "Invalid input. Press your buzzer or press 'n' if there's no solution."
			buzzer_id = gets.chomp
		end
		return buzzer_id
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

			until validated?(player_input, player_input_num)
				puts "Nope, try again: "
				player_input = gets.chomp.downcase
				player_input_num =player_input.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?).map(&:to_i)
			end

			@player_answer = [player_input, player_id]
		end
		return @player_answer
	end

	def validated?(player_input, player_input_num)
		reg = /\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/
		unless (player_input.match reg) && player_input_num.sort == @hand.sort
			return false
		else
			return true
		end
	end

#Check whether player's answer is correct. If not, or if no answer entered, computer finds the solution
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
			puts print_solution
		end
	end

	def find_solution
		FindSolution.new(*@hand.sort.reverse).solution
	end

	def add_paren(s)
		if s[2]
			"((#{s[0][0]} #{s[1][0]} #{s[0][1]}) #{s[1][1]} #{s[0][2]}) #{s[1][2]} #{s[0][3]}"
		else
			"(#{s[0][0]} #{s[1][0]} #{s[0][1]}) #{s[1][1]} (#{s[0][2]} #{s[1][2]} #{s[0][3]})"
		end
	end

	def print_solution
		s = find_solution
		if s
			add_paren(s)
		else
			"No solution."
		end
	end

#Check if the game has ended. If so, announce winner or tie.
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
			puts @score[0] > @score[1] ? "Player 1 wins!" : "Player 2 wins!"
		end
	end
end

Make24.new.play