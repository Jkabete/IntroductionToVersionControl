//
//  ThrillAnimationView.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
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

