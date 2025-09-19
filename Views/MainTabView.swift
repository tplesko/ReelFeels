//
//  MainTabView.swift
//  ReelFeels
//
//  Created by Tea Pleško on 29.05.2025..
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeFeedView()
                .tabItem {
                    Label("Feed", systemImage: "house.fill")
                }

            AddPostView()
                .tabItem {
                    Label("Dodaj", systemImage: "plus.circle.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle.fill")
                }
        }
        .accentColor(.white)
        .toolbarBackground(Color("PrimaryBackground"), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}
