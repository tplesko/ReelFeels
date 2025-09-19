//
//  HomeFeedViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class HomeFeedViewModel: ObservableObject {
    @Published var availableEmojis: [String] = ["😭", "😂", "😍", "😱", "🥹", "🤯", "😡"]
    @Published var posts: [EmotionPost] = []
    @Published var filteredPosts: [EmotionPost] = []
    @Published var commentCounts: [String: Int] = [:]
    @Published var likedPosts: Set<String> = []
    @Published var likeCounts: [String: Int] = [:]
    
    func applyFilters(emoji: String?, searchText: String) {
        var result = posts

        if let emoji = emoji {
            result = result.filter { $0.emoji == emoji }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.movieTitle.localizedCaseInsensitiveContains(searchText) }
        }

        filteredPosts = result
    }

    func fetchPosts() {
        let db = Firestore.firestore()
        
        print("TMDB key:", TMDB.apiKey) // treba ispisati tvoj ključ

        db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Greška pri dohvaćanju postova: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("⚠️ Nema dokumenata")
                    return
                }

                do {
                    self.posts = try documents.map {
                        let post = try $0.data(as: EmotionPost.self)
                        
                        if let postId = post.id {
                            //Dohvaćanje komentara
                            self.fetchCommentCount(for: postId) { count in
                                DispatchQueue.main.async {
                                    self.commentCounts[postId] = count
                                }
                            }

                            //Lajkovi
                            self.fetchLikes(for: postId)
                        }

                        print("Učitano: \(post.movieTitle)")
                        return post
                    }

                    DispatchQueue.main.async {
                        self.filteredPosts = self.posts
                    }

                } catch {
                    print("Greška pri dekodiranju: \(error)")
                }
            }
    }

    func fetchCommentCounts() {
            for post in posts {
                guard let postId = post.id else { continue }
                fetchCommentCount(for: postId) { count in
                    DispatchQueue.main.async {
                        self.commentCounts[postId] = count
                    }
                }
            }
        }

    func fetchCommentCount(for postId: String, completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        db.collection("posts")
            .document(postId)
            .collection("comments")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Greška pri dohvaćanju komentara: \(error.localizedDescription)")
                    completion(0)
                } else {
                    completion(snapshot?.documents.count ?? 0)
                }
            }
    }
    
    func toggleLike(for postId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let likeRef = db.collection("posts").document(postId).collection("likes").document(userId)
        let postRef = db.collection("posts").document(postId)

        if likedPosts.contains(postId) {
            likeRef.delete { error in
                if error == nil {
                    postRef.updateData(["likeCount": FieldValue.increment(Int64(-1))])
                    DispatchQueue.main.async {
                        self.likedPosts.remove(postId)
                        self.likeCounts[postId, default: 1] -= 1
                    }
                }
            }
        } else {
            likeRef.setData(["timestamp": Timestamp()]) { error in
                if error == nil {
                    postRef.updateData(["likeCount": FieldValue.increment(Int64(1))])
                    DispatchQueue.main.async {
                        self.likedPosts.insert(postId)
                        self.likeCounts[postId, default: 0] += 1
                    }
                }
            }
        }
    }

    func fetchLikes(for postId: String) {
        let db = Firestore.firestore()
        db.collection("posts").document(postId).getDocument{ snapshot, error in guard let data = snapshot?.data(), error == nil else {return}

            DispatchQueue.main.async {
                self.likeCounts[postId] = data["likeCount"] as? Int ?? 0
                if let userId = Auth.auth().currentUser?.uid {
                    db.collection("posts").document(postId)
                      .collection("likes").document(userId)
                      .getDocument { doc, _ in
                          if doc?.exists == true {
                              self.likedPosts.insert(postId)
                          } else {
                              self.likedPosts.remove(postId)
                          }
                      }
                }
            }
        }
    }
}

