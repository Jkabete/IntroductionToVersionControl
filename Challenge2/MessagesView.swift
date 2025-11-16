//
//  MessagesView.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import UIKit
// MessagesView.swift - Main messages screen
struct MessagesView: View {
    @State private var searchText = ""
    @State private var showMapModal = false
    @State private var showNearbyModal = false
    @State private var chats: [Chat] = SampleData.chats
    @State private var thrillRequests: [ThrillRequest] = []
    @State private var showRefusalMessage = false
    @State private var refusalFromUser = ""
    @State private var activeChat: Chat?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            // Stories section
                            StoriesRow(showMapModal: $showMapModal, showNearbyModal: $showNearbyModal)
                                .padding(.bottom, 8)
                            
                            Divider()
                            
                            // Messages title
                            HStack {
                                Text("Messages")
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Text("Requests")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            
                            // Chat list
                            LazyVStack(spacing: 0) {
                                ForEach(chats) { chat in
                                    Button(action: {
                                        activeChat = chat
                                    }) {
                                        ChatRow(chat: chat)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Text(verbatim: "__jk1_"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if UIImage(named: SampleData.currentUser.profileImage) != nil {
                            Image(SampleData.currentUser.profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } else {
                            Text(SampleData.currentUser.profileImage)
                                .font(.system(size: 20))
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 22))
                        }
                    }
                }
                
                // Thrill request banners
                VStack {
                    ForEach(thrillRequests) { request in
                        ThrillRequestBanner(
                            request: request,
                            onAccept: {
                                acceptThrillRequest(request)
                            },
                            onDecline: {
                                declineThrillRequest(request)
                            }
                        )
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer()
                }
                .animation(.spring(response: 0.4), value: thrillRequests.count)
                
                // Refusal message overlay
                if showRefusalMessage {
                    RefusalMessageView(fromUser: refusalFromUser)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .sheet(isPresented: $showMapModal) {
            MapModalView(users: SampleData.users)
        }
        .sheet(isPresented: $showNearbyModal) {
            NearbyInteractionView(
                thrillRequests: $thrillRequests,
                onThrillRequestReceived: { request in
                    withAnimation {
                        thrillRequests.append(request)
                    }
                },
                onRefusalReceived: { fromUser in
                    withAnimation {
                        showRefusalMessage = true
                        refusalFromUser = fromUser
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showRefusalMessage = false
                        }
                    }
                },
                onRequestAccepted: { request in
                    acceptThrillRequest(request)
                },
                onRequestDeclined: { request in
                    declineThrillRequest(request)
                }
            )
        }
        .sheet(item: $activeChat) { chat in
            NavigationView {
                ChatDetailView(chat: chat)
            }
        }
    }
    
    private func acceptThrillRequest(_ request: ThrillRequest) {
        // Remove the request
        withAnimation {
            thrillRequests.removeAll { $0.id == request.id }
        }
        
        // Send acceptance message back
        NotificationCenter.default.post(
            name: NSNotification.Name("SendThrillResponse"),
            object: nil,
            userInfo: ["response": "ACCEPT", "peerID": request.fromPeerID]
        )
        
        // Create new chat
        let newUser = User(
            name: request.fromUser,
            username: request.fromUser.lowercased().replacingOccurrences(of: " ", with: "_"),
            profileImage: "👤",
            hasStory: false,
            isOnline: true,
            latitude: 0,
            longitude: 0,
            isNearby: true
        )
        
        let newChat = Chat(
            user: newUser,
            lastMessage: "Started chatting via Nearby",
            timestamp: "now",
            unreadCount: 0,
            isActive: true,
            peerID: request.fromPeerID
        )
        
        chats.insert(newChat, at: 0)

        // Dismiss nearby modal if showing and open chat
        showNearbyModal = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            activeChat = newChat
        }
    }
    
    private func declineThrillRequest(_ request: ThrillRequest) {
        // Remove the request
        withAnimation {
            thrillRequests.removeAll { $0.id == request.id }
        }
        
        // Send refusal message back
        NotificationCenter.default.post(
            name: NSNotification.Name("SendThrillResponse"),
            object: nil,
            userInfo: ["response": "DECLINE", "peerID": request.fromPeerID]
        )
    }
}
