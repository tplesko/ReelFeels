//
//  ReplyListView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//
import SwiftUI

struct ReplyListView: View {
    let postId: String
    let theoryId: String
    @State private var replies: [TheoryReply] = []
    private let viewModel = ConspiracyViewModel()

    var body: some View {
        ForEach(replies) { reply in
            HStack(alignment: .top) {
                Text("↳ \(reply.username):")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(reply.text)
                    .font(.caption)
            }
            .padding(.leading, 16)
        }
        .onAppear {
            viewModel.fetchReplies(for: postId, theoryId: theoryId)
        }
    }
}
