#!/usr/bin/env ruby
require_relative './game_mechanics.rb'
require_relative './find_solution'

class GameOnConsole < GameMechanics
	def initialize(deck, num_of_players)
		super(deck, num_of_players)
		@buzzers = []
	end

	def play
		intro
		pick_buzzer
		until terminal?
			show_hand
			player_move
			show_score
		end
		announce
	end

	def intro
		puts "--** Welcome to Make 24! **--"
		puts "Press 'r' to read the rules. Press any other key to play."
		print ">"
		read_rules
	end

	def read_full_rules?
		r = gets.chomp
		r == 'r'
	end

	def read_rules
		rules = File.open ("rules.txt")
		if read_full_rules?
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

	def pick_buzzer
		@num_of_players.times do |p|
			puts "Player #{p+1}, select a key to be your buzzer (except 'n')."
			b = gets.chomp
			if b.length != 1 || b == 'n' || @buzzers.include?(b)
				puts "Nope. Please select only one key (except 'n')."
				b = gets.chomp
			end
			puts "Player #{p+1}, your buzzer is '#{b}'."
			@buzzers << b
		end
	end

	def show_hand
		puts "Ready..."
		sleep(2)
		draw_hand.each { |n| print "|#{n}|   " }; print "\n"
	end

	def player_move
		b = buzzer
		if give_up?(b)
			s = solution
			if s
				puts "The answer is: #{s}"
			else
				puts "No solution."
			end
		else
			p = id_player(b)
			get_answer(p)
			if make24?
				change_score(p, 1)
				puts "Good job. That definitely makes 24!"
			else
				change_score(p, -1)
				puts "Sorry, the correct answer is: #{solution}"
			end
		end
	end

	def buzzer
		buzzer = gets.chomp
		until buzzer == 'n' || @buzzers.include?(buzzer)
			puts "Invalid input. Press your buzzer or press 'n' if there's no solution."
			buzzer = gets.chomp
		end
		buzzer
	end

	def id_player(buzzer)
		@buzzers.index(buzzer)
	end

	def give_up?(buzzer)
		buzzer == 'n'
	end

	def get_answer(player)
		puts "Player #{player+1}, enter an equation to make 24:"
		self.player_answer = gets.chomp

		until input_valid?
			puts "Nope, try again: "
			self.player_answer = gets.chomp.downcase
		end
	end

	def solution
		FindSolution.new(*@hand).print_solution
	end

	def change_score(player, amount)
		@score[player] += amount
	end

	def show_score
		puts "Score: #{@score}"
	end

	def announce
		puts "Game over. The final score is #{@score}."
		announce_winner if @num_of_players > 1
	end

	def announce_winner
		if @score.max == @score.min
			puts "You tied!"
		else
			puts "Winner(s): "
			@score.length.times { |s| puts "Player #{s+1}" if @score[s] == @score.max}
			puts "Great job, you're a math champion! :)"
		end
	end
end