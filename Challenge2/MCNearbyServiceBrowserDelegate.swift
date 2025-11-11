//
//  MCNearbyServiceBrowserDelegate.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import MultipeerConnectivity
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
