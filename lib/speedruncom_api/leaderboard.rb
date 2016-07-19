class SpeedrunComAPI::Leaderboard
  ENDPOINT = 'leaderboards/%{game}/category/%{category}'

  attr_accessor :game, :category

  def initialize game, category
    self.game = game
    self.category = category
  end

  def load
    $conn.get(ENDPOINT % { game: game, category: category })
  end
end