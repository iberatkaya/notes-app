import Foundation

struct User: Codable {
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
    
    ///The email of the user.
    var email: String
    
    ///The password of the user.
    var password: String
}
