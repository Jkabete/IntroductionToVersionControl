//
//  NISessionDelegate.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import NearbyInteraction
import MultipeerConnectivity
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

