import UIKit
import AVFoundation

class ViewController: UIViewController {
    //MARK: - outlets
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var diffTime: UILabel!
    @IBOutlet private weak var playSongButtonLabel: UIButton!
    @IBOutlet private weak var nameSongLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var songsView: UIView!
    //MARK: - var
    var player: AVAudioPlayer?
    var chek = true
    var timer: Timer?
    var arrayNameSongs = ["AC-DC-Highway To Hell", "Nizkiz-Pravly", "Metallica-The Unforgiven"]
    var arrayNameImage = ["AC DC", "nizkiz", "metallica"]
    var indexSong = 0
    //MARK: - life cycle funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSong()
        self.timerTime()
        self.setupSwipeSettings()
    }
    //MARK: - IBActions
    @IBAction func playSongButtonPressed(_ sender: UIButton) {
        self.chek = !self.chek
        self.setPlaySongButton()
    }
    
    @IBAction func nextSongButtonPressed(_ sender: UIButton) {
        self.nextIndexSong()
        self.playSound()
        self.nameSong()
        self.animateImageSongNext()
        self.setPlaySongButton()
    }
    
    @IBAction func backSongButtonPressed(_ sender: UIButton) {
        self.backIndexSong()
        self.playSound()
        self.nameSong()
        self.animateImageSongBack()
        self.setPlaySongButton()
    }
    
    @IBAction func leftSwipeDetected (_ sender: UISwipeGestureRecognizer) {
        self.moveImageNext()
        self.playSound()
        self.nameSong()
        self.setPlaySongButton()
    }
    
    @IBAction func rightSwipeDetected (_ sender: UISwipeGestureRecognizer) {
        self.moveImageBack()
        self.playSound()
        self.nameSong()
        self.setPlaySongButton()
    }
    //MARK: - flow funcs
    private func setupSong() {
        self.playSound()
        self.nameSong()
        self.imageSong()
        self.setPlaySongButton()
        self.imageView.radius()
        self.slider.maximumValue = Float(player?.duration ?? Double())
    }
    
    private func playSound () {
        guard let url = Bundle.main.url(forResource: self.arrayNameSongs[indexSong], withExtension: "mp3") else {return}
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func setPlaySongButton() {
        if self.chek == true {
            self.playSongButtonLabel.setImage(UIImage(named: "play"), for: .normal)
            self.player?.pause()
        } else {
            self.playSongButtonLabel.setImage(UIImage(named: "stop"), for: .normal)
            self.player?.play()
            self.timerTime()
        }
    }
    
    private func timerTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if let timePlayed = player?.currentTime {
            let minutes = Int(timePlayed / 60)
            let seconds = Int(timePlayed.truncatingRemainder(dividingBy: 60))
            self.timeLabel.text = NSString(format: "%02d:%02d", minutes, seconds) as String
        }
        if let currentTime = player?.currentTime, let duration = player?.duration {
            let diffTime = currentTime - duration
            let diffMinutes = Int(diffTime / 60)
            let diffSeconds = Int(-diffTime.truncatingRemainder(dividingBy: 60))
            self.diffTime.text = NSString(format: "%02d:%02d", diffMinutes, diffSeconds) as String
            self.slider.setValue(Float(currentTime), animated: true)
        }
    }
    
    private func nextIndexSong() {
        if self.indexSong == self.arrayNameSongs.count - 1 {
            self.indexSong = 0
        } else {
            self.indexSong += 1
        }
    }
    
    private func backIndexSong() {
        if self.indexSong == 0 {
            self.indexSong = self.arrayNameSongs.count - 1
        } else {
            self.indexSong -= 1
        }
    }
    
    private func nameSong() {
        self.nameSongLabel.text = self.arrayNameSongs[indexSong]
    }
    
    private func imageSong() {
        let image = UIImage(named: arrayNameImage[indexSong])
        self.imageView.image = image
    }
    
    private func createImageView (x: CGFloat) -> UIImageView {
        let newImageView = UIImageView()
        newImageView.frame = CGRect(x: x,
                                    y: self.imageView.frame.origin.y,
                                    width: self.imageView.frame.size.width ,
                                    height: self.imageView.frame.size.height)
        newImageView.contentMode = .scaleAspectFill
        newImageView.clipsToBounds = true
        newImageView.radius()
        let image = UIImage(named: arrayNameImage[indexSong])
        newImageView.image = image
        self.songsView.addSubview(newImageView)
        return newImageView
    }
    
    private func animateImage(_ newImageView: UIImageView, finish: CGFloat) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear) {
            newImageView.frame.origin.x -= finish
        } completion: { (_) in
            self.imageView.image = newImageView.image
            newImageView.removeFromSuperview()
        }
    }
    
    private func animateImageSongNext() {
        let newImageView = self.createImageView(x: self.songsView.frame.size.width)
        self.animateImage(newImageView, finish: self.imageView.frame.size.width)
    }
    
    private func animateImageSongBack() {
        let newImageView = self.createImageView(x: -self.imageView.frame.size.width)
        self.animateImage(newImageView, finish: -self.imageView.frame.size.width)
    }
    
    private func moveImageNext() {
        self.nextIndexSong()
        self.animateImageSongNext()
    }
    
    private func moveImageBack() {
        self.nextIndexSong()
        self.animateImageSongBack()
    }
    
    private func setupSwipeSettings() {
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipeDetected(_:)))
        leftSwipe.direction = .left
        self.songsView.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipeDetected(_:)))
        rightSwipe.direction = .right
        self.songsView.addGestureRecognizer(rightSwipe)
    }
}
//MARK: - extension
extension UIImageView {
    func radius (_ radius: Int = 10) {
        self.layer.cornerRadius = CGFloat(radius)
    }
}
