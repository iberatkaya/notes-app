import Foundation
import KeychainSwift

struct User: Encodable, Decodable {
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
    }
    
    /// The name of the user.
    var name: String
    
    /// The email of the user.
    var email: String
    
    /// The password of the user.
    var password: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        email = try values.decode(String.self, forKey: .email)
        
        //Store the password in the Keychain.
        let keychain = KeychainSwift()
        guard let password = keychain.get("password") else {
            throw "Password does not exist"
        }
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case email, name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
    }
}
