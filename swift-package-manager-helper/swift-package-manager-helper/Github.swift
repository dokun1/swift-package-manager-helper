//
//  Github.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Foundation

fileprivate struct GithubResponse: Codable {
    var repositories: [Repository]
    
    enum CodingKeys: String, CodingKey {
        case repositories = "items"
    }
}

struct Release: Codable {
    var name: String
    var sha: String?
    var url: String?
    var commit: ReleaseCommit
    
    struct ReleaseCommit: Codable {
        var sha: String
        var url: String
    }
}

struct Repository: Codable {
    var fullName: String
    var url: String
    var stars: Double
    var name: String? {
        let components = fullName.components(separatedBy: "/")
        return components.last
    }
    var owner: String? {
        let components = fullName.components(separatedBy: "/")
        return components.first
    }
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case url = "clone_url"
        case stars = "stargazers_count"
    }
}

enum GithubError: Error {
    case badQuery
    case badRepository
    case noData
    case malformedData
    case badResponse(response: HTTPURLResponse)
    case other(reason: String)
}

extension GithubError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badQuery:
            return "The search term you entered could not be searched for."
        case .noData:
            return "The search did not return any data."
        case .malformedData:
            return "The response from GitHub could not be appropriately parsed."
        case .badResponse(let response):
            return "The GitHub API responded with a status code of \(response.statusCode)"
        case .other(let reason):
            return "An unknown error occurred: \(reason)"
        case .badRepository:
            return "The repository you entered could not be used to find any releases."
        }
    }
}

class Github {
    static func getReleases(for repository: Repository, results: @escaping ([Release]?, GithubError?) -> ()){
        guard let request = constructReleaseRequest(repository: repository) else {
            return results(nil, .badRepository)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    return results(nil, .other(reason: error.localizedDescription))
                }
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    return results(nil, .badResponse(response: httpResponse))
                }
            }
            if let data = data {
                let releases = try? JSONDecoder().decode([Release].self, from: data)
                DispatchQueue.main.async {
                    return results(releases, nil)
                }
            }
        }
        task.resume()
    }
    
    static func search(for query: String, results: @escaping ([Repository]?, GithubError?) -> ()) {
        guard let request = constructSearchRequest(query: query) else {
            return results(nil, .badQuery)
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    return results(nil, .other(reason: error.localizedDescription))
                }
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    return results(nil, .badResponse(response: httpResponse))
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
    
    private class func constructReleaseRequest(repository: Repository) -> URLRequest? {
        guard let repo = repository.name, let owner = repository.owner else {
            return nil
        }
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/repos/\(owner)/\(repo)/tags"
        guard let url = components.url else {
            return nil
        }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "GET"
        return request
    }
    
    private class func constructSearchRequest(query: String) -> URLRequest? {
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
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "GET"
        return request
    }
}
