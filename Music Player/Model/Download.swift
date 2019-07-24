//
//  Download.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import Foundation

class Download {
    
    var track: Track
    init(track: Track) {
        self.track = track
    }
    
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
    var progress: Float = 0
    
}
