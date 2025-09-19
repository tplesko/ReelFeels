//
//  CommentsView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//
import SwiftUI

struct CommentsView: View {
    let postId: String
    let userId: String
    let username: String

    @StateObject private var viewModel = CommentsViewModel()
    @State private var newComment = ""

    var body: some View {
        VStack {
            if viewModel.comments.isEmpty {
                Text("Trenutno nema komentara.")
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.top)
            } else {
                List(viewModel.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.username)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(comment.text)
                            .font(.body)
                    }
                    .padding(.vertical, 4)
                }
            }

            Divider()

            HStack {
                TextField("Napiši komentar...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button(action: {
                    guard !newComment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    viewModel.addComment(to: postId, text: newComment, userId: userId, username: username)
                    newComment = ""
                }) {
                    Text("Pošalji")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding(.trailing)
            }
            .padding(.vertical)
            .background(Color(.systemGray6))
        }
        .onAppear {
            viewModel.fetchComments(for: postId)
        }
        .navigationTitle("Komentari")
    }
}


