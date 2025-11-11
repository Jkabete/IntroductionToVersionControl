//
//  NearbyUserCard.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// MARK: - Nearby User Card
struct NearbyUserCard: View {
    let user: NearbyInteractionManager.NearbyUser
    let onSendThrill: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Distance indicator
            ZStack {
                Circle()
                    .fill(user.canSendThrill ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", user.distance))
                        .font(.system(size: 16, weight: .bold))
                    Text("m")
                        .font(.system(size: 12))
                }
                .foregroundColor(user.canSendThrill ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.system(size: 17, weight: .semibold))
                
                Text(user.canSendThrill ? "In range for thrill" : "Too far away")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Send thrill button
            Button(action: onSendThrill) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(user.canSendThrill ?
                                LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(colors: [.gray, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    )
            }
            .disabled(!user.canSendThrill)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}
