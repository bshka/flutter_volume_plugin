//
//  AudioManager.swift
//  flutter_volume_plugin
//
//  Created by Dzmitry Halauko on 11/22/19.
//

import AVFoundation
import MediaPlayer

class AudioManager {
    
    private static let VOLUME_STEP: Float = 0.0625
    
    class func isVolumeLevelAppropriate() -> Bool {
        let minimumVolumeLevelToAccept = 100
        let currentVolumeLevel = AudioManager.getVolumeLevelAsPercentage()
        let isVolumeLevelAppropriate = currentVolumeLevel >= minimumVolumeLevelToAccept
        return isVolumeLevelAppropriate
    }
    
    class func getVolumeLevelAsPercentage() -> Int {
        let audioVolumePercentage = getVolumeLevel() * 100
        return Int(audioVolumePercentage)
    }
    
    class func setVolume(to volume: Int) {
        MPVolumeView.setVolume(to: Float(volume) / 100.0)
    }
    
    class func volumeUp() {
        let vol = getVolumeLevel()
        let newVol = vol + VOLUME_STEP
        MPVolumeView.setVolume(to: newVol)
    }
    
    class func volumeDown() {
        let volume = getVolumeLevel() - VOLUME_STEP
        MPVolumeView.setVolume(to: volume)
    }
    
    class func initAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
        } catch {
            print("Failed to activate audio session")
        }
    }
    
    private class func getVolumeLevel() -> Float {
        initAudioSession()
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.outputVolume
    }
    
}

extension MPVolumeView {
    static func setVolume(to volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
            slider?.value = volume
        }
    }
}


