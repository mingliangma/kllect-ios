//
//  KllectAPI.swift
//  Kllect
//
//  Created by Arthur Belair on 2016-12-07.
//  Copyright © 2016 Guarana Technologies Inc. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class KllectAPI: NSObject {
    
    static let shared = KllectAPI()
    
    struct Error {
        static let Unknown = NSError(domain: "KllectAPI", code: -1, userInfo: [NSLocalizedDescriptionKey:"An unknown error occured. Please try again later"])
        static let NoUser = NSError(domain: "KllectAPI", code: 1, userInfo: [NSLocalizedDescriptionKey:"You need to login to perform this action"])
    }
    
    enum Router: URLRequestConvertible {
        case getTopics
        case getArticles(userId:String, offset:Int)
        case getArticlesByTopic(topicIdentifier:String, offset:Int)
        case recordUserTopics(userToken:String, topicsIds:[String], birthdateString:String?)
        case recordRelevancy(videoId:String, topicIdentifier:String, relevant:Bool, userToken:String)
        
        
        static let baseURLString = "http://api.app.kllect.com"
        
        var method: HTTPMethod {
            switch self {
            case .getTopics, .getArticles(_), .getArticlesByTopic(_):
                return .get
            case .recordUserTopics(_), .recordRelevancy(_):
                return .post
            }
        }
        
        var path: String {
            switch self {
            case .getTopics, .recordUserTopics(_):
                return "/topics"
            case .getArticlesByTopic(let t, _):
                return "/articles/topic/" + t
            case .getArticles(_):
                return "/articles/recommending"
            case .recordRelevancy(let videoId, _, _, _):
                return "/article/" + videoId + "/relevancy"
            }
        }
        
        var parameters:[String:Any] {
            switch self {
            case .getArticlesByTopic(_, let o):
                return ["offset":o]
            case .getArticles(let id, let o):
                return ["offset":o, "uid":id]
            case .recordRelevancy(_, let topic, let relevant, _):
                return ["topic":topic, "isRelevant":relevant ? "true":"false"]
            default:
                return [:]
            }
        }
        
        var body:[String:Any] {
            switch self {
            case .recordUserTopics(let userToken, let topics, let birthdateString):
                if let bd = birthdateString {
                    return ["token":userToken, "topicIds":topics, "birthdate":bd]
                }
                else {
                    return ["token":userToken, "topicIds":topics]
                }
            case .recordRelevancy(_, _, _, let userToken):
                return ["token":userToken]
            default:
                return [:]
            }
        }
        
        func asURLRequest() throws -> URLRequest {
            let url = URL(string: Router.baseURLString)!.appendingPathComponent(self.path)
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if body.count > 0 {
                urlRequest = try JSONEncoding.default.encode(urlRequest, with: self.body)
            }
            if parameters.count > 0 {
                urlRequest = try URLEncoding.queryString.encode(urlRequest, with: self.parameters)
            }
            
            
            return urlRequest
        }
        
        func debug() {
            if let req = try? self.asURLRequest() {
                dump(req)
            }
        }
    }
    
    
    func getTopics(callback:@escaping (_ topics:[Topic]?) -> Void) {
        let route = Router.getTopics
        route.debug()
        Alamofire.request(route).validate().responseJSON { (response:DataResponse<Any>) in
            if let data = response.result.value as? [AnyObject] {
                let topics = data.flatMap({ Topic(object: $0) })
                callback(topics)
            }
            else {
                callback(nil)
            }
        }
    }
    
    func recordUserTopics(topics:[Topic], birthdate:Date?, callback: @escaping (Bool, NSError?) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else { callback(false, Error.NoUser); return }
        currentUser.getTokenWithCompletion { (token, error) in
            if let err = error {
                callback(false, err as NSError)
            }
            else if let t = token {
                var bdayString:String? = nil
                if let bd = birthdate {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    bdayString = dateFormatter.string(from: bd)
                }
                
                let route = Router.recordUserTopics(userToken: t, topicsIds: topics.map({ $0.id }), birthdateString: bdayString)
                route.debug()
                Alamofire.request(route).validate().responseJSON(completionHandler: { (response:DataResponse<Any>) in
                    if let err = response.result.error {
                        callback(false, err as NSError)
                    }
                    else {
                        callback(true, nil)
                    }
                })
            }
            else {
                callback(false, Error.Unknown)
            }
        }
    }
    
    func getVideoFeed(offset:Int, callback:@escaping (_ videos:[Video]?) -> Void) {
        guard let user = FIRAuth.auth()?.currentUser else { callback(nil); return }
        let route = Router.getArticles(userId: user.uid, offset: offset)
        route.debug()
        Alamofire.request(route).validate().responseJSON { (response:DataResponse<Any>) in
            if let data = (response.result.value as AnyObject?)?.object(forKey: "articles") as? [AnyObject] {
                let videos = data.flatMap({ Video(object: $0) })
                callback(videos)
            }
            else {
                callback(nil)
            }
        }
    }
    
    func getVideoFeed(for topic:Topic, offset:Int, callback:@escaping (_ videos:[Video]?) -> Void) {
        let route = Router.getArticlesByTopic(topicIdentifier: topic.identifier, offset: offset)
        route.debug()
        Alamofire.request(route).validate().responseJSON { (response:DataResponse<Any>) in
            if let data = (response.result.value as AnyObject?)?.object(forKey: "articles") as? [AnyObject] {
                let videos = data.flatMap({ Video(object: $0) })
                callback(videos)
            }
            else {
                callback(nil)
            }
        }
    }

    
    func recordRelevancy(video:Video, topic:Topic, relevant:Bool, callback: @escaping (_ success:Bool, _ error:NSError?) -> Void) {
        guard let currentUser = FIRAuth.auth()?.currentUser else { callback(false, Error.NoUser); return }
        currentUser.getTokenWithCompletion { (token, error1) in
            if let err = error1 {
                callback(false, err as NSError)
            }
            else if let t = token {
                let route = Router.recordRelevancy(videoId: video.id, topicIdentifier: topic.identifier, relevant: relevant, userToken: t)
                route.debug()
                Alamofire.request(route).validate().responseJSON(completionHandler: { (response:DataResponse<Any>) in
                    if let err = response.result.error {
                        callback(false, err as NSError)
                    }
                    else {
                        callback(true, nil)
                    }
                })
            }
            else {
                callback(false, Error.Unknown)
            }
        }
    }
    
    
}












