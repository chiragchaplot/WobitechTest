////
//  MockRequests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation
@testable import Wobitech_Test

struct MockAPIRequest: APIRequest {
  let path: String
  var parameters: [String: Any]?
}

struct InvalidAPIRequest: APIRequest {
  let path: String = "unused"

  func asURLRequest() -> URLRequest? {
    nil
  }
}
