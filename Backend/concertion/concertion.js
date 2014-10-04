Concertions = new Mongo.Collection("concertions")

if (Meteor.isServer) {
  Meteor.startup(function () {
    Concertions.remove({})
    Concertions.insert({
      name: "Hello world",
      currentTrack: {
        "title": "Some track",
        "artistName": "Some artist",
        "imageURL": "asdf",
        "streamingURL": "http://sverigesradio.se/topsy/ljudfil/4119397.mp3"
      },
      playing: true,
      time: {
        "setAt": Date.now(),
        "offset": 0
      }
    })
    Meteor.publish("concertions", function() {
      return Concertions.find()
    })
  });
}


if (Meteor.isClient) {
  Meteor.subscribe("concertions")
}

