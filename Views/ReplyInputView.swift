//
//  ReplyInputView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//
import SwiftUI

struct ReplyInputView: View {
    let postId: String
    let theoryId: String
    let userId: String
    let username: String

    @State private var replyText = ""
    private let viewModel = ConspiracyViewModel()

    var body: some View {
        HStack {
            TextField("Odgovori...", text: $replyText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Odgovori") {
                guard !replyText.isEmpty else { return }
                viewModel.addReply(to: postId, theoryId: theoryId, text: replyText, userId: userId, username: username)
                replyText = ""
            }
        }
        .padding(.leading, 16)
    }
}
