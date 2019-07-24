//
//  Track.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import Foundation

struct Track {
    
    let name: String
    let artist: String
    let previewURL: URL
    let index: Int
    var downloaded = false
    
    init(name: String, artist: String, previewURL: URL, index: Int) {
        self.name = name
        self.artist = artist
        self.previewURL = previewURL
        self.index = index
    }
    
}
