class GameMechanics
	attr_reader :deck, :num_of_players, :hand, :player_answer
	attr_accessor :score
	def initialize(deck, num_of_players)
		@deck = deck
		@num_of_players = num_of_players
		@score = [0] * @num_of_players
	end

	def draw_hand
		@hand = @deck.sample(4).each {|card| @deck.delete_at(@deck.index(card))}
	end

	def player_answer=(input)
		@player_answer = input
	end

	def input_valid?
		match_regexp? && right_num? && complete_paren?
	end

	def match_regexp?
		reg = /\A\({0,3}\s*\d{1,2}\s*(\*|\+|-|\/)\s*\({0,2}\s*\d{1,2}\s*\)?\s*(\*|\+|-|\/)\s*\(?\s*\d{1,2}\s*\){0,2}\s*(\*|\+|-|\/)\s*\d{1,2}\s*\){0,3}\z/
		(@player_answer.match reg) ? true : false
	end

	def right_num?
		player_input_num = @player_answer.gsub(/(\(|\)|\*|\+|-|\/)/, " ").split(" ").reject(&:empty?).map(&:to_i)
		player_input_num.sort == @hand.sort
	end

	def complete_paren?
		openp = @player_answer.split(//).select {|c| c == '('}
		closep = @player_answer.split(//).select {|c| c == ')'}
		openp.length == closep.length
	end

	def make24?
		input_valid? ? eval(@player_answer) == 24 : false
	end

	def response_to_player(m_right, m_wrong, player=0)
		if make24?
			@score[player] += 1
			message = m_right
		else
			@score[player] += 1
			message = m_wrong
		end
		message
	end

	def terminal?
		@deck.length == 0
	end
end