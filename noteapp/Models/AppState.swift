import ReSwift
import Foundation

struct AppState: StateType {
    var user: User? {
        didSet {
            if let encodedUser = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(encodedUser, forKey: "user")
            }
        }
    }

    init() {
        if let userData = UserDefaults.standard.object(forKey: "user") {
            if let myData = try? JSONDecoder().decode(User.self, from: userData as! Data) {
                self.user = myData
            }
        }
    }
}
