//
//  GetPosts.swift
//  DiskExample
//
//  Created by Craig Rouse on 29/05/2019.
//  Copyright © 2019 Saoud Rizwan. All rights reserved.
//

import Foundation

func getPostsFromWeb(completion: (([Post]) -> Void)?) {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "jsonplaceholder.typicode.com"
    urlComponents.path = "/posts"
    let userIdItem = URLQueryItem(name: "userId", value: "1")
    urlComponents.queryItems = [userIdItem]
    guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    let task = session.dataTask(with: request) { (data, response, error) in
        DispatchQueue.main.async {
            guard error == nil else { fatalError(error!.localizedDescription) }
            guard let data = data else { fatalError("No data retrieved") }
            
            // We could directly save this data to disk...
            // try? Disk.save(data, to: .caches, as: "posts.json")
            
            // ... and retrieve it later as [Post]...
            // let posts = try? Disk.retrieve("posts.json", from: .caches, as: [Post].self)
            
            // ... but that's not good practice! Our networking and persistence logic should be separate.
            // Let's return the posts in our completion handler:
            do {
                let decoder = JSONDecoder()
                let posts = try decoder.decode([Post].self, from: data)
                completion?(posts)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    task.resume()
}
