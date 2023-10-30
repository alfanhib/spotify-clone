//
//  SettingsModel.swift
//  Spotify
//
//  Created by Alfan on 26/10/23.
//

import Foundation

struct SettingsModel {
    
}

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
