//
//  TheoryReply.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//


import Foundation
import FirebaseFirestore

struct TheoryReply: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
}
