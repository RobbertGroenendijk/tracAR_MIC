#pragma once

#include "ofxiOS.h"
#include "ofxiOSCoreMotion.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"

#include "geoRenderer.h"

class ofApp : public ofxiOSApp {
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();
    
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs &touch);
    void touchMoved(ofTouchEventArgs &touch);
    void touchUp(ofTouchEventArgs &touch);
    void touchDoubleTap(ofTouchEventArgs &touch);
    void touchCancelled(ofTouchEventArgs &touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    void createAnchor();
    
    bool touchDown_1;
    bool touchDown_2;
    
    float mainBrightness;
    
    // ====== MOTION ====== //
    ofxiOSCoreMotion coreMotion;
    ofVec3f accelerometerData;
    ofVec3f gyroscopeData;
    ofVec3f attitudeData;
    float pitchData;
    float rollData;
    float yawData;
    
    // ====== GEO ====== //
    GeoRenderer geoRenderer;
    
    // ====== TRACKER ====== //
    vector<glm::vec4> trackPoints;
    
    // ====== ENVIRONMENT ====== //
    ofLight light;
    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARRef processor;
    vector <matrix_float4x4> mats;
    vector <ARAnchor*> anchors;
    ofCamera camera;
    ofTrueTypeFont font;
};


