//
//  DownloadService.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import Foundation

class DownloadService {
    var activeDownloads: [URL: Download] = [:]
    
    var downloadSession: URLSession!
    
    func startDownload(_ track: Track) {
        let download = Download(track: track)
        download.task = downloadSession.downloadTask(with: track.previewURL)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[download.track.previewURL] = download
    }
}
