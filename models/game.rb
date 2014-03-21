class Game
  include DataMapper::Resource

  property :appid, Integer, :key => true
  property :title, String
  property :logo, String, :required => true


  has n, :taggings
  has n, :genres, through:  :taggings
  has n, :lobbies
  has n, :ownerships
  has n, :users, through: :ownerships
  def self.import_games(steamid)
    api_key = "8DA685124F4E525EC2A97F2C932F3763"

    #gets all the games of the user with steams api
    games = JSON.parse(Net::HTTP.get(URI("http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{api_key}&steamid=#{steamid}&include_appinfo=1&include_played_free_games=1")))['response']['games']


    games.each do |game|
      #adds games that arent in the database allready
      Game.first_or_create(appid: game['appid'], title: game['name'], logo: game['img_logo_url'])
      #adds ownership so that the user is linked to his games
      Ownership.first_or_create(game_appid: game['appid'], user_steamid: steamid)

    end
  end

end