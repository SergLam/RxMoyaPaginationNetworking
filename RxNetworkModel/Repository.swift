//
//  Repository.swift
//  RxNetworkModel
//
//  Created by Leo on 2016/6/7.
//  Copyright © 2016年 Leo. All rights reserved.
//

import Mapper

struct Repository: Mappable {
    
    var name:String!
    var full_name:String!
    var url:String!
    var stargazers_count:Int!
    
    init(map: Mapper) throws {
        try name = map.from("name")
        try full_name = map.from("full_name")
        try url = map.from("url")
        try stargazers_count = map.from("stargazers_count")
    }

}