//
//  ConspiracyViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//


import FirebaseFirestore
import SwiftUI

class ConspiracyViewModel: ObservableObject {
    @Published var theories: [ConspiracyTheory] = []
    @Published var replies: [String: [TheoryReply]] = [:]
    @Published var replyLimits: [String: Int] = [:]
    @Published var showingReplyInput: [String: Bool] = [:]

    let initialReplyLimit = 2

    private let db = Firestore.firestore()

    func fetchTheories(for postId: String) {
        db.collection("posts").document(postId).collection("theories")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    self.theories = snapshot.documents.compactMap {
                        try? $0.data(as: ConspiracyTheory.self)
                    }
                }
            }
        for theory in self.theories {
            self.replyLimits[theory.id ?? ""] = self.initialReplyLimit
            self.showingReplyInput[theory.id ?? ""] = false
            self.fetchReplies(for: postId, theoryId: theory.id ?? "")
        }
    }

    func addTheory(to postId: String, text: String, userId: String, username: String) {
        let newTheory = ConspiracyTheory(userId: userId, username: username, text: text, timestamp: Date())
        _ = try? db.collection("posts").document(postId).collection("theories").addDocument(from: newTheory)
    }

    func addReply(to postId: String, theoryId: String, text: String, userId: String, username: String) {
        let newReply = TheoryReply(userId: userId, username: username, text: text, timestamp: Date())
        _ = try? db.collection("posts").document(postId).collection("theories")
            .document(theoryId).collection("replies")
            .addDocument(from: newReply)
    }

    func fetchReplies(for postId: String, theoryId: String) {
        let limit = replyLimits[theoryId] ?? initialReplyLimit
        db.collection("posts").document(postId).collection("theories").document(theoryId).collection("replies")
            .order(by: "timestamp", descending: false)
            .limit(to: limit)
            .getDocuments { snapshot, _ in
                let replies = snapshot?.documents.compactMap {
                    try? $0.data(as: TheoryReply.self)
                } ?? []
                DispatchQueue.main.async {
                    self.replies[theoryId] = replies
                }
            }
    }

    func loadMoreReplies(for postId: String, theoryId: String) {
        replyLimits[theoryId, default: initialReplyLimit] += 2
        fetchReplies(for: postId, theoryId: theoryId)
    }

    func toggleReplyInput(for theoryId: String) {
        showingReplyInput[theoryId] = !(showingReplyInput[theoryId] ?? false)
    }
}
