//
//  EmojiPickerView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//
import SwiftUI

struct EmojiPickerView: View {
    let emojis: [String]
    @Binding var selectedEmoji: String?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.title2)
                        .padding(8)
                        .background(selectedEmoji == emoji ? Color.purple.opacity(0.2) : Color.clear)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedEmoji = (selectedEmoji == emoji) ? nil : emoji
                        }
                }
            }
            .padding(.horizontal)
        }
    }
}
