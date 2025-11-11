//
//  UserMapCard.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// UserMapCard.swift
struct UserMapCard: View {
    let user: User
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(user.profileImage)
                    .font(.system(size: 24))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                        Text("Active now")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .frame(width: 220)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .shadow(radius: 2)
        }
    }
}
