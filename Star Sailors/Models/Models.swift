//
//  Models.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 18/6/2025.
//

import Foundation
import CoreLocation

struct Classification: Codable, Identifiable {
    let id: Int64
    let createdAt: Date
    let content: String?
    let author: UUID?
    let anomaly: Int64?
    let media: [String: AnyCodable]?
    let classificationType: String?
    let classificationConfiguration: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case content
        case author
        case anomaly
        case media
        case classificationType = "classificationtype"
        case classificationConfiguration = "classificationConfiguration"
    }
}

// Table < > Struct relationships

struct Anomaly: Decodable { // Corresponds to `anomalies` sb table
    let id: Int64
    let content: String?
    
    // Q: - is this going to affect when we pull anomalies in that won't have coordinates?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Other values (based on table nomenclature)
    /*
    var anomalySet: String?
    var anomalytype: String?
    var configuration: [String: AnyCodable]?
    var createdAt: Date
    */
    
    enum CodingKeys: String, CodingKey {
        case id, content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        content = try container.decodeIfPresent(String.self, forKey: .content)
    }
    
    init(id: Int64, content: String?, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.content = content
        self.coordinate = coordinate
    }
}

struct LinkedAnomaly: Decodable, Identifiable { // Corresponds to `linked_anomalies` sb table
    let id: Int64
    let anomaly: Anomaly
    
//    let author: UUID?
//    let automaton: String?
//    let date: Date?
//    let classification_id: Int64?
//    let anomaly_id: Int64?
}

//struct Inventory: Codable, Identifiable {
//    let id: Int64
//    let item: Int64?
//    let owner: UUID?
//    let quantity: Double?
//    let notes: String?
//    let timeOfDeploy: Date?
//    let anomaly: Int64?
//    let parentItem: Int64?
//    let configuration: [String: AnyCodable]?
//    let terrarium: Int64?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case item
//        case owner
//        case quantity
//        case notes
//        case timeOfDeploy = "time_of_deploy"
//        case anomaly
//        case parentItem = "parentItem"
//        case configuration
//        case terrarium
//    }
//}

struct Event: Codable, Identifiable {
    let id: Int64
    let location: Int64
    let classificationLocation: Int64
    let type: String
    let configuration: [String: AnyCodable]
    let time: Date
    let completed: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case location
        case classificationLocation = "classification_location"
        case type
        case configuration
        case time
        case completed
    }
}

struct Comment: Codable, Identifiable {
    let id: Int64
    let createdAt: Date
    let content: String
    let author: UUID
    let classificationId: Int64?
    let parentCommentId: Int64?
    let configuration: [String: AnyCodable]?
    let uploads: Int64?
    let surveyor: Bool?
    let confirmed: Bool?
    let value: String?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case content
        case author
        case classificationId = "classification_id"
        case parentCommentId = "parent_comment_id"
        case configuration
        case uploads
        case surveyor
        case confirmed
        case value
        case category
    }
}

struct Profile: Codable, Identifiable {
    let id: UUID
    let updatedAt: Date?
    let username: String?
    let fullName: String?
    let avatarUrl: String?
    let website: String?
    let location: Int64?
    let activeMission: Int64?
    let classificationPoints: Int64?
    let pushSubscription: [String: AnyCodable]?
    let referralCode: String?

    enum CodingKeys: String, CodingKey {
        case id
        case updatedAt = "updated_at"
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case website
        case location
        case activeMission = "activemission"
        case classificationPoints = "classificationPoints"
        case pushSubscription = "push_subscription"
        case referralCode = "referral_code"
    }
}

struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported value")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self.value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(self.value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "Unsupported value"))
        }
    }
}

struct UpdateProfileParams: Encodable {
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case username
    }
}
