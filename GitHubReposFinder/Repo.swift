//
//  Repo.swift
//  GitHubReposFinder
//
//  Created by Данил Ильчишин on 4/26/16.
//  Copyright © 2016 KRUBERLICK. All rights reserved.
//

import Foundation

class Repo {
    var name: String
    var readMe: String
    
    init(name: String, readMe: String) {
        self.name = name
        self.readMe = readMe
    }
}