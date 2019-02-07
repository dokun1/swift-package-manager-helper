//
//  DependencyFactory.swift
//  swift-package-manager-helper
//
//  Created by David Okun on 2/6/19.
//  Copyright © 2019 David Okun. All rights reserved.
//

import Foundation

fileprivate extension String {
    func sanitizeForSPM() -> String {
        return self.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func validateHash() -> Bool {
        let sanitized = self.sanitizeForSPM()
        do {
            let regex = try NSRegularExpression(pattern: "\\b[0-9a-f]{5,40}\\b")
            let results = regex.matches(in: sanitized, options: [], range: NSMakeRange(0, self.count))
            return results.count == 1
        } catch {
            return false
        }
    }
}

enum SPMVersionChoice {
    case from(version: String)
    case upToNextMajor(version: String)
    case upToNextMinor(version: String)
    case exact(version: String)
    case openRange(from: String, to: String)
    case closedRange(from: String, to: String)
    case gitBranch(branch: String)
    case gitRevision(revision: String)
    
    func resolution() -> String? {
        switch self {
        case .from(let version):
            return "from: \"\(version.sanitizeForSPM())\""
        case .upToNextMajor(let version):
            return ".upToNextMajor(from: \"\(version.sanitizeForSPM())\")"
        case .upToNextMinor(let version):
            return ".upToNextMinor(from: \"\(version.sanitizeForSPM())\")"
        case .exact(let version):
            return ".exact(\"\(version.sanitizeForSPM())\")"
        case .openRange(let minimum, let maximum):
            return "\"\(minimum.sanitizeForSPM())\"..<\"\(maximum.sanitizeForSPM())\""
        case .closedRange(let minimum, let maximum):
            return "\"\(minimum.sanitizeForSPM())\"...\"\(maximum.sanitizeForSPM())\""
        case .gitBranch(let branch):
            return ".branch(\"\(branch.sanitizeForSPM())\")"
        case .gitRevision(let revision):
            if revision.validateHash() {
                return ".revision(\"\(revision.sanitizeForSPM())\")"
            } else {
                return nil
            }
        }
    }
}

class DependencyFactory {
    public class func resolveString(repositoryURL: String, version: SPMVersionChoice) -> String? {
        guard let resolution = version.resolution() else {
            return nil
        }
        return ".package(url: \"\(repositoryURL)\", \(resolution)),"
    }
}
