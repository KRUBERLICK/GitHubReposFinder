//
//  ReadmeViewController.swift
//  GitHubReposFinder
//
//  Created by Данил Ильчишин on 4/26/16.
//  Copyright © 2016 KRUBERLICK. All rights reserved.
//

import UIKit

class ReadmeViewController: UIViewController {
    
    //MARK: - Outlets
    
    @IBOutlet weak var readmeTextArea: UITextView!
    
    
    
    //MARK: - Properties
    
    var repoOwner = User()
    var repoName = ""
    var readmeText = ""
    
    
    
    //MARK: - GitHub API
    
    //load repo's readme content
    func loadReadme() {
        let urlString = "https://api.github.com/repos/\(repoOwner.username)/\(repoName)/readme"
        
        //URL to server-side
        let myURL = NSURL(string: urlString)
        
        //if created NSURL is nil - something wrong with repo's name
        if myURL == nil {
            displayAlert("Error!", message: "Bad repository name")
            return
        }
        
        //initialize data task
        let task = NSURLSession.sharedSession().dataTaskWithURL(myURL!) { (data, response, error) -> Void in
            
            //if there was a connection error
            if error != nil {
                
                //display alert message (on main thread)
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //dismiss loading message view
                    self.displayAlert("Error!", message: "Connection error has occured. Please check your internet connection and try again.")
                })
                
                return
            }
            
            do {
                
                //decode json object received from server
                if let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSDictionary {
                    
                    
                    //get download url for readme content
                    if let downloadURL = jsonObject["download_url"] as? String {
                        
                        self.getReadmeText(downloadURL) //download raw readme text
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayAlert("Error", message: "Readme file not available")
                        })
                    }
                    
                } else {
                    
                    //display alert message (on main thread)
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.displayAlert("Error!", message: "Readme file not found")
                    })
                    
                    return
                }
            } catch {
                print("Error during JSON decoding")
            }
        }
        
        task.resume()
    }
    
    //load raw text of readme file, url for this was retrieved from json
    func getReadmeText(url: String) {
        let textURL = NSURL(string: url)
        let sharedSession = NSURLSession.sharedSession()
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(textURL!, completionHandler: { (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in
            
            //if there was a connection error
            if error != nil {
                
                //display alert message (on main thread)
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayAlert("Error!", message: "Connection error has occured. Please check your internet connection and try again.")
                })
                
                return
            }
            
            //text content of url
            var urlContents: NSString = ""
            
            do {
                
                //get text content
                urlContents = try NSString(contentsOfURL: location!, encoding: NSUTF8StringEncoding)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //set retrieved readme text and display it in readme text area
                    self.readmeText = urlContents as String
                    self.readmeTextArea.text = self.readmeText
                })
                
                
            } catch {
                print("Catch error")
            }
        })
        
        downloadTask.resume()
    }
    
    
    
    //MARK: - Alerts
    
    //dismiss current alert and display error
    func displayAlert(alertToDismiss: UIAlertController, title: String, message: String) {
            alertToDismiss.dismissViewControllerAnimated(true, completion: {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alert.addAction(okAction)
            self.presentViewController(alert, animated: true, completion: nil)
        });
    }
    
    //display error message
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    //MARK: - Superclass methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadReadme()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
