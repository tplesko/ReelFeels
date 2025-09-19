//
//  WatchEntry.swift
//  ReelFeels
//
//  Created by Tea Pleško on 27.06.2025..
//
import Foundation

struct WatchEntry: Identifiable, Codable {
    var id: String
    var title: String
    var date: Date
    var emoji: String
}
