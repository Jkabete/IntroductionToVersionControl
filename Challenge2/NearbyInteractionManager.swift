//
//  NearbyInteractionManager.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
// MARK: - Nearby Interaction Manager
import NearbyInteraction
import MultipeerConnectivity
import Combine

class NearbyInteractionManager: NSObject, ObservableObject {
    @Published var nearbyUsers: [NearbyUser] = []
    @Published var isScanning = false
    @Published var statusMessage = "Ready to scan"
    @Published var connectedPeerCount: Int = 0
    
    
    
    var onThrillRequestReceived: ((ThrillRequest) -> Void)?
    var onAcceptanceReceived: (() -> Void)?
    var onRefusalReceived: ((String) -> Void)?
    
    var niSession: NISession?
    var peerDiscoveryToken: NIDiscoveryToken?
    var mcSession: MCSession?
    var mcAdvertiser: MCNearbyServiceAdvertiser?
    var mcBrowser: MCNearbyServiceBrowser?
    
    let serviceType = "insta-nearby"
    let myPeerID = MCPeerID(displayName: UIDevice.current.name)
    
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
    
    func shareDiscoveryToken(with peer: MCPeerID) {
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
