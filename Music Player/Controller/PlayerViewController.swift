import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController, SearchViewControllerDelegate {
    
    var player: AVPlayer?
    var track: Track?
    
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var reverseBackground: UIView!
    @IBOutlet weak var playPauseBackground: UIView!
    @IBOutlet weak var forwardBackground: UIView!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
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
    
    //layout player
    let collapsedPlayerHeight: CGFloat = 70
    var extandedPlayerHeight: CGFloat!
    let collapsedPlayerMargins: CGFloat = 10
    let extandedPlayerMargins: CGFloat = 10
    var imageViewWidth: CGFloat!
    let labelHeight: CGFloat = 21
    var artistNameLabelX: CGFloat!
    var artistNameLabelY: CGFloat!
    var trackNameLabelX: CGFloat!
    var trackNameLabelY: CGFloat!
    var labelWidth: CGFloat!
    
    var buttonWidth: CGFloat!
    var reverseButtonX: CGFloat!
    var playButtonX: CGFloat!
    var forwardButtonX: CGFloat!
    var buttonY: CGFloat!
    
    var sliderY: CGFloat = 0

    override func viewWillAppear(_ animated: Bool) {
        collapsePlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        calculateExtandedSizes()
    
        reverseBackground.layer.cornerRadius = (buttonWidth + 10) / 2
        reverseBackground.clipsToBounds = true
        reverseBackground.alpha = 0
        
        forwardBackground.layer.cornerRadius = (buttonWidth + 10) / 2
        forwardBackground.clipsToBounds = true
        forwardBackground.alpha = 0
        
        playPauseBackground.layer.cornerRadius = (buttonWidth + 10) / 2
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
        
        player?.replaceCurrentItem(with: nil)

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
    
    private func calculateCollapsedSizes() {
        imageViewWidth = collapsedPlayerHeight - 2 * collapsedPlayerMargins
        artistNameLabelX = imageViewWidth + 2 * collapsedPlayerMargins
        artistNameLabelY = collapsedPlayerHeight / 2 - labelHeight - 2.5
        trackNameLabelX = artistNameLabelX
        trackNameLabelY = collapsedPlayerHeight / 2 + 2.5
        
        buttonWidth = imageViewWidth - 5
        reverseButtonX = view.frame.width - buttonWidth * 3 - 15
        labelWidth = reverseButtonX - imageViewWidth - 20
        buttonY = collapsedPlayerMargins + 5
        
        playButtonX = view.frame.width - buttonWidth * 2 - 10
        forwardButtonX = view.frame.width - buttonWidth - 5
        
        hideSlider()
    }
    
    private func calculateExtandedSizes() {
        imageViewWidth = view.frame.width - extandedPlayerMargins * 2
        sliderY = imageViewWidth + 10
        artistNameLabelX = extandedPlayerMargins + 10
        artistNameLabelY = sliderY + 41
        trackNameLabelX = artistNameLabelX
        trackNameLabelY = artistNameLabelY + labelHeight + 5
        labelWidth = view.frame.width - artistNameLabelX * 2
        
        buttonWidth = 60
        playButtonX = view.frame.width / 2 - buttonWidth / 2
        reverseButtonX = playButtonX - buttonWidth - 40
        forwardButtonX = playButtonX + buttonWidth + 40
        buttonY = trackNameLabelY + labelHeight + 20
        
        extandedPlayerHeight = buttonY
                
        showSlider()

    }
    
    private func layoutPlayer() {
        imageView.frame = CGRect(x: collapsedPlayerMargins, y: collapsedPlayerMargins, width: imageViewWidth, height: imageViewWidth)
        artistNameLabel.frame = CGRect(x: artistNameLabelX, y: artistNameLabelY, width: labelWidth, height: labelHeight)
        trackNameLabel.frame = CGRect(x: trackNameLabelX, y: trackNameLabelY, width: labelWidth, height: labelHeight)
        
        reverseButton.frame = CGRect(x: reverseButtonX, y: buttonY, width: buttonWidth, height: buttonWidth)
        reverseBackground.frame = CGRect(x: reverseButtonX - 5, y: buttonY - 5, width: buttonWidth + 10, height: buttonWidth + 10)
        
        playPauseButton.frame = CGRect(x: playButtonX, y: buttonY, width: buttonWidth, height: buttonWidth)
        playPauseBackground.frame = CGRect(x: playButtonX - 5, y: buttonY - 5, width: buttonWidth + 10, height: buttonWidth + 10)
        
        forwardButton.frame = CGRect(x: forwardButtonX, y: buttonY, width: buttonWidth, height: buttonWidth)
        forwardBackground.frame = CGRect(x: forwardButtonX - 5, y: buttonY - 5, width: buttonWidth + 10, height: buttonWidth + 10)
        
        slider.frame = CGRect(x: extandedPlayerMargins, y: sliderY, width: imageViewWidth, height: 31)
        timerLabel.frame = CGRect(x: extandedPlayerMargins, y: sliderY + 15, width: 100, height: 21)
        timeLabel.frame = CGRect(x: self.view.frame.width - 100 - extandedPlayerMargins, y: sliderY + 15, width: 100, height: 21)
        
    }
    
    func collapsePlayer() {
        calculateCollapsedSizes()
        layoutPlayer()
    }
    
    func extandPlayer() {
        calculateExtandedSizes()
        layoutPlayer()
    }
    
    private func hideSlider() {
        slider.isHidden = true
        timerLabel.isHidden = true
        timeLabel.isHidden = true
    }
    
    private func showSlider() {
        slider.isHidden = false
        timerLabel.isHidden = false
        timeLabel.isHidden = false
    }
    
}

