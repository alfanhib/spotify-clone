//
//  Artist.swift
//  Spotify
//
//  Created by Alfan on 28/10/23.
//

import Foundation

struct ArtistModel: Codable {
    let id: String
    let name: String
    let type: String
    let external_urls: [String: String]
}
