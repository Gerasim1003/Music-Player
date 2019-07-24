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

class SearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        tableView.rowHeight = 80
        
        downloadService.downloadSession = downloadSession
        
        let playerViewController = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        addChild(playerViewController)
        playerViewController.view.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: view.frame.height - 200)
        view.addSubview(playerViewController.view)
        playerViewController.didMove(toParent: self)
    }
    
    func playDownload(_ track: Track) {
        let playerViewController = AVPlayerViewController()
        present(playerViewController, animated: true, completion: nil)
        let url = localFilePath(for: track.previewURL)
        let player = AVPlayer(url: url)
        playerViewController.player = player
        player.play()
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
        
        cell.setup(image: UIImage(), name: searchResults[indexPath.row].name, artist: searchResults[indexPath.row].artist)
        cell.delegate = self
        
        return cell
    }
    
    
}

// MARK: - TrackCellDelegate
extension SearchViewController: TrackCellDelegate {
    func pauseTapped(_ cell: TrackCell) {
        
    }
    
    func resumeTapped(_ cell: TrackCell) {
        
    }
    
    func cancelTapped(_ cell: TrackCell) {
        
    }
    
    func downloadTapped(_ cell: TrackCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let track = searchResults[indexPath.row]
            downloadService.startDownload(track)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    
}
