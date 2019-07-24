//
//  TrackCell.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import UIKit

protocol TrackCellDelegate {
    func pauseTapped(_ cell: TrackCell)
    func resumeTapped(_ cell: TrackCell)
    func cancelTapped(_ cell: TrackCell)
    func downloadTapped(_ cell: TrackCell)
}

class TrackCell: UITableViewCell {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    var delegate: TrackCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func PlayTapped(_ sender: Any) {
        delegate?.downloadTapped(self)
    }
    @IBAction func pauseTapped(_ sender: Any) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(image: UIImage, name: String, artist: String) {
        self.trackImageView.image = image
        self.nameLabel.text = name
        self.artistLabel.text = artist
    }

}
