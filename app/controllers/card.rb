get '/card/:card_id' do
  if current_user
    guessed_cards = []
    deck = Deck.find(params[:current_deck_id])
    round = Round.find_or_create_by(live: true, deck_id: params[:current_deck_id], user_id: current_user.id)
    Guess.where(id: round.guess_ids).each do |guess|
      guessed_cards << guess.card_id
      p guessed_cards
    end
    card_array = deck.card_ids - guessed_cards
    p card_array
    if card_array.length == 0 || guessed_cards.count > 9
      round.update_attributes(live: 'false')
      redirect "/deck_select?round_over=true"
    end
    flash_card = Card.find(card_array.sample)
    guesses = round.guesses.all.count
    correct = 0
    round.guesses.all.each do |guess|
      correct += 1 if guess.result
    end

    erb :"/card/show", locals:{flash_card: flash_card, correct: correct, guesses: guesses}
  else
    redirect "/"
  end
end

post '/card/:card_id' do
  card = Card.find(params[:card_id])
  round = Round.find_by(live: true, user_id: current_user.id)
  guess = Guess.create(round: round, card_id: params[:card_id], result: (card.answer.downcase == params[:answer].downcase))
  round.guesses << guess
  redirect "/card/#{params[:card_id]}?current_deck_id=#{card.deck_id}"
end


after do
    ActiveRecord::Base.connection.close
end