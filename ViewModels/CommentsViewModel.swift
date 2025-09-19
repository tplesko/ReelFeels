//
//  CommentsViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 25.06.2025..
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore

class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []

    func fetchComments(for postId: String) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Greška kod komentara: \(error.localizedDescription)")
                    return
                }

                self.comments = snapshot?.documents.compactMap {
                    try? $0.data(as: Comment.self)
                } ?? []
            }
    }

    func addComment(to postId: String, text: String, userId: String, username: String) {
        let db = Firestore.firestore()
        let newComment = Comment(
            userId: userId,
            username: username,
            text: text,
            timestamp: Date()
        )

        do {
            _ = try db.collection("posts")
                .document(postId)
                .collection("comments")
                .addDocument(from: newComment)
        } catch {
            print("Neuspjelo dodavanje komentara: \(error.localizedDescription)")
        }
    }
}

