import Flutter
import UIKit
import MediaPlayer

public class SwiftFlutterVolumePlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "itech-art.com/flutter_volume_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterVolumePlugin(with: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    private final let GET_VOLUME = "getVolume"
    private final let SET_VOLUME = "setVolume"
    private final let VOLUME_UP = "volumeUp"
    private final let VOLUME_DOWN = "volumeDown"
    
    private final let START_VOLUME_LISTENER = "startVolumeListener"
    private final let STOP_VOLUME_LISTENER = "stopVolumeListener"
    
    private final let OUT_VOLUME_CHANGED = "volumeChanged"
    
    private final let PARAMETER_VALUE = "volume"
    
    private let channel: FlutterMethodChannel
    
    init(with channel: FlutterMethodChannel) {
        self.channel = channel
        AudioManager.initAudioSession()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case GET_VOLUME:
            result(AudioManager.getVolumeLevelAsPercentage())
        case SET_VOLUME:
            guard let args = call.arguments as? [String: Any] else {
                result("iOS could not recognize flutter arguments in method: " + SET_VOLUME)
                return
            }
            guard let value: Int = args[PARAMETER_VALUE] as? Int else {
                result("NullPointer, Volume must not be null")
                return
            }
            AudioManager.setVolume(to: value)
            result(nil)
            break
        case VOLUME_UP:
            AudioManager.volumeUp()
            result(nil)
            break
        case VOLUME_DOWN:
            AudioManager.volumeDown()
            result(nil)
            break
        case START_VOLUME_LISTENER:
            startObservingVolumeChanges()
            result(nil)
            break
        case STOP_VOLUME_LISTENER:
            stopObservingVolumeChanges()
            result(nil)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private struct Observation {
        static let volumeKey = "outputVolume"
        static var context = 0
    }
    
    func startObservingVolumeChanges() {
        AudioManager.initAudioSession()
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.addObserver(self, forKeyPath: Observation.volumeKey, options: [NSKeyValueObservingOptions.initial, NSKeyValueObservingOptions.new], context: &Observation.context)
    }
    
    func stopObservingVolumeChanges() {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.removeObserver(self, forKeyPath: Observation.volumeKey)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == Observation.volumeKey{
            if let volume = (change?[NSKeyValueChangeKey.newKey] as? NSNumber)?.floatValue {
                channel.invokeMethod(OUT_VOLUME_CHANGED, arguments: (Int(volume * 100)))
            }
        }
    }
}
