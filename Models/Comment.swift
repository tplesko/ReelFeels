//
//  Comment.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//


import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
}
