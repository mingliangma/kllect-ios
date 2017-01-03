//
//  Video.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class Video: NSObject {
    var id:String
    var title:String
    var publisher:String
    var youtubeUrl:String
    var imageUrl:String
    var duration:Int
    
    init?(object:AnyObject) {
        guard let v = object.object(forKey: "isVideo") as? Bool, v == true else { print("article is not a video, cannot initialize"); return nil }
        guard let id = object.object(forKey: "id") as? String else { print("id missing, cannot initialize Video"); return nil }
        guard let title = object.object(forKey: "title") as? String else { print("title missing, cannot initialize Video"); return nil }
        guard let publisher = object.object(forKey: "publisher") as? String else { print("publisher missing, cannot initialize Video"); return nil }
        guard let ytUrl = object.object(forKey: "youtubeUrl") as? String else { print("youtubeUrl missing, cannot initialize Video"); return nil }
        guard let imgUrl = object.object(forKey: "imageUrl") as? String else { print("image url missing, cannot initialize Video"); return nil }
        guard let duration = object.object(forKey: "duration") as? Int else { print("duration missing, cannot initialize Video"); return nil }
        
        self.id = id
        self.title = title
        self.publisher = publisher
        self.youtubeUrl = ytUrl
        self.duration = duration
        self.imageUrl = imgUrl
    }
    
    
    // Computed
    
    var formattedDuration:String {
        let seconds = duration % 60
        let minutes = Int(floor(Double(duration - seconds) / 60))
        let hours = Int(floor(Double(minutes - minutes % 60) / 60))
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var thumbnailURL:URL {
        let pattern = "(hq|mq)?default"
        let reg = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let new = reg.stringByReplacingMatches(in: imageUrl, options: [], range: NSRange(location: 0, length: self.imageUrl.characters.count), withTemplate: "hqdefault")
        return URL(string: new)!
    }
    
    var youtubeId:String? {
        let url = self.youtubeUrl
        let id = url.components(separatedBy: "/").last
        return id
    }
}







