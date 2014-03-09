var client = new Faye.Client('http://#{request.host}:9001/faye')
var channel = "/" +document.getElementById('channel').value;

client.subscribe('/15', function(message) {
    document.getElementById('messages').innerHTML += "<p>" + message.nickname + " : " + message.text + "</p>";
    document.getElementById('messages').scrollTop = 10000;
});


document.getElementById("content_message").addEventListener( "keydown", function( e ) {
    var keyCode = e.keyCode || e.which;
    if ( keyCode === 13 ) {
        say_hi();
    }
}, false);

function say_hi() {
    var text = document.getElementById('content_message').value;
    var nick = document.getElementById('nickname').value;
    content_message.value= ""
    document.getElementById('content_message').focus()
    client.publish(channel, {text: text, nickname: nick});
    document.getElementById("text").focus();
}