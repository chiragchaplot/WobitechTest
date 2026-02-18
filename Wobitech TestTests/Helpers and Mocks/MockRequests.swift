////
//  MockRequests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

@testable import Wobitech_Test
import Foundation

struct MockAPIRequest: APIRequest {
    let path: String
    var parameters: [String: Any]? = nil
}

struct InvalidAPIRequest: APIRequest {
    let path: String = "unused"

    func asURLRequest() -> URLRequest? {
        nil
    }
}

