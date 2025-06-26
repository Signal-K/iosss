//
//  MapView.swift
//  Star Sailors
//
//  Created by Liam Arbuckle on 26/6/2025.
//

import SwiftUI
import MapKit
import CoreLocation

// Make CLLocationCoordinate2D conform to Equatable to fix onChange error
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var anomalyViewModel = AnomalyViewModel()
    @State private var centerCoordinate: CLLocationCoordinate2D

    init() {
        // Initialize with Port Melbourne fallback coordinate
        _centerCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: -37.8399, longitude: 144.9310))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            MapViewWrapper(
                coordinate: centerCoordinate,
                anomalies: anomalyViewModel.anomalies
            )
            .ignoresSafeArea()

            Button(action: {
                if let random = anomalyViewModel.anomalies.randomElement() {
                    centerCoordinate = random.anomaly.coordinate
                }
            }) {
                Text("Jump to Random Anomaly")
                    .fontWeight(.semibold)
                    .padding()
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            locationManager.requestLocation()
            Task {
                let userCoord = locationManager.userCoordinate
                let isDefault = userCoord.latitude == -37.8399 && userCoord.longitude == 144.9310
                let fallback = CLLocationCoordinate2D(latitude: -37.8399, longitude: 144.9310)

                await anomalyViewModel.fetchAnomalies(around: isDefault ? fallback : userCoord)

                // Center map on first anomaly if any
                if let first = anomalyViewModel.anomalies.first {
                    centerCoordinate = first.anomaly.coordinate
                } else {
                    // If no anomalies, fallback to user/fallback coord
                    centerCoordinate = isDefault ? fallback : userCoord
                }
            }
        }
        .onChange(of: locationManager.userCoordinate) { newCoord in
            // Optional: update center if user location changes before anomalies loaded
            if anomalyViewModel.anomalies.isEmpty {
                centerCoordinate = newCoord
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -37.8399, longitude: 144.9310)

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            manager.requestWhenInUseAuthorization()
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.userCoordinate = location.coordinate
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Error: \(error.localizedDescription)")
    }
}

struct MapViewWrapper: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    let anomalies: [LinkedAnomaly]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let tileOverlay = MKTileOverlay(urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png")
        tileOverlay.canReplaceMapContent = true
        mapView.addOverlay(tileOverlay, level: .aboveLabels)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Animate region change
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        uiView.setRegion(region, animated: true)

        // Remove old annotations except user location
        let existingAnnotations = uiView.annotations.filter { $0 !== uiView.userLocation }
        uiView.removeAnnotations(existingAnnotations)

        // Add annotations for anomalies
        for anomaly in anomalies {
            let annotation = MKPointAnnotation()
            annotation.coordinate = anomaly.anomaly.coordinate
            annotation.title = anomaly.anomaly.content ?? "Unknown"
            let distance = coordinate.distanceInKilometers(to: anomaly.anomaly.coordinate)
            annotation.subtitle = String(format: "%.2f km away", distance)
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewWrapper

        init(_ parent: MapViewWrapper) {
            self.parent = parent
            super.init()
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                return MKTileOverlayRenderer(tileOverlay: tileOverlay)
            }
            return MKOverlayRenderer()
        }
    }
}

extension CLLocationCoordinate2D {
    func distanceInKilometers(to: CLLocationCoordinate2D) -> Double {
        let fromLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLoc.distance(from: toLoc) / 1000
    }
}

#Preview {
    MapView()
}
