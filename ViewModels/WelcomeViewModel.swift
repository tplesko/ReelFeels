//
//  WelcomeViewModel.swift
//  ReelFeels
//
//  Created by Tea Pleško on 28.05.2025..
//


import SwiftUI

class WelcomeViewModel: ObservableObject {
    @Published var activeIndex = 0
    let emojis = ["😍", "😱", "🫣", "😂", "😭"]
    
    private var timer: Timer?

    init() {
        startWave()
    }

    func startWave() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            DispatchQueue.main.async {
                self.activeIndex = (self.activeIndex + 1) % self.emojis.count
            }
        }
    }

    deinit {
        timer?.invalidate()
    }
}
