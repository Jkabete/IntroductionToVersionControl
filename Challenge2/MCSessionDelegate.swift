//
//  MCSessionDelegate.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import MultipeerConnectivity
import NearbyInteraction
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
                self.niSession?.run(config)
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

