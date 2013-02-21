#!/usr/bin/env ruby
class Make24
	STD_DECK = (1..10).to_a * 4 + [1, 1, 1] * 4

	def initialize
		@deck = STD_DECK
		@game_mode
		@hand
		@player_answer
		@score = [0, 0]
	end

	def play
		intro
		game_mode
		until terminal?
			show_hand
			player_input
			check_player_answer
		end
		announce
	end

	def intro
		puts "--** Welcome to Make 24! **--"
		puts "Press 'h' for instructions. Press any other key to play."
		print ">"
		r = gets.chomp.downcase
		if r == 'h' #put the following text in separate file intro.txt
			puts "4 cards are displayed at a time. As quickly as you can, try to make 24 by combining the cards with +, -, *, /, (, and )."
			puts "Press the assigned buzzer when you are ready." #You will have 10 seconds to type in the correct solution. --Not possible?
			puts "You will receive 1 point for a correct solution. You will lose 1 point for a wrong solution."
			puts "If no solution is possible, there will be no change to the score."
			puts "The game ends when all cards in the deck are played or if there are no possible solutions left."
			print "Press any key to continue.\n> "
			STDIN.gets
		end
	end

	def game_mode
		print "Select game mode:\nPress 1 for single player game.\nPress 2 for two player game.\n> "
		@game_mode = gets.chomp.to_i

		until @game_mode == 1 || @game_mode == 2
			print "Nope, try again:\nPress 1 for single player game.\nPress 2 for two player game.\n> "
			@game_mode = gets.chomp.to_i
		end

		if @game_mode == 1
			puts "You are Player 1. Your buzzer is 'a'."
			puts "Press 'n' if you think there is no solution."
			puts "Press any key to continue"
			print "> "
		else
			puts "Player 1's buzzer is 'a'. Player 2's buzzer is 'l'."
			puts "Press 'n' if you think there is no solution."
			puts "Press any key to continue"
			print "> "
		end
		STDIN.gets
		@game_mode
	end

	def show_hand
		@hand = draw_hand
		puts "Ready..."
		sleep(2)
		puts "a: |#{@hand['a']}|  b: |#{@hand['b']}|  c: |#{@hand['c']}|  d: |#{@hand['d']}|"
	end

	def draw_hand
		hand = {'a' => nil, 'b' => nil, 'c' => nil, 'd' => nil}

		hand['a'] = @deck[rand(@deck.length)]
		@deck.delete_at(@deck.index(hand['a']))

		hand['b'] = @deck[rand(@deck.length)]
		@deck.delete_at(@deck.index(hand['b']))

		hand['c'] = @deck[rand(@deck.length)]
		@deck.delete_at(@deck.index(hand['c']))

		hand['d'] = @deck[rand(@deck.length)]
		@deck.delete_at(@deck.index(hand['d']))

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
			puts "Player #{player_id}, enter an equation to make 24 (refer to each card by letter):"
			player_input = gets.chomp.downcase
			player_input_char = player_input.split(//)
			player_input_char.delete(" ")

			until validated?(player_input, player_input_char)
				puts "Nope, try again: "
				player_input = gets.chomp.downcase
				player_input_char = player_input.split(//)
				player_input_char.delete(" ")
			end

			@player_answer = [player_input, player_id]
		end
		return @player_answer
	end

	def check_player_answer
		if @player_answer
			player_eq = write_equation(@player_answer)

			if eval(player_eq) == 24
				@score[@player_answer[1] - 1] += 1
				puts "That's correct! Player #{@player_answer[1]} gets 1 point. The current score is #{@score}."
			else
				@score[@player_answer[1] - 1] -= 1
				puts "That's incorrect. Player #{@player_answer[1]} loses 1 point. The current score is #{@score}."
				# puts "The correct answer is: "
			end
		#else
			#evaluate whether it's possible
		end
	end

	def write_equation(player_answer)
		player_eq = player_answer[0].gsub(/[a-d]/) {|l| @hand[l] }
	end

	# def check_input
	# 	{'*' => *}
	# end

	def buzzer
		buzzer_id = gets.chomp
		until buzzer_id == 'n' || buzzer_id == 'a' || buzzer_id == 'l'
			puts "Invalid input. Press your buzzer or press 'n' if there's no solution."
			buzzer_id = gets.chomp
		end
		return buzzer_id
	end

	def validated?(player_input, player_input_char) #USE REGEX TO CAPTURE AND THEN COMPARE TO CHAR
		re = /\A\({0,3}\s*[a-d]\s*(\*|\+|-|\/)\s*\({0,2}\s*[a-d]\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*[a-d]\s*\){0,2}\s*(\*|\+|-|\/)\s*[a-d]\s*\){0,3}\z/
		valid_chars = %w(a b c d + - * / ( ))
		if !player_input.match re #match agains regexp
			return false
		elsif player_input_char.find { |char| !valid_chars.include? char } #must use valid_chars only
			return false
		elsif valid_chars[0,4].find { |letter| player_input_char.count(letter) != 1 } #use every card once
			return false
		else
			return true
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
		#elsif rest of the cards are not possible
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
