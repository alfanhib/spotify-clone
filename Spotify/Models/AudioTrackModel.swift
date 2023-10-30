//
//  AudioTrackModel.swift
//  Spotify
//
//  Created by Alfan on 29/10/23.
//

import Foundation

struct AudioTrackModel: Codable  {
    let album: Album
    let artists: [ArtistModel]
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
    let popularity: Int
}
