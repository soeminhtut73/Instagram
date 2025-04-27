//
//  UploadPostController.swift
//  Instagram
//
//  Created by S M H  on 11/01/2025.
//

import UIKit
import AVKit
import YPImagePicker
import AVFoundation

protocol UploadPostControllerDelegate: AnyObject {
    func didUploadPost(_ controller: UploadPostController)
}

class UploadPostController : UIViewController {
    
    //MARK: - Properties
    
    var selectedImage: UIImage? {
        didSet {
            guard let selectedImage = selectedImage else { return }
            postImage.isHidden = false
            postImage.image = selectedImage
        }
    }
    
    var selectedVideo: YPMediaVideo? {
        didSet {
            guard let video = selectedVideo else { return }
            videoView.isHidden = false
            playVideoInline(from: video.url)
        }
    }
    
    var user : User?
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    weak var delegate: UploadPostControllerDelegate?
    
    private let postImage: UIImageView = {
        let postImage           = UIImageView()
        postImage.contentMode   = .scaleAspectFill
        postImage.clipsToBounds = true
        postImage.isHidden      = true
        return postImage
    }()
    
    private let videoView: UIView = {
        let view               = UIView()
        view.backgroundColor   = .systemGray6
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    
    private lazy var replayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.trianglehead.clockwise"), for: .normal)
        button.tintColor        = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        button.layer.cornerRadius = 8
        button.isHidden = true
        button.addTarget(self, action: #selector(replayVideo), for: .touchUpInside)
        return button
    }()
    
    private let captionText: UITextView = {
        let captionText = CustomTextView()
        captionText.placeholderText             = "Share your thoughts..."
        captionText.font                        = .systemFont(ofSize: 15)
        captionText.textColor                   = .label
        captionText.placeholderShouldCenterY    = false
        return captionText
    }()
    
    private let characterCount: UILabel = {
        let label               = UILabel()
        label.font              = .systemFont(ofSize: 16)
        label.textColor         = .secondaryLabel
        label.textAlignment     = .center
        label.text              = "0/100"
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }
    
    
    //MARK: - Selector
    
    @objc func didTapCancleButton() {
        dismiss(animated: true)
    }
    
    @objc func didTapSaveButton() {

        guard let user = user else { return }
        
        showLoader(true)
        
        if let image = postImage.image {
            
            PostServices.uploadPost(user: user, image: image, caption: captionText.text) { error in
                
                self.showLoader(false)
                
                if let error = error {
                    print("Debug: Error uploading post : \(error.localizedDescription)")
                    return
                }
                self.delegate?.didUploadPost(self)
            }
        } else if let selectedVideo = selectedVideo {
            
            generateThumbnail(from: selectedVideo.url) { thumbnail in
                
                guard let thumbnail = thumbnail else { return }
                
                DispatchQueue.main.async {
                    PostServices.uploadPostWithVideo(user: user, thumbnailImage: thumbnail, video: selectedVideo, caption: self.captionText.text) { _ in
                        self.showLoader(false)
                        
                        self.delegate?.didUploadPost(self)
                    }
                }
            }
            
        }
    }
    
    //MARK: - Helper Functions
    
    func configureUI() {
        
        navigationItem.title = "Upload Post"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapSaveButton))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancleButton))
        
        view.addSubview(postImage)
        postImage.anchor(top: view.safeAreaLayoutGuide.topAnchor,
                         paddingTop: 12)
        postImage.setDimensions(height: 340, width: 180)
        postImage.centerX(inView: view)
        postImage.layer.cornerRadius = 10
        postImage.clipsToBounds = true
        
        view.addSubview(videoView)
        videoView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 12)
        videoView.centerX(inView: view)
        videoView.setDimensions(height: 340, width: view.frame.width)
        videoView.clipsToBounds = true
        
        view.addSubview(replayButton)
        replayButton.centerX(inView: videoView)
        replayButton.centerY(inView: videoView)
        replayButton.setDimensions(height: 50, width: 50)
        
        view.addSubview(captionText)
        captionText.delegate = self
        captionText.anchor(top: postImage.bottomAnchor,
                        left: view.leftAnchor,
                        right: view.rightAnchor,
                        paddingTop: 16,
                        paddingLeft: 12,
                        paddingRight: 12,
                        height: 64)
        
        view.addSubview(characterCount)
        characterCount.anchor(top: captionText.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingRight: 12)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: AVPlayerItem.didPlayToEndTimeNotification,
                                               object: player?.currentItem)
    }
    
    func checkCharacterMaxLength(_ captionText: UITextView) {
        if captionText.text.count > 100 {
            captionText.deleteBackward()
        }
    }
    
    func playVideoInline(from url: URL) {
        playerLayer?.removeFromSuperlayer()
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        
        playerLayer?.frame = videoView.bounds
        playerLayer?.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer!)
        
        player?.play()
    }
    
    func generateThumbnail(from videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVURLAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true // Avoids rotated frames
        
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        
        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, actualTime, error in
            if let error = error {
                print("Debug: Error generating thumbnail : \(error)")
            }
            
            guard let cgImage = cgImage else { return }
            
            let image = UIImage(cgImage: cgImage)
            
            completion(image)
        }
    }
    
    //MARK: - Selector
    
    @objc func playerDidFinishPlaying() {
        replayButton.isHidden = false
    }
    
    @objc func replayVideo() {
        replayButton.isHidden = true
        player?.seek(to: .zero)
        player?.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // This will dismiss the keyboard
        super.touchesBegan(touches, with: event)
    }
}

extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ captionText: UITextView) {
        characterCount.text = "\(captionText.text.count)/100"
        checkCharacterMaxLength(captionText)
    }
}
