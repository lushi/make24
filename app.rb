require 'sinatra'
require 'securerandom'
require_relative './lib/find_solution'
require_relative './lib/game_mechanics'

enable :sessions

STD_DECK = (1..10).to_a * 4 + [1, 1, 1] * 4

games_db = {}


class Make24App < GameMechanics
	def solution
		FindSolution.new(*@hand).print_solution
	end
end

get '/' do
  session[:id] = SecureRandom.uuid
  games_db[session[:id]] = Make24App.new(STD_DECK.dup, 1)
  erb :home
end

get '/play' do
	if games_db[session[:id]].nil?
		redirect '/'
	else
		unless games_db[session[:id]].terminal?
			@score = games_db[session[:id]].score[0]
			@hand = games_db[session[:id]].draw_hand
			erb :play
		else
			@score = games_db[session[:id]].score[0]
			games_db.delete(session[:id])
			erb :announce
		end
	end
end

def get_session_id(env)
	env["rack.session.unpacked_cookie_data"]["id"]
end

post '/solution' do
	session_id = get_session_id(env)
	@hand = games_db[session_id].hand
	@solution = games_db[session_id].solution || 0
	games_db[session_id].score[0] -= 1 unless @solution == nil
	@score = games_db[session_id].score[0]
	erb :play
end

post '/validate' do
	session_id = get_session_id(env)
	games_db[session_id].player_answer = params[:player_answer]
	if games_db[session_id].input_valid?
		if games_db[session_id].make24?
			games_db[session_id].score[0] += 1
			erb :message_right
		else
			games_db[session_id].score[0] -= 1
			@solution = games_db[session_id].solution
			erb :message_wrong
		end
	else
		@hand = games_db[session_id].hand
		@score = games_db[session_id].score[0]
		erb :replay
	end
end