//
//  FeaturedPlaylistsModel.swift
//  Spotify
//
//  Created by Alfan on 28/10/23.
//

import Foundation

struct FeaturedPlaylistsModel: Codable {
    let playlists: PlaylistItemModel
}

struct PlaylistItemModel: Codable {
    let items: [Playlist]
}

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [ImageModel]
    let name: String
    let owner: OwnerModel
}

struct OwnerModel: Codable {
    let display_name: String
    let id: String
    let type: String
    let external_urls: [String: String]
} 
