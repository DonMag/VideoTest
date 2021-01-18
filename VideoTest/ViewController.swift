//
//  ViewController.swift
//  VideoTest
//
//  Created by Don Mag on 1/18/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemYellow
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard let originalVideoURL1 = Bundle.main.url(forResource: "video1", withExtension: "mov"),
			  let originalVideoURL2 = Bundle.main.url(forResource: "video2", withExtension: "mov")
		else { return }
		
		let firstAsset = AVURLAsset(url: originalVideoURL1)
		let secondAsset = AVURLAsset(url: originalVideoURL2)
		
		let mixComposition = AVMutableComposition()
		
		guard let firstTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
		let timeRange1 = CMTimeRangeMake(start: .zero, duration: firstAsset.duration)
		
		do {
			try firstTrack.insertTimeRange(timeRange1, of: firstAsset.tracks(withMediaType: .video)[0], at: .zero)
		} catch {
			return
		}
		
		guard let secondTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid)) else { return }
		let timeRange2 = CMTimeRangeMake(start: .zero, duration: secondAsset.duration)
		
		do {
			try secondTrack.insertTimeRange(timeRange2, of: secondAsset.tracks(withMediaType: .video)[0], at: .zero)
		} catch {
			return
		}
		
		let mainInstruction = AVMutableVideoCompositionInstruction()
		
		mainInstruction.timeRange = CMTimeRangeMake(start: .zero, duration: CMTimeMaximum(firstAsset.duration, secondAsset.duration))
		
		var track: AVAssetTrack!
		
		track = firstAsset.tracks(withMediaType: .video).first
		
		let firstSize = track.naturalSize.applying(track.preferredTransform)
		
		track = secondAsset.tracks(withMediaType: .video).first
		
		let secondSize = track.naturalSize.applying(track.preferredTransform)
		
		// debugging
		print("firstSize:", firstSize)
		print("secondSize:", secondSize)
		
		let renderSize = CGSize(width: 640, height: 480)
		
		var scale: CGAffineTransform!
		var move: CGAffineTransform!
		
		let firstLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: firstTrack)
		
		scale = .identity
		move = .identity
		
		if (firstSize.width < 0) {
			scale = CGAffineTransform(rotationAngle: .pi)
		}
		scale = scale.scaledBy(x: abs(renderSize.width / 2.0 / firstSize.width), y: abs(renderSize.height / firstSize.height))
		move = CGAffineTransform(translationX: 0, y: 0)
		if (firstSize.width < 0) {
			move = CGAffineTransform(translationX: renderSize.width / 2.0, y: renderSize.height)
		}
		
		firstLayerInstruction.setTransform(scale.concatenating(move), at: .zero)
		
		let secondLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: secondTrack)
		
		scale = .identity
		move = .identity
		
		if (secondSize.width < 0) {
			scale = CGAffineTransform(rotationAngle: .pi)
		}
		scale = scale.scaledBy(x: abs(renderSize.width / 2.0 / secondSize.width), y: abs(renderSize.height / secondSize.height))
		move = CGAffineTransform(translationX: renderSize.width / 2.0, y: 0)
		if (secondSize.width < 0) {
			move = CGAffineTransform(translationX: renderSize.width, y: renderSize.height)
		}
		
		secondLayerInstruction.setTransform(scale.concatenating(move), at: .zero)
		
		mainInstruction.layerInstructions = [firstLayerInstruction, secondLayerInstruction]
		
		let mainCompositionInst = AVMutableVideoComposition()
		mainCompositionInst.instructions = [mainInstruction]
		mainCompositionInst.frameDuration = CMTime(value: 1, timescale: 30)
		mainCompositionInst.renderSize = renderSize
		
		let newPlayerItem = AVPlayerItem(asset: mixComposition)
		newPlayerItem.videoComposition = mainCompositionInst
		
		let player = AVPlayer(playerItem: newPlayerItem)
		let playerLayer = AVPlayerLayer(player: player)
		
		playerLayer.frame = view.bounds
		view.layer.addSublayer(playerLayer)
		player.seek(to: .zero)
		player.play()
		
		// video export code goes here...
		
	}

}

