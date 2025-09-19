//
//  ProfileViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var userPosts: [EmotionPost] = []
    @Published var friends: [Friend] = []
    @Published var watchHistory: [WatchEntry] = []
    @Published var streakCount: Int = 0
    @Published var challenges: [Challenge] = []
    let db = Firestore.firestore()


    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }

        let userRef = db.collection("users").document(currentUser.uid)

        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Greška pri dohvaćanju korisnika: \(error.localizedDescription)")
                return
            }

            if let data = snapshot?.data(),
               let email = data["email"] as? String,
               let username = data["username"] as? String {

                self.user = User(id: currentUser.uid, email: email, username: username)
                self.fetchUserPosts(userId: currentUser.uid)
                self.fetchFriends(userId: currentUser.uid)
                self.fetchWatchHistory(userId: currentUser.uid)
                self.fetchChallenges(userId: currentUser.uid)

            } else {
                print("Korisnik nije pronađen ili nedostaju podaci.")
            }
        }
    }

    private func fetchUserPosts(userId: String) {
        db.collection("posts")
            .whereField("userID", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching user posts: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                do {
                    self.userPosts = try documents.map {
                        try $0.data(as: EmotionPost.self)
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                }
            }
    }

    private func fetchFriends(userId: String) {
        db.collection("users").document(userId).collection("friends").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching friends: \(error.localizedDescription)")
                return
            }

            self.friends = snapshot?.documents.compactMap { doc in
                try? doc.data(as: Friend.self)
            } ?? []
        }
    }

    private func fetchWatchHistory(userId: String) {
        db.collection("users").document(userId).collection("watchHistory").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching watch history: \(error.localizedDescription)")
                return
            }

            let history = snapshot?.documents.compactMap { doc in
                try? doc.data(as: WatchEntry.self)
            } ?? []

            self.watchHistory = history.sorted(by: { $0.date > $1.date })
            self.calculateStreak()
        }
    }

    private func calculateStreak() {
        let dates = watchHistory.map { Calendar.current.startOfDay(for: $0.date) }
        let uniqueDates = Array(Set(dates)).sorted(by: >)

        var streak = 0
        var current = Calendar.current.startOfDay(for: Date())

        for date in uniqueDates {
            if Calendar.current.isDate(current, inSameDayAs: date) {
                streak += 1
                current = Calendar.current.date(byAdding: .day, value: -1, to: current)!
            } else {
                break
            }
        }

        self.streakCount = streak
    }
    
    private func fetchChallenges(userId: String) {
        db.collection("challenges")
            .whereField("challengerId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching challenges: \(error.localizedDescription)")
                    return
                }

                let sentChallenges = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Challenge.self)
                } ?? []

                self.db.collection("challenges")
                    .whereField("receiverId", isEqualTo: userId)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching received challenges: \(error.localizedDescription)")
                            return
                        }

                        let receivedChallenges = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: Challenge.self)
                        } ?? []

                        DispatchQueue.main.async {
                            self.challenges = sentChallenges + receivedChallenges
                        }
                    }
            }
    }


    func addWatchEntry(title: String, date: Date, emoji: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let id = UUID().uuidString
        let entry = WatchEntry(id: id, title: title, date: date, emoji: emoji)

        do {
            try db.collection("users").document(userID).collection("watchHistory").document(id).setData(from: entry)
            self.watchHistory.append(entry)
            self.calculateStreak()
        } catch {
            print("Error saving watch entry: \(error.localizedDescription)")
        }
    }

    func addFriend(friend: Friend) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        do {
            try db.collection("users").document(userId).collection("friends").document(friend.id).setData(from: friend)
            self.friends.append(friend)
        } catch {
            print("Error adding friend: \(error.localizedDescription)")
        }
    }

    func challengeFriend(friendId: String, movieTitle: String) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let challenge = [
            "challengerId": currentUserId,
            "movieTitle": movieTitle,
            "timestamp": Timestamp(date: Date())
        ] as [String : Any]

        db.collection("users").document(friendId).collection("challenges").addDocument(data: challenge) { error in
            if let error = error {
                print("Error sending challenge: \(error.localizedDescription)")
            } else {
                print("Challenge sent to \(friendId) for movie: \(movieTitle)")
            }
        }
    }
    
    func createChallenge(with friend: Friend, title: String, episodes: Int) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let id = UUID().uuidString
        let challenge = Challenge(
            id: id,
            challengerId: currentUserId,
            receiverId: friend.id,
            movieTitle: title,
            totalEpisodes: episodes,
            startDate: Date(),
            finishedBy: nil,
            status: "active"
        )

        do {
            try db.collection("challenges").document(id).setData(from: challenge)
            let progress = ChallengeProgress(id: currentUserId, episodesWatched: 0, finished: false)
            try db.collection("challenges").document(id).collection("progress").document(currentUserId).setData(from: progress)
            try db.collection("challenges").document(id).collection("progress").document(friend.id).setData(from: progress)
        } catch {
            print("Error creating challenge: \(error)")
        }
    }

    func updateProgress(challengeId: String, episodes: Int) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let progressRef = db.collection("challenges").document(challengeId).collection("progress").document(userId)
        progressRef.setData(["episodesWatched": episodes, "finished": false], merge: true)
    }

    func finishChallenge(challenge: Challenge) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("challenges").document(challenge.id).updateData([
            "status": "completed",
            "finishedBy": userId
        ])
        db.collection("challenges").document(challenge.id).collection("progress").document(userId).updateData([
            "finished": true
        ])
    }
    
    func addFriendByEmail(email: String) {
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print("Greška kod pretrage korisnika: \(error.localizedDescription)")
                return
            }

            guard let document = snapshot?.documents.first else {
                print("Korisnik nije pronađen.")
                return
            }

            do {
                let friendUser = try document.data(as: User.self)
                let friend = Friend(id: friendUser.id, username: friendUser.username, email: friendUser.email)
                self.addFriend(friend: friend)
            } catch {
                print("Greška kod dekodiranja korisnika: \(error)")
            }
        }
    }


}
