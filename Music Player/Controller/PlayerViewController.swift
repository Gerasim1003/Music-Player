import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController, SearchViewControllerDelegate {
    
    var player: AVPlayer?
    var track: Track?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reverseBackground: UIView!
    @IBOutlet weak var playPauseBackground: UIView!
    @IBOutlet weak var forwardBackground: UIView!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                play()
            } else {
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                pause()
            }
        }
    }
    
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        reverseBackground.layer.cornerRadius = 35
        reverseBackground.clipsToBounds = true
        reverseBackground.alpha = 0
        
        forwardBackground.layer.cornerRadius = 35
        forwardBackground.clipsToBounds = true
        forwardBackground.alpha = 0
        
        playPauseBackground.layer.cornerRadius = 35
        playPauseBackground.clipsToBounds = true
        playPauseBackground.alpha = 0
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
    }
    
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        guard track != nil else { return }
        
        switch sender.tag {
        case 0: //reverseButton
            break
        case 1: //playPauseButton
            if isPlaying {
                animateionScale()
            } else {
                animationIdentity()
            }
            
            isPlaying.toggle()
        case 2: //forwardButton
            break
        default:
            break
        }
    }
    
    @IBAction func touchedDown(_ sender: UIButton) {
        var buttonBackground: UIView = UIView()
        
        switch sender {
        case reverseButton:
            buttonBackground = reverseBackground
        case playPauseButton:
            buttonBackground = playPauseBackground
        case forwardButton:
            buttonBackground = forwardBackground
        default:
            break
        }
        
        UIView.animate(withDuration: 0.25) {
            buttonBackground.alpha = 0.3
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    @IBAction func touchedUpInside(_ sender: UIButton) {
        var buttonBackground: UIView = UIView()
        
        switch sender {
        case reverseButton:
            buttonBackground = reverseBackground
        case playPauseButton:
            buttonBackground = playPauseBackground
        case forwardButton:
            buttonBackground = forwardBackground
        default:
            break
        }
        
        UIView.animate(withDuration: 0.25) {
            buttonBackground.alpha = 0
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        UIView.animate(withDuration: 0.25, animations: {
            buttonBackground.alpha = 0
            buttonBackground.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.transform = CGAffineTransform.identity
        }) { (_) in
            buttonBackground.transform = CGAffineTransform.identity
        }
    }
    
    func animateionScale() {
        UIView.animate(withDuration: 0.5) {
            self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    func animationIdentity() {
        UIView.animate(withDuration: 0.5) {
            self.imageView.transform = CGAffineTransform.identity
        }
    }
    
    //MARK: AVPlayer
    func localFilePath(for url: URL) -> URL {
        return documentsPath.appendingPathComponent(url.lastPathComponent)
    }
    
    func prepareMusicSession(_ track: Track) {
        self.track = track

        let url = localFilePath(for: track.previewURL)
        
        let playerItem: AVPlayerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        
        self.view.layer.addSublayer(playerLayer)
        
        play()
        isPlaying = true
        animationIdentity()
        setup()
    }
    
    func setup() {
        guard let track = track else { return }
        
        UIView.animate(withDuration: 0.25) {
            self.trackNameLabel.text = track.name
            self.artistNameLabel.text = track.artist
            self.imageView.image = track.image
        }
    }
    
    //MARK: SearchViewControllerDelegate
    func play() {
        if let player = player {
            player.play()
        }
    }
    
    func pause() {
        if let player = player {
            player.pause()
        }
    }

}

