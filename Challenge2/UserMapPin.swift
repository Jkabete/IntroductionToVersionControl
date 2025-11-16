//
//  UserMapPin.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
import UIKit
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
                
                if UIImage(named: user.profileImage) != nil {
                    Image(user.profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 46, height: 46)
                        .clipShape(Circle())
                } else {
                    Text(user.profileImage)
                        .font(.system(size: 22))
                }
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
