//
//  ViewController.swift
//  DiskExample
//
//  Created by Saoud Rizwan on 7/23/17.
//  Copyright © 2017 Saoud Rizwan. All rights reserved.
//

import UIKit
import Disk

class ViewController: UIViewController {
    
    // MARK: Properties
    
    var posts = [Post]()
    
    // MARK: IBOutlets
    
    @IBOutlet weak var resultsTextView: UITextView!
    
    // MARK: IBActions
    
    @IBAction func getTapped(_ sender: Any) {
        getPostsFromWeb { (posts) in
            print("Posts retrieved from network request successfully!")
            self.posts = posts
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // Disk is smart about error handling, so when an error does occur, Disk throws
        //  a fatalError so you can figure out the problem in your persistence game plan
        Disk.store(posts, to: .documents, as: "posts")
        
        print("Stored posts to disk!")
    }
    
    @IBAction func retrieveTapped(_ sender: Any) {
        guard let retrievedPosts = Disk.retrieve("posts", from: .documents, as: [Post].self) else { return }
        
        // If you Option+Click 'retrievedPosts' above, you'll notice that its type is [Post]
        // without ever having to downcast our return value. Pretty neat, huh?
        var result: String = ""
        for post in retrievedPosts {
            result.append("\(post.id): \(post.title)\n\(post.body)\n\n")
        }
        self.resultsTextView.text = result
        
        print("Retrieved posts from disk!")
    }
    
    // MARK: Networking
    
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
                
                // We could directly store this data to disk...
                // Disk.store(data, to: .caches, as: "posts")
                
                // ... and retrieve it later as [Post]...
                // let postsFromDisk = Disk.retrieve("posts", from: .caches, as: [Post].self)!
                
                // ... but that's not good practice! Let's return the posts in our completion handler:
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
}

