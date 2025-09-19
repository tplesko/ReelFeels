//
//  TMDBMovie.swift
//  ReelFeels
//
//  Created by Tea Pleško on 02.09.2025..
//


struct TMDBMovie: Decodable, Identifiable {
    let id: Int
    let title: String
    let release_date: String?
    let poster_path: String?
}

struct TMDBPaged<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

func parseYear(_ s: String?) -> Int? {
    guard let s, s.count >= 4, let y = Int(s.prefix(4)) else { return nil }
    return y
}
