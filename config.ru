require './config/environment'

Faye::WebSocket.load_adapter('thin')

run GamersOnline