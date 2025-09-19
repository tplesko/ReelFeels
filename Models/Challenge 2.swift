//
//  Challenge 2.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//


struct Challenge: Identifiable, Codable {
    var id: String
    var challengerId: String
    var receiverId: String
    var movieTitle: String
    var totalEpisodes: Int
    var startDate: Date
    var finishedBy: String? // UID of the winner
    var status: String // "active", "completed"
}