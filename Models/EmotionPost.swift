//
//  EmotionPost.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import Foundation
import FirebaseFirestore

struct EmotionPost: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String
    var username: String
    var movieTitle: String
    var emoji: String
    var description: String
    var isPublic: Bool
    var timestamp: Date?
    var likeCount: Int? = 0
    var commentCount: Int? = 0
    
    var posterPath: String?           // 👈 DODANO
    var movieId: Int?
    var year: Int?

}
