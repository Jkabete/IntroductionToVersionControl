//
//  NearbyInteractionView.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// MARK: - Nearby Interaction View
struct NearbyInteractionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var manager = NearbyInteractionManager()
    @State private var showThrillAnimation = false
    @Binding var thrillRequests: [ThrillRequest]
    @State private var showRefusalMessage = false
    @State private var refusalFromUser = ""
    
    let onThrillRequestReceived: (ThrillRequest) -> Void
    let onRefusalReceived: (String) -> Void
    let onRequestAccepted: (ThrillRequest) -> Void
    let onRequestDeclined: (ThrillRequest) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.pink.opacity(0.3), Color.orange.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Status section
                    VStack(spacing: 12) {
                        Image(systemName: manager.isScanning ? "wave.3.right.circle.fill" : "wave.3.right.circle")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                            .symbolEffect(.pulse, isActive: manager.isScanning)
                        
                        Text(manager.statusMessage)
                            .font(.system(size: 16))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    // Nearby users list
                    if !manager.nearbyUsers.isEmpty {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(manager.nearbyUsers) { user in
                                    NearbyUserCard(user: user) {
                                        manager.sendThrill(to: user)
                                        showThrillAnimation = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            showThrillAnimation = false
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    } else if manager.isScanning {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Searching for nearby users...")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Control button
                    Button(action: {
                        if manager.isScanning {
                            manager.stopScanning()
                        } else {
                            manager.startScanning()
                        }
                    }) {
                        Text(manager.isScanning ? "Stop Scanning" : "Start Scanning")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(manager.isScanning ? Color.red : Color.orange)
                            )
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                }
                
                // Thrill request banners - ON TOP
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
            .navigationTitle("Nearby Users")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        manager.stopScanning()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .overlay {
                if showThrillAnimation {
                    ThrillAnimationView()
                }
            }
            .onAppear {
                manager.onThrillRequestReceived = { request in
                    onThrillRequestReceived(request)
                }
                manager.onRefusalReceived = { fromUser in
                    withAnimation {
                        showRefusalMessage = true
                        refusalFromUser = fromUser
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showRefusalMessage = false
                        }
                    }
                    onRefusalReceived(fromUser)
                }
            }
        }
    }
    
    private func acceptThrillRequest(_ request: ThrillRequest) {
        onRequestAccepted(request)
        manager.statusMessage = "✅ Chat request accepted!"
    }
    
    private func declineThrillRequest(_ request: ThrillRequest) {
        onRequestDeclined(request)
        manager.statusMessage = "Request declined"
    }
}
