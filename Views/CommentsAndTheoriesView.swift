//
//  CommentsAndTheoriesView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//

import SwiftUI

struct CommentsAndTheoriesView: View {
    let postId: String
    let userId: String
    let username: String

    @State private var selectedTab = 0 // 0 = Komentari, 1 = Teorije
    @StateObject private var commentsVM = CommentsViewModel()
    @StateObject private var theoriesVM = ConspiracyViewModel()

    @State private var newComment = ""
    @State private var newTheory = ""
    @State private var replyText: String = ""

    var body: some View {
        VStack {
            // MARK: - Segmented Control
            Picker("Odaberi", selection: $selectedTab) {
                Label("💬 Komentari", systemImage: "text.bubble").tag(0)
                Label("🧠 Teorije zavjere", systemImage: "eye").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Divider()

            if selectedTab == 0 {
                // MARK: - Komentari
                List(commentsVM.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.username).font(.caption).foregroundColor(.gray)
                        Text(comment.text)
                    }
                }

                HStack {
                    TextField("Napiši komentar...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Objavi") {
                        guard !newComment.isEmpty else { return }
                        commentsVM.addComment(to: postId, text: newComment, userId: userId, username: username)
                        newComment = ""
                    }
                }
                .padding(.horizontal)
            } else {
                // MARK: - Teorije zavjere
                List {
                    ForEach(theoriesVM.theories) { theory in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(theory.username).font(.caption).foregroundColor(.gray)
                            Text(theory.text)

                            // Prikaz odgovora
                            if let replies = theoriesVM.replies[theory.id ?? ""] {
                                ForEach(replies.prefix(theoriesVM.replyLimits[theory.id ?? ""] ?? 2)) { reply in
                                    HStack(alignment: .top) {
                                        Spacer().frame(width: 16)
                                        VStack(alignment: .leading) {
                                            Text(reply.username).font(.caption2).foregroundColor(.gray)
                                            Text(reply.text).font(.footnote)
                                        }
                                    }
                                }

                                if replies.count >= (theoriesVM.replyLimits[theory.id ?? ""] ?? 2) {
                                    Button("Učitaj još...") {
                                        theoriesVM.loadMoreReplies(for: postId, theoryId: theory.id ?? "")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                }
                            }

                            // Gumb za odgovor
                            Button("Odgovori") {
                                theoriesVM.toggleReplyInput(for: theory.id ?? "")
                            }
                            .font(.caption)
                            .foregroundColor(.purple)

                            // Input za odgovor
                            if theoriesVM.showingReplyInput[theory.id ?? ""] ?? false {
                                HStack {
                                    TextField("Napiši odgovor...", text: $replyText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    Button("Pošalji") {
                                        guard !replyText.isEmpty else { return }
                                        theoriesVM.addReply(to: postId, theoryId: theory.id ?? "", text: replyText, userId: userId, username: username)
                                        replyText = ""
                                        theoriesVM.fetchReplies(for: postId, theoryId: theory.id ?? "")
                                        theoriesVM.toggleReplyInput(for: theory.id ?? "")
                                    }
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 6)
                        .onAppear {
                            theoriesVM.fetchReplies(for: postId, theoryId: theory.id ?? "")
                        }
                    }

                    // Novi unos teorije
                    HStack {
                        TextField("Dodaj teoriju...", text: $newTheory)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Button("Objavi") {
                            guard !newTheory.isEmpty else { return }
                            theoriesVM.addTheory(to: postId, text: newTheory, userId: userId, username: username)
                            newTheory = ""
                        }
                    }
                }
            }
        }
        .onAppear {
            commentsVM.fetchComments(for: postId)
            theoriesVM.fetchTheories(for: postId)
        }
        .navigationTitle("Komentari i teorije")
    }
}
