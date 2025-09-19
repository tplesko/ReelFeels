//
//  EmotionPostRow.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//


import SwiftUI

struct EmotionPostRow: View {
    let post: EmotionPost
    let commentCount: Int
    let likeCount: Int
    let isLiked: Bool
    var onCommentTapped: (() -> Void)? = nil
    var onLikeTapped:    (() -> Void)? = nil
    
    // Podesi širinu postera (TMDB ima w92, w154, w185, w342, w500, w780…)
    private let posterWidth: Int = 154
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: avatar/username + emoji
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username.isEmpty ? "Korisnik" : post.username)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(post.movieTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        if let year = post.commentCount /* reuse field? no */ { /* ignore */ }
                    }
                }
                Spacer(minLength: 8)
                Text(post.emoji)
                    .font(.largeTitle)
                    .accessibilityLabel("Emoji: \(post.emoji)")
            }
            
            // Sadržaj: poster + opis
            HStack(alignment: .top, spacing: 12) {
                posterView
                    .frame(width: 90, height: 135)
                    .background(Color.secondary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.05))
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    if !post.description.isEmpty {
                        Text(post.description)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(5)
                    } else {
                        Text("— bez opisa —")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let likeCount = post.likeCount, let commentCount = post.commentCount {
                    }
                }
                Spacer(minLength: 0)
            }
            
            // Akcije
            HStack(spacing: 16) {
                Button(action: { onLikeTapped?() }) {
                    Label("\(likeCount)", systemImage: isLiked ? "heart.fill" : "heart")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(isLiked ? .red : .primary)
                .buttonStyle(.plain)
                
                Button(action: { onCommentTapped?() }) {
                    Label("\(commentCount)", systemImage: "bubble.right")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.primary)
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Poster
    
    @ViewBuilder
    private var posterView: some View {
        if let url = TMDB.posterURL(path: post.posterPath, width: posterWidth) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let img):
                    img.resizable().scaledToFill()
                case .failure:
                    placeholderPoster
                @unknown default:
                    placeholderPoster
                }
            }
        } else {
            placeholderPoster
        }
    }
    
    private var placeholderPoster: some View {
        ZStack {
            Color.secondary.opacity(0.08)
            Image(systemName: "film")
                .imageScale(.large)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}
