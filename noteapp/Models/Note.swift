import Foundation
import SwiftyJSON

struct Note: Codable {
    init(id: String, title: String, body: String, date: Date, ownerId: String) {
        self.id = id
        self.title = title
        self.body = body
        self.date = date
        self.ownerId = ownerId
    }
    
    init(json: JSON) {
        self.id = json["_id"].string ?? ""
        self.title = json["title"].string ?? ""
        self.body = json["body"].string ?? ""
        self.ownerId = json["ownerId"].string ?? ""
        
        let isoDate = json["date"].string ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        self.date = dateFormatter.date(from: isoDate)!
    }
    
    /// The title of the note.
    var title: String
    
    /// The body of the note.
    var body: String
    
    /// The note's creation date.
    var date: Date
    
    /// The owner of the note.
    var ownerId: String
    
    /// The ID of the note.
    var id: String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        body = try values.decode(String.self, forKey: .body)
        date = try values.decode(Date.self, forKey: .date)
        ownerId = try values.decode(String.self, forKey: .ownerId)
        id = try values.decode(String.self, forKey: ._id)
    }
    
    enum CodingKeys: String, CodingKey {
        case title, body, date, ownerId, _id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(body, forKey: .body)
        try container.encode(date, forKey: .date)
        try container.encode(ownerId, forKey: .ownerId)
        try container.encode(id, forKey: ._id)
    }
}
