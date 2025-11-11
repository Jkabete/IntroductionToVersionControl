//
//  MapModalView.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// MapModalView.swift - The new map feature
import MapKit

struct MapModalView: View {
    @Environment(\.dismiss) var dismiss
    let users: [User]
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    ForEach(users) { user in
                        Annotation(user.name, coordinate: CLLocationCoordinate2D(
                            latitude: user.latitude,
                            longitude: user.longitude
                        )) {
                            UserMapPin(user: user)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Bottom user cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(users) { user in
                                UserMapCard(user: user) {
                                    withAnimation {
                                        position = .region(
                                            MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(
                                                    latitude: user.latitude,
                                                    longitude: user.longitude
                                                ),
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            )
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Friends Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "location.fill")
                    }
                }
            }
        }
    }
}

