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
    func createNote(title: String, body: String, completed: @escaping (Note) -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/note/addnote")!
        
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
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                onError("Error: \(String(describing: error))")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            guard status != 401 else {
                onError("Unauthorized user!")
                return
            }
            
            guard let data = data, JSON(data) != JSON.null else {
                onError("Data in nil!")
                return
            }
            
            let jsonData = JSON(data)
            
            if jsonData["success"] == false {
                onError("Error: \(jsonData["message"])")
                return
            }
            
            let note = Note(json: jsonData["data"])
            
            completed(note)
        }.resume()
    }
    
    /// Delete a note for the user.
    /// - Parameters:
    ///     - noteId: The ID of the note to be deleted.
    ///     - completed: The clousure called when the request is successful.
    ///     - onError: The clousure called when the request failed or an error occured.
    func deleteNote(noteId: String, completed: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/note/deletenote")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = String(format: "%@:%@", user.email, user.password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let data = ["noteId": noteId]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            onError("JSON serialization error!")
            return
        }
        
        request.httpBody = jsonData

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                onError("Error: \(String(describing: error))")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            guard status != 401 else {
                onError("Unauthorized user!")
                return
            }
            
            guard let data = data, JSON(data) != JSON.null else {
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
    
    /// Edit a note for the user.
    /// - Parameters:
    ///     - id: The ID of the note to be deleted.
    ///     - title: The note's optional title.
    ///     - body: The note's optional body.
    ///     - completed: The clousure called when the request is successful.
    ///     - onError: The clousure called when the request failed or an error occured.
    func editNote(id: String, title: String?, body: String?, completed: @escaping () -> Void, onError: @escaping (String) -> Void) {
        let url = URL(string: "\(baseUrl)/note/editnote")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = String(format: "%@:%@", user.email, user.password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        var data = ["id": id]
        
        if let title = title {
            data["title"] = title
        }
        if let body = body {
            data["body"] = body
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: data) else {
            onError("JSON serialization error!")
            return
        }
        
        request.httpBody = jsonData

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                onError("Error: \(String(describing: error))")
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            guard status != 401 else {
                onError("Unauthorized user!")
                return
            }
            
            guard let data = data, JSON(data) != JSON.null else {
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
    func fetchNotes(page: Int, completed: @escaping ([Note]) -> Void, onError: @escaping (String, Int) -> Void) {
        let url = URL(string: "\(baseUrl)/note/getnotes?page=\(page)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let loginString = String(format: "%@:%@", user.email, user.password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if error != nil {
                onError("Error: \(String(describing: error))", -1)
                return
            }
            
            let status = (response as! HTTPURLResponse).statusCode
            
            guard status != 401 else {
                onError("Unauthorized user!", status)
                return
            }
            
            guard let data = data, JSON(data) != JSON.null else {
                onError("Data in nil!", status)
                return
            }
            
            let jsonData = JSON(data)
            
            if jsonData["success"] == false {
                onError("Error: \(jsonData["message"])", status)
                return
            }
            
            var notes = [Note]()
            
            for (_, note) in jsonData["data"] {
                notes.append(Note(json: note))
            }
            
            completed(notes)
        }.resume()
    }
}
