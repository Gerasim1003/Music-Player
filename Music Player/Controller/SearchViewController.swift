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

enum PlayerState {
    case expanded
    case collapsed
}

protocol SearchViewControllerDelegate {
    func prepareMusicSession(_ track: Track)
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
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    var searchResults: [Track] = []
    let queryService = QueryService()
    let downloadService = DownloadService()
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    // interactive animation
    var playerViewController: PlayerViewController!
    var visualEffectView: UIVisualEffectView!
    var playerHeight: CGFloat!
    let playerHandleAreaHeight: CGFloat = 70
    var playerVisible = false
    var nextState: PlayerState  {
        return playerVisible ? .collapsed : .expanded
    }
    var runninganimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.rowHeight = 62
        
        downloadService.downloadSession = downloadSession

        setupPlayer()
    }
    

}

//MARK: TableView
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = searchResults[indexPath.row]
        if track.downloaded {
            delegate.prepareMusicSession(track)
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    //MARK: interactive animation
    func setupPlayer() {

        visualEffectView = UIVisualEffectView()
        self.visualEffectView.isUserInteractionEnabled = false
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        playerViewController = PlayerViewController(nibName: "PlayerViewController", bundle: nil)
        delegate = playerViewController
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view )
        
        playerViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - playerHandleAreaHeight, width: self.view.bounds.width, height: playerHandleAreaHeight)
        
        playerViewController.view.clipsToBounds = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(SearchViewController.handlePlayerPan(recognizer:)))
        
        playerViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        
        playerHeight = playerViewController.extandedPlayerHeight
    }
    
    @objc func handlePlayerPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startTransition(state: nextState, duration: 0.9)
        case .changed:
            let translation = recognizer.translation(in: self.playerViewController.handleArea)
            var fractionComplete = translation.y / playerHeight
            fractionComplete = playerVisible ? fractionComplete : -fractionComplete
            updateTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueTransition()
        default:
            break
        }
    }
    
    func animateTransition(state: PlayerState, duration: TimeInterval) {
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.playerViewController.extandPlayer()
                self.playerViewController.view.frame = CGRect(x: 0, y: self.view.frame.height  - self.playerHeight, width: self.view.frame.width, height: self.playerHeight)
            case .collapsed:
                self.playerViewController.collapsePlayer()
                self.playerViewController.view.frame = CGRect(x: 0, y: self.view.frame.height  - self.playerHandleAreaHeight, width: self.view.frame.width, height: self.playerHandleAreaHeight)
            }
        }
        
        frameAnimator.addCompletion { _ in
            self.playerVisible.toggle()
            self.runninganimations.removeAll()
        }
        
        frameAnimator.startAnimation()
        runninganimations.append(frameAnimator)
        
        let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
                self.visualEffectView.effect = UIBlurEffect(style: .light)
            case .collapsed:
                self.visualEffectView.effect = nil
            }
        }
        
        blurAnimator.startAnimation()
        runninganimations.append(blurAnimator)
    }
    
    func startTransition(state: PlayerState, duration: TimeInterval) {
        if runninganimations.isEmpty {
            animateTransition(state: state, duration: duration )
        }
        
        for animator in runninganimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateTransition(fractionCompleted: CGFloat) {
        for animator in runninganimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    func continueTransition() {
        for animator in runninganimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
}
