//
//  ChatRow.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//
// ChatRow.swift

import SwiftUI
import UIKit

struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)
                
                if UIImage(named: chat.user.profileImage) != nil {
                    Image(chat.user.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                } else {
                    Text(chat.user.profileImage)
                        .font(.system(size: 26))
                }
                
                if chat.isActive {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            
            // Chat info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.user.name)
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                    Text(chat.timestamp)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.blue))
                    }
                }
            }
        }
    }
}

