//
//  ViewController.swift
//  GitHubReposFinder
//
//  Created by Данил Ильчишин on 4/26/16.
//  Copyright © 2016 KRUBERLICK. All rights reserved.
//

import UIKit

class SearchRepoViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userURLLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var reposTableView: UITableView!
    @IBOutlet weak var searchRepoButton: UIButton!
    
    
    
    //MARK: - Actions
    
    @IBAction func searchReposButtonTapped(sender: UIButton) {
        usernameTextField.resignFirstResponder() //hide keyboard
        loadRepos()
    }
    
    
    
    //MARK: - Properties
    
    var user = User()
    
    
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder() //hide keyboard
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        loadRepos()
    }
    
    
    
    //MARK: - GitHub API
    
    //loda repositories from specified user
    func loadRepos() {
        
        //show loading alert
        let loadingMsg = UIAlertController(title: "", message: "Searching For User...", preferredStyle: .Alert)
        self.presentViewController(loadingMsg, animated: true, completion: nil)
        
        let urlString = "https://api.github.com/users/\(usernameTextField.text!)/repos"
        
        //URL to server-side
        let myURL = NSURL(string: urlString)
        
        //if created NSURL is nil - username text field has invelid format
        if myURL == nil {
            displayAlert(loadingMsg, title: "Error!", message: "Username has invalid format")
            return
        }
        
        //initialize data task
        let task = NSURLSession.sharedSession().dataTaskWithURL(myURL!) { (data, response, error) -> Void in
            
            //if there was a connection error
            if error != nil {
                
                //display alert message (on main thread)
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //dismiss loading message view
                    self.displayAlert(loadingMsg, title: "Error!", message: "Connection error has occured. Please check your internet connection and try again.")
                })
                
                return
            }
            
            do {
                
                //decode json object received from server
                //if the user was found - server will return JSON array with repos
                //if not - it will return a single dictionary, so casting to NSArray will fail
                if let jsonObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSArray {
                    
                    //collect user data from JSON object and initialize all the stuff (on main thread)
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //if array is empty - user doesn't have any repositories
                        if (jsonObject.count < 1) {
                            self.displayAlert(loadingMsg, title: "Alert!", message: "User has no repositories")
                            return;
                        }
                        
                        //get user info from the first repository
                        let owner = jsonObject[0].objectForKey("owner")
                        
                        //initialize username and github profile url
                        self.user.username = owner?.objectForKey("login") as! String
                        self.user.userURL = owner?.objectForKey("html_url") as! String
                        
                        //load user image
                        let photoURL = NSURL(string: owner?.objectForKey("avatar_url") as! String)
                        let imageData = NSData(contentsOfURL: photoURL!)
                        self.user.photo = UIImage(data: imageData!)!
                        
                        //fetch user's repos to repos array
                        self.user.repos = [Repo]()
                        for el in jsonObject {
                            
                            //path to readme file json
                            let readmeURL = "https://api.github.com/repos/\(self.user.username)/\(el.objectForKey("name")!)/readme"
                            
                            self.user.repos.append(Repo(name: el.objectForKey("name") as! String, readMe: readmeURL))
                        }
                        
                        //set user info fields and photo
                        self.usernameLabel.text = self.user.username
                        self.userURLLabel.text = self.user.userURL
                        self.userPhotoImageView.image = self.user.photo
                        
                        //show user info
                        self.usernameLabel.hidden = false
                        self.userURLLabel.hidden = false
                        self.userPhotoImageView.hidden = false
                        self.reposTableView.hidden = false
                        
                        //reload repos table
                        self.reposTableView.reloadData()
                        
                        //dismiss loading message
                        loadingMsg.dismissViewControllerAnimated(true, completion: nil)
                    })
                    
                } else {
                    
                    //display alert message (on main thread)
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //dismiss loading message view
                        self.displayAlert(loadingMsg, title: "Error!", message: "User not found")
                    })
                    
                    return
                }
            } catch {
                print("Error during JSON decoding")
            }
        }
        
        task.resume()
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
        
        //make user photo image round
        userPhotoImageView.layer.cornerRadius = 50
        userPhotoImageView.layer.masksToBounds = true
        
        usernameTextField.delegate = self //set username text field delegate
        
        //setup table view's delegate and data source
        reposTableView.delegate = self
        reposTableView.dataSource = self
        
        //hide details
        usernameLabel.hidden = true
        userURLLabel.hidden = true
        userPhotoImageView.hidden = true
        reposTableView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: - TableView data source setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.repos.count
    }
    
    //configure table cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //dequeue reusable cell
        let cell = tableView.dequeueReusableCellWithIdentifier("RepoCell")! as UITableViewCell
        
        //get current repo from user's repos array
        let repo = user.repos[indexPath.row]
        
        cell.textLabel!.text = repo.name
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    
    
    //MARK: - UITableViewDelegate
    
    //perform segue to readme view when table row selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ViewReadme", sender: tableView)
    }
    
    
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier != "ViewReadme" {
            return
        }
        
        //get destination vc
        let readmeViewController = segue.destinationViewController as! ReadmeViewController
        
        //set back button
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .Plain, target: nil, action: nil)
        
        //set readme vc title
        readmeViewController.title = user.repos[reposTableView.indexPathForSelectedRow!.row].name
        
        //set readme vc repo owner and repo name
        readmeViewController.repoOwner = user
        readmeViewController.repoName = readmeViewController.title!
    }
}

