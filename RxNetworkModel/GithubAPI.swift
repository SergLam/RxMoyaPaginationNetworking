//
//  GithubEndpoint.swift
//  RxNetworkModel
//
//  Created by Leo on 2016/6/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Foundation
import Moya

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}


let requestClosure = { (endpoint: Endpoint<GitHub>, done: MoyaProvider.RequestResultClosure) in
    var request: URLRequest = endpoint.urlRequest!
    //request.httpShouldHandleCookies = false
    done(.success(request))
}


let endpointClosure = { (target: GitHub) -> Endpoint<GitHub> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    var httpHeaderFields:[String: String]? = nil
    
    return Endpoint(url: url, sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: target.method, parameters: target.parameters, parameterEncoding: URLEncoding.default, httpHeaderFields: httpHeaderFields)
    
}


let failureEndpointClosure = { (target: GitHub) -> Endpoint<GitHub> in
    let error = NSError(domain: "com.moya.moyaerror", code: 0, userInfo: [NSLocalizedDescriptionKey: "Houston, we have a problem"])
    return Endpoint<GitHub>(url: url(route: target), sampleResponseClosure: {.networkError(error)}, method: target.method, parameters: target.parameters)
}


let githubProvider = RxMoyaProvider<GitHub>(
    endpointClosure:endpointClosure,
    requestClosure:requestClosure,
    plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)]
)

public func url(route: TargetType) -> String {
    return route.baseURL.appendingPathComponent(route.path).absoluteString
}


private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}


enum GitHub {
    case FetchRepositorys(keyword: String, page: Int)
}

extension GitHub: TargetType {
    /// The type of HTTP task to be performed.
    public var task: Task {
        return .request
    }

    public var baseURL: URL { return URL(string: "https://api.github.com")! }

    /// The parameters to be incoded in the request.
    var path: String {
        switch self {
        case .FetchRepositorys:
            return "/search/repositories"
        }
    }
    
    var method: Moya.Method {
       return .get
    }
    
    var parameters: [String : Any]?  {
        switch self {
        case .FetchRepositorys(let keyword,let page):
            return ["q":keyword,"page":page]
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        
        return JSONEncoding.default
    }

    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }

    
}
