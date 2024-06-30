//
//  ContentView.swift
//  Traveller
//
//  Created by handic on 27.01.2024.
//

import SwiftUI
import MapKit

@MainActor class LocationHandler: ObservableObject {
    static let shared = LocationHandler()
    public let manager: CLLocationManager
    
    init() {
        self.manager = CLLocationManager()
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }
    }
}

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(center: CLLocationCoordinate2D(
                                            latitude: 42.360256,
                                            longitude: -71.057279),
                                           span: MKCoordinateSpan(
                                            latitudeDelta: 0.1,
                                            longitudeDelta: 0.1)
    )
    
    static let northShore = MKCoordinateRegion(center: CLLocationCoordinate2D(
                                            latitude: 42.547408,
                                            longitude: -70.870085),
                                           span: MKCoordinateSpan(
                                            latitudeDelta: 0.5,
                                            longitudeDelta: 0.5)
    )
}

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)

}

struct ContentView: View {
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var route: MKRoute?
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        request.region = visibleRegion ?? MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125))
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
        }
    }
    
    
    var body: some View {
        Map(position: $position, selection: $selectedResult) {
            Annotation("Parking", coordinate: .parking) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 5)
                    Image(systemName: "car")
                        .padding(5)
                }
            }
            .annotationTitles(.hidden)
            
            ForEach(searchResults, id: \.self) { result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
                        
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
            
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top, .horizontal])
                    }
                    
                    BeantownButtons(searchResults: $searchResults, position: $position, visibleRegion: visibleRegion)
                        .padding(.top)
                }
                Spacer()
            }
            .background(.thinMaterial)
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
//            search(for: "restaurant")
        }
        .mapControls {
            MapUserLocationButton()
            MapPitchToggle()
            MapCompass()
            MapScaleView()
        }
        
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .parking))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    ContentView()
}
