//
//  SearchViewController.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol SearchViewControllerDelegate {
    func play(_ track: Track)
}

class SearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    var delegate: SearchViewControllerDelegate!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    lazy var downloadSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var searchResults: [Track] = []
    let queryService = QueryService()
    let downloadService = DownloadService()
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    let playerViewController = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        tableView.rowHeight = 62
        
        downloadService.downloadSession = downloadSession
        
        delegate = playerViewController
        addChild(playerViewController)
        playerViewController.view.frame = CGRect(x: 0, y: 300, width: view.frame.width, height: view.frame.height - 300)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
    }
    
    func playDownload(_ track: Track) {
        if player != nil {
            player?.pause()
        }
        let url = localFilePath(for: track.previewURL)

        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        self.view.layer.addSublayer(playerLayer)
        player!.play()
    }
}

//MARK: TableView
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "TrackCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? TrackCell else { return UITableViewCell() }
        
        let track = searchResults[indexPath.row]
        let download = downloadService.activeDownloads[track.previewURL]
        cell.configure(track: track, downloaded: track.downloaded, download: download )
        cell.delegate = self
        
        return cell
    }
    
    
}

// MARK: - TrackCellDelegate
extension SearchViewController: TrackCellDelegate {
    func pauseTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.pauseDownload(track)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func resumeTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.resumeDownload(track)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func cancelTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.cancelDownload(track)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func downloadTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.startDownload(track)
//            self.delegate.play(track)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
}
