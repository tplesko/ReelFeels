//
//  AddWatchEntryView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//


import SwiftUI

struct AddWatchEntryView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var title = ""
    @State private var emoji = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Film/serija")) {
                    TextField("Naslov", text: $title)
                }
                Section(header: Text("Kako si se osjećao/la?")) {
                    TextField("Emoji", text: $emoji)
                }
                Section(header: Text("Datum gledanja")) {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Dodaj gledanje")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Spremi") {
                        viewModel.addWatchEntry(title: title, date: date, emoji: emoji)
                        dismiss()
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Odustani") {
                        dismiss()
                    }
                }
            }
        }
    }
}
