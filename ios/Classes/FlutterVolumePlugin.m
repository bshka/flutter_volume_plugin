#import "FlutterVolumePlugin.h"
#import <flutter_volume_plugin/flutter_volume_plugin-Swift.h>

@implementation FlutterVolumePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVolumePlugin registerWithRegistrar:registrar];
}
@end
