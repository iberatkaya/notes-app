import Foundation
import SwiftyJSON

class NoteService {
    init(user: User) {
        self.user = user
    }
    
    private let user: User
    
    /// Create a note for the user.
    /// - Parameters:
    ///     - title: The title of the note.
    ///     - body: The body content of the note.
    ///     - completed: The clousure called when the request is successful.
    ///     - onError: The clousure called when the request failed or an error occured.
    func createNote(title: String, body: String, completed: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "http://localhost:3000/note/addnote")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = String(format: "%@:%@", user.email, user.password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let data = ["body": body, "title": title]

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
    
    /// Fetch the notes of the user.
    /// - Parameters:
    ///     - page: The page of the request.
    ///     - completed: The clousure called when the request is successful.
    ///     - onError: The clousure called when the request failed or an error occured.
    func fetchNotes(page: Int, completed: @escaping ([Note]) -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "http://localhost:3000/note/getnotes?page=\(page)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = String(format: "%@:%@", user.email, user.password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

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
            
            guard let notesData = jsonData["data"].string?.data(using: .utf8) else {
                onError("Note data error!")
                return
            }
            
            let decoder = JSONDecoder()
                
            // Parse date from Express.js.
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .init(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            guard let notes = try? decoder.decode([Note].self, from: notesData) else {
                onError("Note data error!")
                return
            }
            
            completed(notes)
        }.resume()
    }
}
