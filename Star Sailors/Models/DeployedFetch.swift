//
//  DeployedFetch.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 26/6/2025.
//

import Foundation
import CoreLocation

struct LinkedAnomaly: Decodable, Identifiable {
    let id: Int64
    let anomaly: Anomaly
}

struct Anomaly: Decodable {
    let id: Int64
    let content: String?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

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

@MainActor
class AnomalyViewModel: ObservableObject {
    @Published var anomalies: [LinkedAnomaly] = []
    
    func fetchAnomalies(around origin: CLLocationCoordinate2D) async {
        do {
            let results: [LinkedAnomaly] = try await supabase
                .from("linked_anomalies")
                .select("id, anomaly(id, content)")
                .limit(10)
                .execute()
                .value
            
            self.anomalies = results.map { linked in
                let randomCoord = generateRandomCoordinate(around: origin, maxDistanceInKM: 20)
                return LinkedAnomaly(id: linked.id, anomaly: Anomaly(
                    id: linked.anomaly.id,
                    content: linked.anomaly.content,
                    coordinate: randomCoord
                ))
            }
        } catch {
            print("Error fetching anomalies: \(error)")
        }
    }
    
    private func generateRandomCoordinate(around origin: CLLocationCoordinate2D, maxDistanceInKM: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6371.0 // in km
        let maxDistance = maxDistanceInKM / earthRadius

        let bearing = Double.random(in: 0...360).toRadians()
        let distance = Double.random(in: 0...maxDistance)

        let lat1 = origin.latitude.toRadians()
        let lon1 = origin.longitude.toRadians()

        let lat2 = asin(sin(lat1) * cos(distance) + cos(lat1) * sin(distance) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(distance) * cos(lat1), cos(distance) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
}

private extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
}
