class Message

  def create
    @message = Message.create!(params[:message])
    broadcast("/messages/new", @message)
    render :json => @message
  end

  private

  def broadcast(channel, object)
    message = {:channel => channel, :data => { :object => object, :type => "message" } }
    uri = URI.parse("http://localhost:9292/faye")
    Net::HTTP.post_form(uri, :message => message.to_json)
  end
end