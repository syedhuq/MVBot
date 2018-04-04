require 'discordrb'
require_relative "player"

#Constants
NUM_IMAGES = 182
server_id = 277188495728967681
gm_id = 430164410552549386 # role id for guess gm
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
engaged ||= false
players = []
guess_gm_role = bot.server(server_id).role(gm_id)

artist_current = "", title_current = ""
artists_file = "artists.txt"
titles_file = "titles.txt"
artists = []
titles = []
IO.foreach(artists_file){|line| artists.push(line.strip)}
IO.foreach(titles_file){|line| titles.push(line.strip)}

bot.command :help do |event|
  str = [
    "***Regular Commands:***",
    "-You can join and quit a game with **?join** and **?quit**.",
    "-You can see the current leaderboard with **?scores**.",
    "\n***Admin Commands:***",
    "-You can start and end a session with **?guess** and **?end**.",
    "-Display the next picture with **?next**.",
    "\n***Answers:***",
    "-Answers __must__ contain the whole artist and whole title.",
    "-They do not, however, need to match case - answering in all uppercase is the same as all lowercase.",
    "-Punctuation in words is ignored, but you can't have any other words in between the words of an artist or title."
  ]
  event.respond(str.join("\n"))
end


bot.command :guess, required_roles:[guess_gm_role] do |event|
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
      event.respond("**#{event.user.username}** joined the game!")
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
      event.respond("**#{event.user.username}** has quit!")
    end
  else
    event.respond("There is no game in progress right now!")
  end
end


bot.command :end, required_roles:[guess_gm_role] do |event|
  if in_progress
    in_progress = false
    rankings = ""
    players.sort_by(&:get_score)
    players.each{|player| rankings<<player.rank_to_str()}
    players.clear()
    event.respond("The game is over. Use ?guess to start a new one. Here are the rankings: #{rankings}")
  else
    event.respond("There is no game in progress right now!")
  end
end

bot.command :scores do |event|
  if in_progress
    if players.empty?
      event.respond("No one has joined the game yet!")
    else
      rankings = ""
      players.sort_by(&:get_score)
      players.each{|player| rankings<<player.rank_to_str()}
      event.respond("Here are the rankings: #{rankings}")
    end
  else
    event.respond("There is no game in progress right now!")
  end
end

bot.command :next, required_roles:[guess_gm_role] do |event|
  if in_progress
    #test_arr = [70,47,131,174,95]
    #randTest = rand(test_arr.size)
    #randVal = test_arr[randTest]-1
    
    randVal = rand(NUM_IMAGES)
    f = File.new("pics/"+(randVal+1).to_s+".png", "r")
    engaged = true
    artist_current = artists[randVal].strip
    title_current = titles[randVal].strip
    event.respond("Ok! Guess the MV!")
    event.channel.send_file(f)
    puts "#{artist_current} - #{title_current}"
  else
    event.respond("There is no game in progress right now!")
  end
end

bot.message do |event|
  if in_progress && engaged
    loc = players.find_index{|player| player.match(event.user.id)}
    if loc != nil
      title_words = title_current.gsub(/[[:punct:]]/, '').split(/\s+/)
      title_words.shift
      puts "title_words: #{title_words}"
      artist_words = artist_current.gsub(/[[:punct:]]/, '').split(/\s+/)
      artist_words.shift
      puts "artist_words: #{artist_words}"
      
      guess = event.message.text.strip.downcase.gsub(/[[:punct:]]/, '')#.gsub(/[^[\w\s\d]]/, '')
      puts "guess: #{guess}"
      title_reg = /\b#{Regexp.quote(title_words.join(' '))}\b/
      artist_reg = /\b#{Regexp.quote(artist_words.join(' '))}\b/
      if title_reg.match(guess) and artist_reg.match(guess)
        engaged = false
        event.respond("**#{event.user.username}** gets a point!")
        players[loc].give_point
      end
    end
  end
end

bot.run(true) # async
bot.game = "use ?help"
bot.sync