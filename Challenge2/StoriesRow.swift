//
//  StoriesRow.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// StoriesRow.swift - Horizontal stories scroll
struct StoriesRow: View {
    @Binding var showMapModal: Bool
    @Binding var showNearbyModal: Bool
    let users = SampleData.users
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // Your story
                VStack {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                            .background(Circle().fill(Color.white))
                    }
                    Text("Your story")
                        .font(.system(size: 12))
                }
                
                // Nearby Interaction button (NEW!)
                Button(action: { showNearbyModal = true }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.pink, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "wave.3.right")
                                .font(.system(size: 26))
                                .foregroundColor(.white)
                        }
                        Text("Nearby")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                    }
                }
                
                // Map button
                Button(action: { showMapModal = true }) {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: "map.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        Text("Map")
                            .font(.system(size: 12))
                            .foregroundColor(.primary)
                    }
                }
                
                // Other users' stories
                ForEach(users.filter { $0.hasStory }) { user in
                    StoryCircle(user: user)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

