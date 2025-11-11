// ContentView.swift - Main entry point
import SwiftUI
import NearbyInteraction
internal import Combine

struct ContentView: View {
    var body: some View {
        MessagesView()
    }
}

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
                                    ChatRow(chat: chat)
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("username")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
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

// SearchBar.swift
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

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
                
                Text(user.profileImage)
                    .font(.system(size: 30))
            }
            
            Text(user.name)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(width: 70)
        }
    }
}

// ChatRow.swift
struct ChatRow: View {
    let chat: Chat
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile picture
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 56, height: 56)
                
                Text(chat.user.profileImage)
                    .font(.system(size: 26))
                
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

// MARK: - Chat Detail View
struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let chat: Chat
    @State private var messageText = ""
    @State private var messages: [String] = ["Started chatting via Nearby"]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(messages.indices, id: \.self) { index in
                        Text(messages[index])
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(index % 2 == 0 ? Color.blue.opacity(0.15) : Color(.systemGray5))
                            )
                            .frame(maxWidth: .infinity, alignment: index % 2 == 0 ? .trailing : .leading)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal)
            }
            .background(Color(.systemGroupedBackground))
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .white)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(.systemGray5) : Color.blue)
                        )
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(chat.user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        withAnimation {
            messages.append(trimmed)
        }
        messageText = ""
    }
}

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

// MARK: - Refusal Message View
struct RefusalMessageView: View {
    let fromUser: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Request Declined")
                    .font(.system(size: 22, weight: .bold))
                
                Text("\(fromUser) declined your thrill request")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal, 40)
        }
    }
}

// MapModalView.swift - The new map feature
import MapKit

struct MapModalView: View {
    @Environment(\.dismiss) var dismiss
    let users: [User]
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                Map(position: $position) {
                    ForEach(users) { user in
                        Annotation(user.name, coordinate: CLLocationCoordinate2D(
                            latitude: user.latitude,
                            longitude: user.longitude
                        )) {
                            UserMapPin(user: user)
                        }
                    }
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Bottom user cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(users) { user in
                                UserMapCard(user: user) {
                                    withAnimation {
                                        position = .region(
                                            MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(
                                                    latitude: user.latitude,
                                                    longitude: user.longitude
                                                ),
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            )
                                        )
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Friends Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "location.fill")
                    }
                }
            }
        }
    }
}

// UserMapPin.swift
struct UserMapPin: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 46, height: 46)
                
                Circle()
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: 46, height: 46)
                
                Text(user.profileImage)
                    .font(.system(size: 22))
            }
            .shadow(radius: 4)
            
            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(.white)
                .offset(y: -8)
                .shadow(radius: 2)
        }
    }
}

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

// SampleData.swift - Sample data for testing
struct SampleData {
    static let users: [User] = [
        User(name: "Sarah", username: "sarah_m", profileImage: "🧑‍🦰", hasStory: true, isOnline: true, latitude: 40.7580, longitude: -73.9855, distance: nil, isNearby: false),
        User(name: "Mike", username: "mike_j", profileImage: "👨‍💼", hasStory: true, isOnline: true, latitude: 40.7489, longitude: -73.9680, distance: nil, isNearby: false),
        User(name: "Emma", username: "emma_k", profileImage: "👩‍🎨", hasStory: true, isOnline: false, latitude: 40.7589, longitude: -73.9851, distance: nil, isNearby: false),
        User(name: "Alex", username: "alex_p", profileImage: "🧔", hasStory: false, isOnline: true, latitude: 40.7614, longitude: -73.9776, distance: nil, isNearby: false),
        User(name: "Lisa", username: "lisa_w", profileImage: "👩‍💻", hasStory: true, isOnline: false, latitude: 40.7529, longitude: -73.9772, distance: nil, isNearby: false)
    ]
    
    static let chats: [Chat] = [
        Chat(user: users[0], lastMessage: "See you tomorrow! 👋", timestamp: "2m", unreadCount: 0, isActive: true),
        Chat(user: users[1], lastMessage: "That sounds great!", timestamp: "15m", unreadCount: 2, isActive: true),
        Chat(user: users[2], lastMessage: "Haha yes definitely 😂", timestamp: "1h", unreadCount: 0, isActive: false),
        Chat(user: users[3], lastMessage: "Thanks for the help", timestamp: "3h", unreadCount: 1, isActive: true),
        Chat(user: users[4], lastMessage: "You: Cool, talk soon", timestamp: "5h", unreadCount: 0, isActive: false)
    ]
}

// MARK: - Nearby Interaction Manager
import NearbyInteraction
import MultipeerConnectivity

class NearbyInteractionManager: NSObject, ObservableObject {
    @Published var nearbyUsers: [NearbyUser] = []
    @Published var isScanning = false
    @Published var statusMessage = "Ready to scan"
    
    var onThrillRequestReceived: ((ThrillRequest) -> Void)?
    var onAcceptanceReceived: (() -> Void)?
    var onRefusalReceived: ((String) -> Void)?
    
    private var niSession: NISession?
    private var peerDiscoveryToken: NIDiscoveryToken?
    private var mcSession: MCSession?
    private var mcAdvertiser: MCNearbyServiceAdvertiser?
    private var mcBrowser: MCNearbyServiceBrowser?
    
    private let serviceType = "insta-nearby"
    private let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
    struct NearbyUser: Identifiable {
        let id = UUID()
        let name: String
        let peerID: MCPeerID
        let distance: Float
        let direction: simd_float3?
        var canSendThrill: Bool {
            distance < 3.0 // Within 3 meters
        }
    }
    
    override init() {
        super.init()
        setupMultipeerConnectivity()
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThrillResponse),
            name: NSNotification.Name("SendThrillResponse"),
            object: nil
        )
    }
    
    @objc private func handleThrillResponse(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let response = userInfo["response"] as? String,
              let peerIDString = userInfo["peerID"] as? String,
              let session = mcSession else { return }
        
        // Find the peer
        let peer = session.connectedPeers.first { $0.displayName == peerIDString }
        
        guard let targetPeer = peer else { return }
        
        let message = "THRILL_RESPONSE_\(response)_FROM_\(myPeerID.displayName)"
        let data = message.data(using: .utf8)!
        
        do {
            try session.send(data, toPeers: [targetPeer], with: .reliable)
        } catch {
            print("Error sending response: \(error)")
        }
    }
    
    func startScanning() {
        guard NISession.isSupported else {
            statusMessage = "Nearby Interaction not supported on this device"
            return
        }
        
        isScanning = true
        statusMessage = "Scanning for nearby users..."
        
        // Initialize NI Session
        niSession = NISession()
        niSession?.delegate = self
        
        // Get our discovery token
        if let token = niSession?.discoveryToken {
            peerDiscoveryToken = token
            startAdvertising()
            startBrowsing()
        }
    }
    
    func stopScanning() {
        isScanning = false
        statusMessage = "Scanning stopped"
        niSession?.invalidate()
        niSession = nil
        mcAdvertiser?.stopAdvertisingPeer()
        mcBrowser?.stopBrowsingForPeers()
        nearbyUsers.removeAll()
    }
    
    func sendThrill(to user: NearbyUser) {
        // Send thrill notification via Multipeer
        guard let session = mcSession else { return }
        
        let thrillData = "THRILL_REQUEST_FROM_\(myPeerID.displayName)".data(using: .utf8)!
        
        do {
            try session.send(thrillData, toPeers: [user.peerID], with: .reliable)
            statusMessage = "Thrill sent to \(user.name)! Waiting for response..."
        } catch {
            statusMessage = "Failed to send thrill"
        }
    }
    
    private func setupMultipeerConnectivity() {
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        mcSession?.delegate = self
    }
    
    private func startAdvertising() {
        mcAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        mcAdvertiser?.delegate = self
        mcAdvertiser?.startAdvertisingPeer()
    }
    
    private func startBrowsing() {
        mcBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        mcBrowser?.delegate = self
        mcBrowser?.startBrowsingForPeers()
    }
    
    private func shareDiscoveryToken(with peer: MCPeerID) {
        guard let token = peerDiscoveryToken,
              let session = mcSession else { return }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("Error sharing token: \(error)")
        }
    }
}

// MARK: - NISessionDelegate
extension NearbyInteractionManager: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        DispatchQueue.main.async {
            // Get connected peers
            guard let mcSession = self.mcSession else { return }
            
            self.nearbyUsers = nearbyObjects.compactMap { object in
                guard let distance = object.distance else { return nil }
                
                // Try to match with a connected peer
                let peer = mcSession.connectedPeers.first
                
                return NearbyUser(
                    name: peer?.displayName ?? "User",
                    peerID: peer ?? MCPeerID(displayName: "Unknown"),
                    distance: distance,
                    direction: object.direction
                )
            }
            
            if !self.nearbyUsers.isEmpty {
                self.statusMessage = "Found \(self.nearbyUsers.count) nearby user(s)"
            }
        }
    }
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        DispatchQueue.main.async {
            self.statusMessage = "User moved out of range"
        }
    }
    
    func sessionWasSuspended(_ session: NISession) {
        statusMessage = "Session suspended"
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        statusMessage = "Session resumed"
    }
    
    func session(_ session: NISession, didInvalidateWith error: Error) {
        statusMessage = "Session error: \(error.localizedDescription)"
    }
}

// MARK: - MCSessionDelegate
extension NearbyInteractionManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.statusMessage = "Connected to \(peerID.displayName)"
                self.shareDiscoveryToken(with: peerID)
            case .connecting:
                self.statusMessage = "Connecting to \(peerID.displayName)..."
            case .notConnected:
                self.statusMessage = "Disconnected from \(peerID.displayName)"
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Check if it's a thrill request
        if let message = String(data: data, encoding: .utf8) {
            if message.starts(with: "THRILL_REQUEST_FROM_") {
                let fromUser = message.replacingOccurrences(of: "THRILL_REQUEST_FROM_", with: "")
                DispatchQueue.main.async {
                    self.triggerHapticFeedback()
                    
                    // Create thrill request
                    let request = ThrillRequest(
                        fromUser: fromUser,
                        fromPeerID: peerID.displayName,
                        timestamp: Date()
                    )
                    
                    self.onThrillRequestReceived?(request)
                }
                return
            }
            
            // Check if it's a response
            if message.starts(with: "THRILL_RESPONSE_") {
                if message.contains("ACCEPT") {
                    let fromUser = message.components(separatedBy: "_FROM_").last ?? ""
                    DispatchQueue.main.async {
                        self.statusMessage = "✅ \(fromUser) accepted! Chat started!"
                        self.onAcceptanceReceived?()
                    }
                } else if message.contains("DECLINE") {
                    let fromUser = message.components(separatedBy: "_FROM_").last ?? ""
                    DispatchQueue.main.async {
                        self.statusMessage = "❌ \(fromUser) declined your request"
                        self.onRefusalReceived?(fromUser)
                    }
                }
                return
            }
        }
        
        // Try to decode as discovery token
        do {
            if let token = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
                let config = NINearbyPeerConfiguration(peerToken: token)
                niSession?.run(config)
            }
        } catch {
            print("Error decoding token: \(error)")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Create pulsing effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            generator.notificationOccurred(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension NearbyInteractionManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, mcSession)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension NearbyInteractionManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let session = mcSession else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.statusMessage = "Lost connection to \(peerID.displayName)"
        }
    }
}

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

// MARK: - Thrill Animation View
struct ThrillAnimationView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.orange)
                    .scaleEffect(scale)
                    .opacity(opacity)
                
                Text("Thrill Sent!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.2
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
                opacity = 0
            }
        }
    }
}

