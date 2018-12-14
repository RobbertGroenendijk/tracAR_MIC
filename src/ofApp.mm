#include "ofApp.h"

using namespace ofxARKit::common;

void logSIMD(const simd::float4x4 &matrix)
{
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
}

//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
    cout << "creating ofApp" << endl;
}

ofApp::ofApp(){}

//--------------------------------------------------------------
ofApp :: ~ofApp () {
    cout << "destroying ofApp" << endl;
}

//--------------------------------------------------------------
void ofApp::setup() {
    
    touchDown_1 = false;
    touchDown_2 = false;
    
    mainBrightness = 180;
    
    // ====== MOTION SENSOR SETUP ====== //
    coreMotion.setupAccelerometer();
    coreMotion.setupGyroscope();
    coreMotion.setupAttitude();
    
    // ====== ENVIRONMENT SETUP ====== //
    light.setup();
    light.setAmbientColor(ofFloatColor::yellow);
    light.setPosition(0, 0, 0);
    light.enable();
    
    // ====== FONT SETUP ====== //
    int fontSize = 8;
    if (ofxiOSGetOFWindow()->isRetinaSupportedOnDevice()) {
       fontSize *= 2;
    }
    font.load("fonts/mono0755.ttf", fontSize);
    
    // ====== AR SETUP ====== //
    processor = ARProcessor::create(session);
    processor->setup();
}



//--------------------------------------------------------------
void ofApp::update(){
    processor->update();
    
    // ====== MOTION ====== //
    coreMotion.update();
    accelerometerData = coreMotion.getAccelerometerData();
    gyroscopeData = coreMotion.getGyroscopeData();
    pitchData = coreMotion.getPitch();
    rollData = coreMotion.getRoll();
    yawData = coreMotion.getYaw();
    attitudeData = ofVec3f(pitchData,rollData,yawData);
    
    // ====== TOUCH ====== //
    if (touchDown_1 == true && touchDown_2 == true) {
        if (ofGetFrameNum() % 2 == 0) {
            createAnchor();
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::draw() {
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->draw();
    // ====== BACKGROUND BRIGHTNESS ====== //
    ofSetColor(0, 0, 0, mainBrightness);
    ofDrawRectangle(0, 0, ofGetWidth(), ofGetHeight());
    ofEnableDepthTest();
    
    geoRenderer.animateGeo();
    geoRenderer.animateColor();

    if (session.currentFrame){
        if (session.currentFrame.camera){
            
            camera.begin();
            light.draw();
            
            processor->setARCameraMatrices();
            
            for (int i = 0; i < session.currentFrame.anchors.count; i++){
                ARAnchor * anchor = session.currentFrame.anchors[i];
                
                for (int j = 0; j < geoRenderer.geoVector[i].size(); j++) {
                    // ====== WORLD TRANSLATION ====== //
                    ofPushMatrix();
                    
                        ofMatrix4x4 mat = convert<matrix_float4x4, ofMatrix4x4>(anchor.transform);
                        mat.translate(geoRenderer.geoPosVector[i][j]);
                        ofMultMatrix(mat);
                    
                        // ====== LOCAL TRANSLATION ====== //
                        ofPushMatrix();
                            ofMatrix4x4 rotMat = *new ofMatrix4x4;
                            rotMat.rotate(geoRenderer.geoRotVector[i][j], 1, 1, 1);
                            ofMultMatrix(rotMat);
                    
                            geoRenderer.geoVector[i][j].draw();
                            //geoRenderer.masterMesh.draw();
                    
                        ofPopMatrix();
        
                    ofPopMatrix();
                } // End of j forLoop
            } // End of i forLoop
            camera.end();
        } // End of session.currentFrame.camera
    } // End of session.currentFrame
    
    ofDisableDepthTest();
    // ========== DEBUG STUFF ============= //
    ofSetColor(255);
    processor->debugInfo.drawDebugInformation(font);
}

//--------------------------------------------------------------
void ofApp::exit() {
    
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs &touch){
    if (touch.id == 0 ) {
        if (touch.x < 200 || touch.x > ofGetWidth()-200) {
            touchDown_1 = true;
            cout << "hold on touchDown_1" << endl;
        }
    }
    if (touch.id == 1) {
        if (touchDown_1 == true) {
            if (touch.x < 200 || touch.x > ofGetWidth()-200) {
                touchDown_2 = true;
                cout << "hold on touchDown_2" << endl;
            }
            
            if (touch.x > (ofGetWidth()/2-200) && touch.x < (ofGetWidth()/2+200)) {
                cout << "saving mesh" << endl;
                geoRenderer.saveMesh();
            }
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs &touch){
    if (touch.x > (ofGetWidth()/2-200) && touch.x < (ofGetWidth()/2+200)) {
        mainBrightness = ofMap(touch.y,0,ofGetHeight(),0,255);
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs &touch){
    if (touch.id == 0) {
        touchDown_1 = false;
        cout << "let go of touchDown_1" << endl;
    }
    
    if (touch.id == 1) {
        touchDown_2 = false;
        cout << "let go of touchDown_2" << endl;
    }
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
  
    processor->deviceOrientationChanged(newOrientation);
}


//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs& args){
    
}


//--------------------------------------------------------------
void ofApp::createAnchor() {
    // ====== AR ANCHORS ====== //
    if (session.currentFrame){
        ARFrame *currentFrame = [session currentFrame];
        
        matrix_float4x4 translation = matrix_identity_float4x4;
        translation.columns[3].z = -0.2;
        matrix_float4x4 transform = matrix_multiply(currentFrame.camera.transform, translation);
        
        // Add a new anchor to the session
        ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
        [session addAnchor:anchor];
        
        // Add a new geo to the anchor
        geoRenderer.createGeo(accelerometerData,gyroscopeData,attitudeData);
    }
}

