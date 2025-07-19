class Card
  def initialize(card, value)
    @card = card
    @value = value
  end

  attr_accessor :value
end

class Deck
  def initialize
    card_values = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']
    @cards = card_values.map.with_index(2) { |card, value| Card.new(card, value) } * 4
    @cards.shuffle!
  end

  attr_accessor :cards

end

class Player
  def initialize(label, cards)
    puts "Player #{label} has joined the game!"
    @label = label
    @cards = cards
  end

  attr_accessor :label, :cards
end

class WarGame
  def initialize
    puts "How many players?"
    @num_of_players = gets.chomp.to_i
    raise "Only 2 or 4 players allowed" unless [2, 4].include?(@num_of_players)
    @deck = Deck.new
    @players = []
    @num_of_players.times do |index|
      @players << Player.new(index + 1, @deck.cards.shift(52 / @num_of_players))
    end
  end

  def play
    while (continue_game?) do
      commence_round
      eliminate_players
    end
    winner = @players.first
    puts "Player #{winner.label} wins!"
  end

  private

  def commence_round
    players_with_cards = Hash.new
    @players.each do |player|
      players_with_cards[player] = player.cards.shift
    end
    evaluate_cards_in_play(players_with_cards)
  end

  def evaluate_cards_in_play(cards, accumulated = [])
    accumulated.concat(cards.values)

    highest_card = cards.values.map(&:value).max
    winning_players = cards.each_key.select { |x| cards[x].value == highest_card }

    if winning_players.size == 1
      # Noticed an infinite loop as we're evaluating the same card order
      winning_players.first.cards.concat(accumulated.shuffle)
      puts "Player #{winning_players.first.label} wins the round."
    else
      tie_breaker(winning_players, accumulated)
    end
  end

  def tie_breaker(winners, accumulated)
    war_cards = {}

    winners.each do |player|
      if player.cards.size > 1
        face_down_count = [3, player.cards.size - 1].min
        face_down_count.times { accumulated << player.cards.shift }
      end

      face_up_card = player.cards.shift
      if face_up_card
        war_cards[player] = face_up_card
      else
        puts "Player #{player.label} has no cards left to play"
      end
    end

    evaluate_cards_in_play(war_cards, accumulated)
  end

  def eliminate_players
    @players = @players.reject { |player| player.cards.empty? }
  end

  def continue_game?
    @players.none? { |player| player.cards.size == 52 } && @players.size > 1
  end


end

game = WarGame.new
game.play
