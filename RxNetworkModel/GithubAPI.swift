//
//  GithubEndpoint.swift
//  RxNetworkModel
//
//  Created by Leo on 2016/6/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Foundation
import Moya

private extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

enum GitHub {
    case FetchRepositorys(keyword: String, page: Int)
}

extension GitHub: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://api.github.com")! }
    var path: String {
        switch self {
        case .FetchRepositorys:
            return "/search/repositories"
        }
    }
    var method: Moya.Method {
        return .GET
    }
    var parameters: [String: AnyObject]? {
        switch self {
        case .FetchRepositorys(let keyword,let page):
            return ["q":keyword,"page":page]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return method == .GET ? .URL : .JSON
        }
    }
    var sampleData: NSData {
        return "".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
}