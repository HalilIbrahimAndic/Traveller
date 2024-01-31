//
//  BeantownButtons.swift
//  Traveller
//
//  Created by handic on 27.01.2024.
//

import SwiftUI
import MapKit

struct BeantownButtons: View {
    
    @Binding var searchResults: [MKMapItem]
    @Binding var position: MapCameraPosition
    var visibleRegion: MKCoordinateRegion?
    
    var body: some View {
        HStack {
            Button(action: {
                search(for: "playground")
            }, label: {
                Label("Playgrounds", systemImage: "figure.and.child.holdinghands")
            })
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                search(for: "beaches")
            }, label: {
                Label("Beaches", systemImage: "beach.umbrella")
            })
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                search(for: "restaurant")
            }, label: {
                Label("Restaurants", systemImage: "takeoutbag.and.cup.and.straw")
            })
            .buttonStyle(.borderedProminent)
            
            Button(action: {
                position = .region(.boston)
            }, label: {
                Label("Boston", systemImage: "building.2")
            })
            .buttonStyle(.bordered)
            
            Button(action: {
                position = .region(.northShore)
            }, label: {
                Label("North Shore", systemImage: "water.waves")
            })
            .buttonStyle(.bordered)
        }
        .labelStyle(.iconOnly)
    }
    
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
}
