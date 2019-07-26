import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController, SearchViewControllerDelegate {
    
    var musicPlayer = AVAudioPlayer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reverseBackground: UIView!
    @IBOutlet weak var playPauseBackground: UIView!
    @IBOutlet weak var forwardBackground: UIView!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    var isPlaying: Bool = true {
        didSet {
            if isPlaying {
                playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            } else {
                playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
        switch sender.tag {
        case 0: //reverseButton
            break
        case 1: //playPauseButton
            if isPlaying {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            } else {
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform.identity                }
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
    
    //MARK: AVPlayer
    
    func prepareMusicSession(_ track: Track) {
//        guard let player = try? AVAudioPlayer(contentsOf: track.previewURL) else {
//            return
//        }
//        player.prepareToPlay()
//
    }
    
    //MARK: SearchViewControllerDelegate
    func play(_ track: Track) {
//        prepareMusicSession(track)
//        musicPlayer.play()
    }
    
    func pause() {
        
    }

}

