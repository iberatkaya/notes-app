import Foundation

/// Determines whether the base url should be the localhost or the remote server.
let production = true

/// The base url for the requests.
let baseUrl = production ? "https://ibk-note-app.herokuapp.com" : "http://localhost:3000"

/// Set the Basic Auth Header for a request
/// - Parameters:
///     - request: The request instance.
///     - email: The email of the user.
///     - password: The password of the user.
func setBasicAuthHeader(request: inout URLRequest, email: String, password: String) {
    let loginString = String(format: "%@:%@", email, password)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
}
