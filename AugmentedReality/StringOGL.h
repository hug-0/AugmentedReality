#pragma once

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include "TrackerOutput.h"

#if TARGET_IPHONE_SIMULATOR && !defined(STRING_INTERNAL)
#error String does not support the iOS Simulator, as it lacks a camera API. Please build for Device instead.
#endif

@interface StringOGL : NSObject

// Initialization
- (StringOGL *)initWithLeftHanded: (BOOL)leftHanded;

- (NSString *)getSDKVersion;
- (void)getProjectionMatrix: (float *)matrix;
- (void)getViewport: (int *)viewport;
- (void)setNearPlane: (float)near farPlane: (float)far;

// Markers
- (int)loadMarkerImageFromMainBundle: (NSString *)filename;
- (void)unloadMarkerImages;

// Flow control
- (BOOL)process;
- (BOOL)render;
- (void)pauseCapture;
- (void)resumeCapture;
- (BOOL)isCapturePaused;

// Tracking data
- (unsigned)getMarkerInfoMatrixBased: (struct MarkerInfoMatrixBased *)markerInfo maxMarkerCount: (unsigned)maxMarkerCount;
- (unsigned)getMarkerInfoQuaternionBased: (struct MarkerInfoQuaternionBased *)markerInfo maxMarkerCount: (unsigned)maxMarkerCount;

// Video buffers
- (BOOL)isVideoTextureSupported;
- (void)getCurrentVideoTextureName: (unsigned *)textureName viewToVideoTextureTransform: (float *)viewToVideoTextureTransform;

@end
