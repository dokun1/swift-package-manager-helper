//
//  Github.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Foundation

struct GithubResponse: Codable {
    var repositories: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case repositories = "items"
    }
}

struct Repository: Codable {
    var name: String
    var url: String
    var stars: Double
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case url = "clone_url"
        case stars = "stargazers_count"
    }
}

enum GithubError: Error {
    case badQuery
    case noData
    case malformedData
    case other(reason: String)
}

class Github {
    static func search(for query: String, results: @escaping ([Repository]?, GithubError?) -> ()) {
        guard let request = constructRequest(query: query) else {
            return results(nil, .badQuery)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    return results(nil, .other(reason: error.localizedDescription))
                }
            }
            if let data = data {
                let githubResponse = try? JSONDecoder().decode(GithubResponse.self, from: data)
                if let repositories = githubResponse?.repositories {
                    DispatchQueue.main.async {
                        return results(repositories, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        return results(nil, .malformedData)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    return results(nil, .noData)
                }
            }
        }
        task.resume()
    }
    
    private class func constructRequest(query: String) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/repositories"
        components.queryItems = [
            URLQueryItem(name: "q", value: "\(query)+language:swift"),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc")
        ]
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }
}
