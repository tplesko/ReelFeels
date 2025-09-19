//
//  PostListView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//
import SwiftUI

struct PostListView: View {
    let posts: [EmotionPost]
    var commentCounts: [String: Int]
    var likeCounts: [String: Int]
    var likedPosts: Set<String>
    var onCommentTapped: ((String) -> Void)? = nil
    var onLikeTapped: ((String) -> Void)? = nil

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(posts) { post in
                    if let postId = post.id {
                        EmotionPostRow(
                            post: post,
                            commentCount: commentCounts[postId] ?? 0,
                            likeCount: likeCounts[postId] ?? 0,
                            isLiked: likedPosts.contains(postId),
                            onCommentTapped: {
                                if let id = post.id {
                                    onCommentTapped?(id)
                                }
                            },
                            onLikeTapped: {
                                onLikeTapped?(postId)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}



