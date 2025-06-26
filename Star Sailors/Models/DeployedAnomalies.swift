//
//  DeployedAnomalies.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 26/6/2025.
//

import SwiftUI
import CoreLocation

struct AnomalyListView: View {
    @StateObject private var viewModel = AnomalyViewModel()
    let origin: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -37.8399, longitude: 144.9310) // Port Melbourne fallback

    var body: some View {
        NavigationView {
            List(viewModel.anomalies) { linkedAnomaly in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anomaly ID: \(linkedAnomaly.anomaly.id)")
                        .font(.headline)
                    Text(linkedAnomaly.anomaly.content ?? "No content")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "Lat: %.5f, Lon: %.5f",
                                linkedAnomaly.anomaly.coordinate.latitude,
                                linkedAnomaly.anomaly.coordinate.longitude))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Linked Anomalies")
            .task {
                await viewModel.fetchAnomalies(around: origin)
            }
        }
    }
}

#Preview {
    AnomalyListView()
}
