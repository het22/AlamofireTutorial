//
//  ImaggaRouter.swift
//  AlamofireTutorial
//
//  Created by Het Song on 11/04/2019.
//  Copyright © 2019 Het Song. All rights reserved.
//

import Alamofire

public enum ImaggaRouter: URLRequestConvertible {
    
    enum Constants {
        static let baseURLPath = "http://api.imagga.com/v1"
        static let authenticationToken = "Basic YourAuthToken"
    }
    
    case content
    case tags(String)
    
    var method: HTTPMethod {
        switch self {
        case .content:
            return .post
        case .tags:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .content:
            return "/content"
        case .tags:
            return "/tagging"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .tags(let contentID):
            return ["content": contentID]
        default:
            return [:]
        }
    }
    
    public func asURLRequest() throws -> URLRequest {
        let url = try Constants.baseURLPath.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(Constants.authenticationToken, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = TimeInterval(10*1000)
        return try URLEncoding.default.encode(request, with: parameters)
    }
}
