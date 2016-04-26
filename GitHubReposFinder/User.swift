//
//  User.swift
//  GitHubReposFinder
//
//  Created by Данил Ильчишин on 4/26/16.
//  Copyright © 2016 KRUBERLICK. All rights reserved.
//

import UIKit

class User {
    var username: String
    var userURL: String
    var photo: UIImage
    var repos: [Repo]
    
    init() {
        self.username = ""
        self.userURL = ""
        self.photo = UIImage()
        self.repos = [Repo]()
    }
}