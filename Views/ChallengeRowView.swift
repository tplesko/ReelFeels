//
//  ChallengeRowView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//


import SwiftUI

struct ChallengeRowView: View {
    var challenge: Challenge
    @Binding var episodeCounts: [String: Int]
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🎬 \(challenge.movieTitle)")
                .font(.subheadline)
                .foregroundColor(.purple)

            Text("Epizoda: \(episodeCounts[challenge.id] ?? 0)/\(challenge.totalEpisodes)")
                .foregroundColor(.white)

            HStack(spacing: 12) {
                Button("+1 Epizoda") {
                    let current = episodeCounts[challenge.id] ?? 0
                    let next = min(current + 1, challenge.totalEpisodes)
                    episodeCounts[challenge.id] = next
                    viewModel.updateProgress(challengeId: challenge.id, episodes: next)
                }
                .font(.caption)
                .padding(6)
                .background(Color.green)
                .cornerRadius(8)
                .foregroundColor(.white)

                Button("Završi") {
                    viewModel.finishChallenge(challenge: challenge)
                }
                .font(.caption)
                .padding(6)
                .background(Color.blue)
                .cornerRadius(8)
                .foregroundColor(.white)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
