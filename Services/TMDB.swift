//
//  TMDB.swift
//  ReelFeels
//
//  Created by Tea Pleško on 02.09.2025..
//


import Foundation

enum TMDB {
    static let base = URL(string: "https://api.themoviedb.org/3")!
    static let images = URL(string: "https://image.tmdb.org/t/p/")!

    static var apiKey: String {
        (Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String) ?? ""
    }

    static func posterURL(path: String?, width: Int = 342) -> URL? {
        guard let path else { return nil }
        return images.appendingPathComponent("w\(width)").appendingPathComponent(path)
    }
}

enum TMDBError: Error { case missingKey, badURL }

protocol TMDBServicing {
    func searchMovies(query: String, language: String) async throws -> [TMDBMovie]
    func recommendations(for movieId: Int, language: String) async throws -> [TMDBMovie]
}

final class TMDBService: TMDBServicing {
    static let shared = TMDBService()
    private init() {}

    func searchMovies(query: String, language: String = "en-US") async throws -> [TMDBMovie] {
        guard !TMDB.apiKey.isEmpty else { throw TMDBError.missingKey }
        var comps = URLComponents(url: TMDB.base.appendingPathComponent("search/movie"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "api_key", value: TMDB.apiKey),
            .init(name: "query", value: query),
            .init(name: "include_adult", value: "false"),
            .init(name: "language", value: language)
        ]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        return try JSONDecoder().decode(TMDBPaged<TMDBMovie>.self, from: data).results
    }

    func recommendations(for movieId: Int, language: String = "en-US") async throws -> [TMDBMovie] {
        guard !TMDB.apiKey.isEmpty else { throw TMDBError.missingKey }
        let url = TMDB.base.appendingPathComponent("movie/\(movieId)/recommendations")
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.queryItems = [.init(name: "api_key", value: TMDB.apiKey),
                            .init(name: "language", value: language)]
        let (data, _) = try await URLSession.shared.data(from: comps.url!)
        return try JSONDecoder().decode(TMDBPaged<TMDBMovie>.self, from: data).results
    }
}
