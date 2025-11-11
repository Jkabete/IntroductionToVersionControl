//
//  Models.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// Models.swift - Data models
struct User: Identifiable {
    let id = UUID()
    let name: String
    let username: String
    let profileImage: String
    let hasStory: Bool
    let isOnline: Bool
    let latitude: Double
    let longitude: Double
    var distance: Float? = nil
    var isNearby: Bool = false
}

struct ThrillRequest: Identifiable {
    let id = UUID()
    let fromUser: String
    let fromPeerID: String
    let timestamp: Date
}

struct Chat: Identifiable {
    let id = UUID()
    let user: User
    let lastMessage: String
    let timestamp: String
    let unreadCount: Int
    let isActive: Bool
    var peerID: String? = nil
}

