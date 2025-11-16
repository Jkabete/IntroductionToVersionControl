//
//  StoryCircle.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import UIKit
// StoryCircle.swift
struct StoryCircle: View {
    let user: User
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .orange, .red],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2.5
                    )
                    .frame(width: 74, height: 74)
                
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 70, height: 70)
                
                if UIImage(named: user.profileImage) != nil {
                    Image(user.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else {
                    Text(user.profileImage)
                        .font(.system(size: 30))
                }
            }
            
            Text(user.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

