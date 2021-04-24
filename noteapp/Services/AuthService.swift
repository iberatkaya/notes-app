import Foundation
import SwiftyJSON

class AuthService {
    func signUp(name: String, email: String, password: String, completed: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "http://localhost:3000/auth/signup")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let data = ["name": name, "email": email, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            onError("JSON serialization error!")
            return
        }
        
        request.httpBody = jsonData

        let session = URLSession.shared
        session.dataTask(with: request) { data, _, error in
            if error != nil {
                onError("Error: \(String(describing: error))")
                return
            }
            guard let data = data else {
                onError("Data in nil!")
                return
            }
            
            let jsonData = JSON(data)
            
            if jsonData["success"] == false {
                onError("Error: \(jsonData["message"])")
                return
            }
            
            completed()
        }.resume()
    }
}
