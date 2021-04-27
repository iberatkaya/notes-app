import Foundation
import KeychainSwift
import SwiftyJSON

struct User: Codable {
    init(id: String, name: String, email: String, password: String, active: Bool) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.active = active
    }
    
    init(json: JSON, password: String) {
        self.id = json["_id"].string ?? ""
        self.name = json["name"].string ?? ""
        self.email = json["email"].string ?? ""
        self.password = password
        self.active = json["active"].bool ?? false
    }
    
    /// The name of the user.
    var name: String
    
    /// The email of the user.
    var email: String
    
    /// The password of the user.
    var password: String
    
    /// The user's email verification status..
    var active: Bool
    
    /// The ID of the user.
    var id: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        email = try values.decode(String.self, forKey: .email)
        id = try values.decode(String.self, forKey: ._id)
        active = try values.decode(Bool.self, forKey: .active)
        
        // Store the password in the Keychain.
        let keychain = KeychainSwift()
        guard let password = keychain.get("password") else {
            throw "Password does not exist"
        }
        self.password = password
    }
    
    enum CodingKeys: String, CodingKey {
        case email, name, _id, active
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encode(id, forKey: ._id)
        try container.encode(active, forKey: .active)
    }
}
