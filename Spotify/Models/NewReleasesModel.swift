//
//  NewReleasesModel.swift
//  Spotify
//
//  Created by Alfan on 28/10/23.
//

import Foundation

struct NewReleasesModel: Codable {
    let albums: AlbumsModel
}

struct AlbumsModel: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let images: [ImageModel]
    let name: String
    let release_date: String
    let release_date_precision: String
    let total_tracks: Int
    let artists: [ArtistModel]
}

 
