//
//  SampleData.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// SampleData.swift - Sample data for testing
struct SampleData {
    static let currentUser = User(
        name: "You",
        username: "__jk1_",
        profileImage: "Image_1", // Replace with your actual asset name
        hasStory: true,
        isOnline: true,
        latitude: 40.7589,
        longitude: -73.9851,
        distance: nil,
        isNearby: false
    )
    
    static let users: [User] = [
        User(name: "Sarah", username: "sarah_m", profileImage: "sarah_profile", hasStory: true, isOnline: true, latitude: 40.7580, longitude: -73.9855, distance: nil, isNearby: false),
        User(name: "Mike", username: "mike_j", profileImage: "mike_profile", hasStory: true, isOnline: true, latitude: 40.7489, longitude: -73.9680, distance: nil, isNearby: false),
        User(name: "Emma", username: "emma_k", profileImage: "emma_profile", hasStory: true, isOnline: false, latitude: 40.7589, longitude: -73.9851, distance: nil, isNearby: false),
        User(name: "Alex", username: "alex_p", profileImage: "alex_profile", hasStory: false, isOnline: true, latitude: 40.7614, longitude: -73.9776, distance: nil, isNearby: false),
        User(name: "Lisa", username: "lisa_w", profileImage: "lisa_profile", hasStory: true, isOnline: false, latitude: 40.7529, longitude: -73.9772, distance: nil, isNearby: false)
    ]
    
    static let chats: [Chat] = [
        Chat(user: users[0], lastMessage: "See you tomorrow! 👋", timestamp: "2m", unreadCount: 0, isActive: true),
        Chat(user: users[1], lastMessage: "That sounds great!", timestamp: "15m", unreadCount: 2, isActive: true),
        Chat(user: users[2], lastMessage: "Haha yes definitely 😂", timestamp: "1h", unreadCount: 0, isActive: false),
        Chat(user: users[3], lastMessage: "Thanks for the help", timestamp: "3h", unreadCount: 1, isActive: true),
        Chat(user: users[4], lastMessage: "You: Cool, talk soon", timestamp: "5h", unreadCount: 0, isActive: false)
    ]
}
