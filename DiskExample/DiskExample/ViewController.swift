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
        // Be sure to check out the comments in the networking function below
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        getPostsFromWeb { (posts) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("Posts retrieved from network request successfully!")
            self.posts = posts
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        // Disk is thorough when it comes to error handling, so make sure you understand why an error occurs when it does.
        do {
            try Disk.save(self.posts, to: .documents, as: "posts.json")
        } catch let error as NSError {
            fatalError("""
                Domain: \(error.domain)
                Code: \(error.code)
                Description: \(error.localizedDescription)
                Failure Reason: \(error.localizedFailureReason ?? "")
                Suggestions: \(error.localizedRecoverySuggestion ?? "")
                """)
        }
        // Notice how we use a do, catch, try block when using Disk, this is because almost all of Disk's methods
        // are throwing functions, meaning they will throw an error if something goes wrong. In almost all cases, these
        // errors come with a lot of information like a description, failure reason, and recover suggestions.
        
        // You could alternatively use try! or try? instead of do, catch, try blocks
        // try? Disk.save(self.posts, to: .documents, as: "posts.json") // returns a discardable result of nil
        // try! Disk.save(self.posts, to: .documents, as: "posts.json") // will crash the app during runtime if this fails
        
        // You can also save files in folder hierarchies, for example:
        // try? Disk.save(self.posts, to: .caches, as: "Posts/MyCoolPosts/1.json")
        // This will automatically create the Posts and MyCoolPosts folders
        
        // If you want to save new data to a file location, you can treat the file as an array and simply append to it as well.
        let newPost = Post(userId: 0, id: self.posts.count + 1, title: "Appended Post", body: "...")
        try? Disk.append(newPost, to: "posts.json", in: .documents)
        
        print("Saved posts to disk!")
    }
    
    @IBAction func retrieveTapped(_ sender: Any) {
        // We'll keep things simple here by using try?, but it's good practice to handle Disk with do, catch, try blocks
        // so you can make sure everything is going according to plan.
        if let retrievedPosts = try? Disk.retrieve("posts.json", from: .documents, as: [Post].self) {
            // If you Option+Click 'retrievedPosts' above, you'll notice that its type is [Post]
            // Pretty neat, huh?
            
            var result: String = ""
            for post in retrievedPosts {
                result.append("\(post.id): \(post.title)\n\(post.body)\n\n")
            }
            self.resultsTextView.text = result
            
            print("Retrieved posts from disk!")
        }
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
}

