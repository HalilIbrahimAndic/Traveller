//
//  ItemInfoView.swift
//  Traveller
//
//  Created by handic on 1.02.2024.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    
    @State private var lookAroundScene: MKLookAroundScene?
    @Binding var selectedResult: MKMapItem
    @Binding var route: MKRoute
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name ?? "")")
                    
                    if let travelTime {
                        Text(travelTime)
                    }
                }
            }
            .onAppear {
                
            }
            .onChange(of: selectedResult) {
                self.getLookAroundScene()
            }
    }
    
    
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
}


