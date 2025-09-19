//
//  AddPostView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI

struct AddPostView: View {
    @StateObject private var vm = AddPostViewModel()
    private let emojis: [String] = ["😭","😂","😍","😱","🥹","🤯","😡"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("🎞️ Kako si se osjećao/la nakon gledanja?")
                    .font(.title2).bold()
                    .foregroundColor(.white)

                // Film / serija
                VStack(alignment: .leading, spacing: 8) {
                    Text("Film ili serija")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Unesi naziv sadržaja", text: $vm.movieTitle)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .onChange(of: vm.movieTitle) { newValue in
                            vm.onTitleChange(newValue)
                        }

                    // Autocomplete lista
                    if vm.isSearching {
                        ProgressView().tint(.white)
                    }

                    if !vm.suggestions.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(vm.suggestions, id: \.id) { m in
                                SuggestionRow(movie: m) {
                                    vm.selectSuggestion(m)
                                }
                            }
                        }
                    }
                }

                // Emoji picker
                Text("Odaberi emoji:")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)) {
                    ForEach(emojis, id: \.self) { e in
                        Text(e)
                            .font(.largeTitle)
                            .padding()
                            .background(vm.emoji == e ? Color.white.opacity(0.3) : Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .onTapGesture { vm.emoji = e }
                    }
                }

                // Opis
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opiši osjećaj (opcionalno)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))

                    TextField("Npr. dirnut, oduševljen, iznerviran…", text: $vm.description, axis: .vertical)
                        .lineLimit(3...8)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }

                Toggle("Objava je javna", isOn: $vm.isPublic)
                    .toggleStyle(SwitchToggleStyle(tint: .white))
                    .foregroundColor(.white.opacity(0.9))

                Button {
                    vm.addPost()
                } label: {
                    if vm.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Objavi osjećaj")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.white)
                .foregroundColor(.black)
                .cornerRadius(20)
                .disabled(vm.isSubmitting)
            }
            .padding()
        }
        .background(Color("PrimaryBackground").ignoresSafeArea())
        .alert("Obavijest", isPresented: $vm.showAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text(vm.alertMessage) }
    }
}

private struct SuggestionRow: View {
    let movie: TMDBMovie
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: TMDB.posterURL(path: movie.poster_path, width: 92)) { phase in
                    switch phase {
                    case .empty: Color.white.opacity(0.1)
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color.white.opacity(0.1)
                    @unknown default: Color.white.opacity(0.1)
                    }
                }
                .frame(width: 46, height: 69)
                .clipped()
                .cornerRadius(6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(movie.title)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    if let y = parseYear(movie.release_date) {
                        Text(String(y))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(10)
            .background(Color.white.opacity(0.06))
            .cornerRadius(8)
        }
    }
}
