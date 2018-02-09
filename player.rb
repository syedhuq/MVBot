class Player
  def initialize(name, id)
    @player_name = name
    @player_id = id
    @score = 0
  end
  
  def match(id)
    id == @player_id
  end
  
  def rank_to_str()
    return "\n**#{@player_name}** - #{@score} points"
  end
  
  def get_score()
    @score
  end
  
  def give_point()
    @score += 1
  end
end