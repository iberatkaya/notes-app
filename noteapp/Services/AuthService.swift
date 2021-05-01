import Foundation
import SwiftyJSON

class AuthService {
    
    /// Sign up for an account.
    /// - Parameters:
    ///     - name: The username of the user..
    ///     - title: The email of the user.
    ///     - body: The password of the user.
    ///     - completed: The clousure called when the request is successful.
    ///     - onError: The clousure called when the request failed or an error occured.
    func signUp(name: String, email: String, password: String, completed: @escaping (User) -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/auth/signup")!
        
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
            
            let user = User(json: jsonData["data"], password: password)
            
            completed(user)
        }.resume()
    }
}
