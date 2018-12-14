#pragma once

#include "ofxiOS.h"
#include "../ofxBranchesPrimitive/src/ofxBranchesPrimitive.h"

class GeoRenderer {
public:
    void setup();
    void createGeo(ofVec3f _accelerometerData,
                   ofVec3f _gyroscopeData,
                   ofVec3f _attitudeData);
    float getSize(ofVec3f _accelerometerData);
    ofVec3f getGyro(ofVec3f _gyroscopeData);
    void animateGeo();
    void animateColor();
    void saveMesh();
    
    // ====== MESH ====== //
    vector<vector<ofMesh>> geoVector;
    vector<vector<ofVec3f>> geoPosVector;
    vector<vector<ofVec3f>> geoAxisVector;
    vector<vector<float>> geoRotVector;
    vector<vector<float>> geoRotSpeedVector;
    vector<vector<glm::vec3>> geoVertex;
    vector<vector<vector<ofFloatColor>>> colorVector;
    vector<vector<vector<ofFloatColor>>> colorChangeVector;
    
    ofMesh masterMesh;
    
    int meshRes;
    int baseSize;
    
    float noiseNum;
    float vertexNoiseNum;
    
    GeoRenderer();
};
