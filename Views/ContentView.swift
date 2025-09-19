//
//  ContentView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 29.05.2025..
//


import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            WelcomeView(isLoggedIn: $isLoggedIn)
        }
    }
}
