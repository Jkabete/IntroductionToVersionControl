//
//  ChatDetailView.swift
//  Challenge2
//
//  Created by francesco jacopo abete on 11/11/25.
//


import SwiftUI
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

