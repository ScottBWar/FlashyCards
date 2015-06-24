get '/deck/new' do
   if current_user
     erb :"deck/new"
   else
    redirect '/'
   end
end

post '/deck/new' do
  deck_1 = Deck.create(name: params[:name], user_id: session[:user_id])
  redirect "/deck/#{deck_1.id}/card/new"
end

get '/deck/:deckid/edit' do
  if current_user
    deck = Deck.find_by(id: params[:deckid])
    erb :"deck/edit", locals: {deck_id: params[:deckid], deck_name: deck.name }
  else
    redirect '/'
  end
end

put '/deck/:deckid/edit' do
  value = Deck.find_by(id: params[:deckid])
  value.update_attributes( name: params[:name])
  redirect "/deck_select"
end

delete '/deck/:deckid/edit' do
  deck_delete = Deck.find_by(id: params[:deckid])
  deck_delete.cards.destroy_all
  deck_delete.destroy
  redirect "/deck_select"
end

get '/deck/edit' do
  if current_user
    all_decks = Deck.where(user_id: current_user.id)
    erb :"deck/all_edit", locals: {all_decks: all_decks}
  else
    redirect '/'
  end
end

get '/deck_select' do
  if current_user
    all_decks = Deck.all
    last_deck = all_decks.last
    live_rounds = Round.where(live:true, user_id: current_user.id).count
    while live_rounds > 0
      round = Round.find_by(live:true, user_id: current_user.id)
      round.update_attributes(live: false)
      live_rounds = Round.where(live:true, user_id: current_user.id).count
    end
    if last_deck.cards.count < 5
      last_deck.cards.destroy_all
      last_deck.destroy
      erb :"/deck/all", locals: {all_decks: all_decks, deck_select: true}
    else
      erb :"/deck/all", locals: {all_decks: all_decks, deck_select: false}
    end
  else
    redirect "/"
  end
end

get "/deck/:deckid/card/new" do
  if current_user

    erb :"card/new" ,locals: {deck_id: params[:deckid]}

  else
    redirect '/'
  end
end

post "/deck/:deckid/card" do
  new_card = Card.new(question: params[:question], answer: params[:answer], deck_id: params[:deckid])
  new_card.save
  redirect "/deck/#{params[:deckid]}/card/new"
end

after do
    ActiveRecord::Base.connection.close
end