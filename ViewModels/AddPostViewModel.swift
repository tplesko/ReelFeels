//
//  AddPostViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
final class AddPostViewModel: ObservableObject {
    // Form input
    @Published var movieTitle = ""
    @Published var emoji = ""
    @Published var description = ""
    @Published var isPublic = true

    // TMDB meta
    @Published var movieId: Int?
    @Published var posterPath: String?
    @Published var year: Int?

    // Sugestije (autocomplete)
    @Published var suggestions: [TMDBMovie] = []
    @Published var isSearching = false
    private var searchTask: Task<Void, Never>?

    // UI state
    @Published var isSubmitting = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    func clearForm() {
        movieTitle = ""; emoji = ""; description = ""; isPublic = true
        movieId = nil; posterPath = nil; year = nil
        suggestions = []
    }

    // Debounce pretrage – pozovi iz onChange
    func onTitleChange(_ text: String, service: TMDBServicing = TMDBService.shared) {
        searchTask?.cancel()
        suggestions = []
        movieId = nil; posterPath = nil; year = nil

        let q = text.trimmed
        guard q.count >= 2 else { return }

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(nanoseconds: 300_000_000) // 300ms
                self.isSearching = true
                let results = try await service.searchMovies(query: q, language: "en-US")
                if Task.isCancelled { return }
                self.suggestions = Array(results.prefix(8))
            } catch {
                if !Task.isCancelled { self.suggestions = [] }
            }
            self.isSearching = false
        }
    }

    func selectSuggestion(_ m: TMDBMovie) {
        movieTitle = m.title
        movieId = m.id
        posterPath = m.poster_path
        year = parseYear(m.release_date)
        suggestions = []
    }

    func addPost() {
        guard !movieTitle.trimmed.isEmpty else { alert("Naslov filma je obavezan"); return }
        guard !emoji.isEmpty else { alert("Odaberi emoji"); return }
        guard let uid = Auth.auth().currentUser?.uid else { alert("Nisi prijavljen/a"); return }
        let username  = Auth.auth().currentUser?.displayName ?? "Korisnik"

        isSubmitting = true
        let db = Firestore.firestore()

        var data: [String: Any] = [
            "userID": uid,
            "username": username,
            "movieTitle": movieTitle.trimmed,
            "movieTitleNormalized": movieTitle.lowercased(),
            "emoji": emoji,
            "description": description.trimmed,
            "isPublic": isPublic,
            "timestamp": FieldValue.serverTimestamp(),
            "likeCount": 0,
            "commentCount": 0
        ]
        if let movieId { data["movieId"] = movieId }
        if let posterPath { data["posterPath"] = posterPath }
        if let year { data["year"] = year }

        db.collection("posts").addDocument(data: data) { [weak self] error in
            guard let self else { return }
            self.isSubmitting = false
            if let error { self.alert("Greška pri spremanju: \(error.localizedDescription)"); return }
            self.clearForm()
            self.alert("Objava je uspješno objavljena 🎉")
        }
    }

    private func alert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}
