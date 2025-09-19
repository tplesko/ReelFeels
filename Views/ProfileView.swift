//
//  ProfileView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAddEntry = false
    @State private var newTitle = ""
    @State private var newEmoji = ""
    @State private var selectedDate = Date()
    @State private var episodeCounts: [String: Int] = [:]
    @State private var showFriendSearch = false
    @State private var searchFriendEmail = ""
    @State private var showCreateChallenge = false
    @State private var selectedFriend: Friend?
    @State private var challengeTitle = ""
    @State private var challengeEpisodes = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // HEADER
                    Text("👤 Moj profil")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    if let user = viewModel.user {
                        Text("Email: \(user.email)")
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // STREAK
                    Text("🔥 Trenutni streak: \(viewModel.streakCount) dana")
                        .foregroundColor(.orange)

                    Divider().background(Color.white.opacity(0.2))

                    // GLEDANJA
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📅 Pogledano:")
                            .foregroundColor(.white)
                            .font(.headline)

                        ForEach(viewModel.watchHistory.prefix(5)) { entry in
                            HStack {
                                Text(entry.emoji)
                                VStack(alignment: .leading) {
                                    Text(entry.title)
                                    Text(entry.date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .foregroundColor(.white)
                        }

                        Button("Prikaži sve") {} // Dodaj navigaciju ako želiš
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }

                    Button("+ Dodaj gledanje") {
                        showAddEntry = true
                    }
                    .padding(.top, 8)

                    Divider().background(Color.white.opacity(0.2))

                    // PRIJATELJI
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("👥 Prijatelji")
                                .foregroundColor(.white)
                                .font(.headline)
                            Spacer()
                            Button("Dodaj") {
                                showFriendSearch = true
                            }
                            .font(.caption)
                            .foregroundColor(.green)
                        }

                        ForEach(viewModel.friends) { friend in
                            HStack {
                                Text(friend.username)
                                    .foregroundColor(.white)
                                Spacer()
                                Button("🎯 Izazovi") {
                                    selectedFriend = friend
                                    showCreateChallenge = true
                                }
                                .font(.caption)
                                .foregroundColor(.yellow)
                            }
                        }
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // IZAZOVI
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎯 Moji izazovi")
                            .foregroundColor(.white)
                            .font(.headline)

                        ForEach(viewModel.challenges.filter { $0.status == "active" }) { challenge in
                            ChallengeRowView(
                                challenge: challenge,
                                episodeCounts: $episodeCounts,
                                viewModel: viewModel
                            )
                        }
                    }

                    Divider().background(Color.white.opacity(0.2))

                    // OBJAVE
                    VStack(alignment: .leading, spacing: 8) {
                        Text("📝 Moje objave")
                            .foregroundColor(.white)
                            .font(.headline)

                        ForEach(viewModel.userPosts.prefix(3)) { post in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(post.movieTitle)
                                        .foregroundColor(.purple)
                                    Spacer()
                                    Text(post.emoji)
                                }
                                Text(post.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }

                        Button("Prikaži sve") {} // Dodaj navigaciju ako želiš
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showAddEntry) {
                VStack(spacing: 12) {
                    Text("Dodaj gledanje")
                        .font(.title2)
                        .padding(.top)

                    TextField("Naziv sadržaja", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Emoji osjećaja", text: $newEmoji)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    DatePicker("Datum gledanja", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(GraphicalDatePickerStyle())

                    Button("Spremi") {
                        viewModel.addWatchEntry(title: newTitle, date: selectedDate, emoji: newEmoji)
                        showAddEntry = false
                        newTitle = ""
                        newEmoji = ""
                        selectedDate = Date()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showFriendSearch) {
                VStack(spacing: 16) {
                    Text("Dodaj prijatelja")
                        .font(.title2)

                    TextField("Email prijatelja", text: $searchFriendEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Dodaj") {
                        viewModel.addFriendByEmail(email: searchFriendEmail)
                        showFriendSearch = false
                        searchFriendEmail = ""
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showCreateChallenge) {
                VStack(spacing: 16) {
                    Text("🎯 Novi izazov")

                    TextField("Naziv serije / filma", text: $challengeTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Broj epizoda", text: $challengeEpisodes)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Započni izazov") {
                        if let friend = selectedFriend, let epCount = Int(challengeEpisodes) {
                            viewModel.createChallenge(with: friend, title: challengeTitle, episodes: epCount)
                            showCreateChallenge = false
                            challengeTitle = ""
                            challengeEpisodes = ""
                        }
                    }
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .presentationDetents([.medium, .large])
            }
            .background(Color("PrimaryBackground").ignoresSafeArea())
            .onAppear {
                viewModel.fetchUserData()
            }
        }
    }
}
