/// Determines whether the base url should be the localhost or the remote server.
let production = true

/// The base url for the requests.
let baseUrl = production ? "http://notes-app.us-west-2.elasticbeanstalk.com" : "http://localhost:3000"
