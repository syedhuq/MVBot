require 'discordrb'
require_relative "player"
require 'timers' 

#Constants
NUM_IMAGES = 27
#------------------------------------------------------------------------------------------------------------------------------------------------------------
tk = File.open('token.txt', &:readline)
tk = tk.strip
bot = Discordrb::Commands::CommandBot.new(
  token: tk, 
  client_id: 408851146959224856,
  prefix: '?'
)
puts "This bot's invite URL is #{bot.invite_url}."
in_progress ||= false
players = []
timers = Timers::Group.new

bot.command :guess do |event|
  if !in_progress
    in_progress = true
    event.respond("Starting a game! Use ?join if you want to play.")
  else
    event.respond("There's already a game in progress right now!")
  end
end

bot.command :join do |event|
  if in_progress
    if players.none?{|player| player.match(event.user.id)}
      players.push(Player.new(event.user.username, event.user.id))
      event.respond("#{event.user.username} joined the game!")
    else
      event.respond("You have already joined!")
    end
  else
    event.respond("There is no game in progress right now!")
  end
end

  
bot.command :quit do |event|
  if in_progress
    loc = players.find_index{|player| player.match(event.user.id)}
    if loc == nil
      event.respond("You are not in the game!")
    else
      players.delete_at(loc)
      event.respond("#{event.user.username} has quit!")
    end
  else
    event.respond("There is no game in progress right now!")
  end
end


bot.command :end do |event|
  if in_progress
    in_progress = false
    rankings = ""
    players.sort_by(&:get_score)
    players.each{|player| rankings<<player.rank_to_str()}
    players.clear()
    event.respond("The game is over. Use !guess to start a new one. Here are the rankings: #{rankings}")
  else
    event.respond("There is no game in progress right now!")
  end
end

bot.command :next do |event|
  randVal = rand(NUM_IMAGES).to_s
  event.respond("Ok! Guess the MV!")
  f = File.new("pics/"+randVal+".png", "r")
  event.channel.send_file(f)
end

def set_pic(num)
  
end


=begin
looping ||= false
bot.command :start do |event|
  looping = true
  
  $pic_timer = timers.every(5) {event.respond("test")}
  loop {timers.wait}
  $pic_timer.resume
end

bot.command :stop do |event|
  looping = false
  $pic_timer.pause
end
=end

bot.run()