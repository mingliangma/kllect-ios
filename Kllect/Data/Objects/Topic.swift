//
//  Topic.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit

class Topic: NSObject {

    var identifier:String
    var displayName:String
    var id:String
    
    init?(object:AnyObject) {
        guard let identifier = object.object(forKey: "topic") as? String else { print("no 'topic' value to initialize topic"); return nil }
        guard let name = object.object(forKey: "displayName") as? String else { print("no 'name' value to initialize topic"); return nil }
        guard let id = object.object(forKey: "id") as? String else { print("no 'id' value to initialize topic"); return nil }
        
        self.identifier = identifier
        self.displayName = name
        self.id = id
    }
}
