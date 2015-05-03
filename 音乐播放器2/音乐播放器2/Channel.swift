//
//  Channel.swift
//  音乐播放器2
//
//  Created by 李鑫 on 14-8-1.
//  Copyright (c) 2014年 李鑫. All rights reserved.
//

import UIKit

class Channel: NSObject {
    
    var id: String!
    var title: String!
    var cate_id: String!
    var cate: String!

    init(dict: NSDictionary) {
        super.init()
        
        self.id = dict["id"] as String
        self.title = dict["title"] as String
        self.cate_id = dict["cate_id"] as String
        self.cate = dict["cate"] as String
    }
}
