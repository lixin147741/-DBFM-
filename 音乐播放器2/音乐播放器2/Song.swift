//
//  Song.swift
//  音乐播放器2
//
//  Created by 李鑫 on 14-8-1.
//  Copyright (c) 2014年 李鑫. All rights reserved.
//
import Foundation

class Song: NSObject, NSCoding {
    
    func encodeWithCoder(aCoder: NSCoder!) {
        aCoder.encodeInteger(self.id, forKey: "id")
        aCoder.encodeObject(self.songName, forKey: "songName")
        //...
    }
    
    init(coder aDecoder: NSCoder!) {
        self.id = aDecoder.decodeIntegerForKey("id")
        self.songName = aDecoder.decodeObjectForKey("songName") as String
    }
    
    init() {
        
    }

    var id: Int!
    var songName: String!
    var artistName: String!
    var albumName: String!
    var songPicSmall: String!
    var songPicBig: String!
    var songPicRadio: String!
    var lrcLink: String!
    var songLink: String!
    var showLink: String!
    
    func refreshSong(dic: NSDictionary) {
        self.songName = dic["songName"] as String
        self.artistName = dic["artistName"] as String
        self.albumName = dic["albumName"] as String
        self.songPicSmall = dic["songPicSmall"] as String
        self.songPicBig = dic["songPicBig"] as String
        self.songLink = dic["songLink"] as String
        self.lrcLink = dic["lrcLink"] as String
        self.showLink = dic["showLink"] as String
    }
    
    
}
