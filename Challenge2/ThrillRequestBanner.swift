//
//  ThrillRequestBanner.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// MARK: - Thrill Request Banner
struct ThrillRequestBanner: View {
    let request: ThrillRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Pulse effect
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(request.fromUser) sent you a thrill!")
                    .font(.system(size: 15, weight: .semibold))
                
                Text("Start chatting?")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Accept button
            Button(action: onAccept) {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.green))
            }
            
            // Decline button
            Button(action: onDecline) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.red))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
    }
}

