//
//  Track.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import UIKit

class Track {
    
    let name: String
    let artist: String
    let previewURL: URL
    let image: UIImage?
    let timeStamp: Double
    let index: Int
    var downloaded = false
    
    init(name: String, artist: String, previewURL: URL, image: UIImage?, timeStamp: Double, index: Int) {
        self.name = name
        self.artist = artist
        self.previewURL = previewURL
        self.image = image
        self.timeStamp = timeStamp
        self.index = index
    }
    
}
