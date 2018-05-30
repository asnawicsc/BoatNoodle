var socket = new Phoenix.Socket("/socket", {
    params: {
        token: window.userToken
    }
});
socket.connect()
// Now that you are connected, you can join channels with a topic:
var topic = "user:" + window.currentUser
// Join the topic
let channel = socket.channel(topic, {})
channel.join()


    .receive("ok", data => {
        console.log("Joined topic", topic)
    })


    .receive("error", resp => {
        console.log("Unable to join topic", topic)
    })

var topic2 = "menu_item:" + window.currentUser
// Join the topic
let channel2 = socket.channel(topic2, {})
channel2.join()


    .receive("ok", data => {
        console.log("Joined topic", topic2)
    })


    .receive("error", resp => {
        console.log("Unable to join topic", topic2)
    })

var topic3 = "item:" + window.currentUser
// Join the topic
let channel3 = socket.channel(topic3, {})
channel3.join()


    .receive("ok", data => {
        console.log("Joined topic", topic3)
    })


    .receive("error", resp => {
        console.log("Unable to join topic", topic3)
    })

