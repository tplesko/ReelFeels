//
//  ConspiracySectionView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//
import SwiftUI

struct ConspiracySectionView: View {
    let postId: String
    let userId: String
    let username: String
    @StateObject private var viewModel = ConspiracyViewModel()
    @State private var newTheory = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🧠 Teorije zavjere")
                .font(.headline)

            ForEach(viewModel.theories) { theory in
                VStack(alignment: .leading, spacing: 6) {
                    Text(theory.username).font(.subheadline).foregroundColor(.gray)
                    Text(theory.text)

                    // Odgovori
                    ReplyListView(postId: postId, theoryId: theory.id ?? "")
                    
                    ReplyInputView(postId: postId, theoryId: theory.id ?? "", userId: userId, username: username)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            HStack {
                TextField("Dodaj teoriju...", text: $newTheory)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Objavi") {
                    guard !newTheory.isEmpty else { return }
                    viewModel.addTheory(to: postId, text: newTheory, userId: userId, username: username)
                    newTheory = ""
                }
            }

        }
        .padding()
        .onAppear {
            viewModel.fetchTheories(for: postId)
        }
    }
}
