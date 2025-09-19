//
//  HomeFeedView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeFeedView: View {
    @StateObject private var viewModel = HomeFeedViewModel()
    @State private var selectedEmoji: String? = nil
    @State private var searchText: String = ""
    @State private var selectedPostId: String? = nil
    @State private var showComments = false
    @State private var currentUserId: String = ""
    @State private var currentUsername: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    Text("📜 Emocije zajednice")
                        .font(.headline)
                        .padding(.leading)
                    Spacer()
                }

                EmojiPickerView(emojis: viewModel.availableEmojis, selectedEmoji: $selectedEmoji)

                TextField("Pretraži po nazivu filma...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                PostListView(
                    posts: viewModel.filteredPosts,
                    commentCounts: viewModel.commentCounts,
                    likeCounts: viewModel.likeCounts,
                    likedPosts: viewModel.likedPosts,
                    onCommentTapped: { postId in
                        selectedPostId = postId
                        showComments = true
                    },
                    onLikeTapped: { postId in
                        viewModel.toggleLike(for: postId)
                    }
                )
            }
            .navigationTitle("Feed")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .onAppear {
            viewModel.fetchPosts()
            viewModel.applyFilters(emoji: selectedEmoji, searchText: searchText)

            if let user = Auth.auth().currentUser {
                self.currentUserId = user.uid

                Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
                    if let data = snapshot?.data(),
                       let username = data["username"] as? String {
                        self.currentUsername = username
                    }
                }
            }
        }
        .onChange(of: selectedEmoji) {
            viewModel.applyFilters(emoji: selectedEmoji, searchText: searchText)
        }
        .onChange(of: searchText) {
            viewModel.applyFilters(emoji: selectedEmoji, searchText: searchText)
        }
        .sheet(isPresented: $showComments) {
            if let postId = selectedPostId {
                CommentsAndTheoriesView(postId: postId, userId: currentUserId, username: currentUsername)
            }
        }
    }
}
