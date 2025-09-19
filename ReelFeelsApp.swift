//
//  ReelFeelsApp.swift
//  ReelFeels
//
//  Created by Tea Pleško on 22.05.2025..
//

import SwiftUI
import Firebase

@main
struct ReelFeelsApp: App {
    
    init(){
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
