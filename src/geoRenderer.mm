#include "geoRenderer.h"

GeoRenderer::GeoRenderer() {
    cout << "GeoRenderer instanced" << endl;
    noiseNum = 0;
    vertexNoiseNum = 0;
}
void GeoRenderer::setup() {

}
void GeoRenderer::createGeo(ofVec3f _accelerometerData, ofVec3f _gyroscopeData, ofVec3f _attitudeData) {
    float baseSize = 0.03;
    ofVec3f attitudeData = ofVec3f(ofMap(_attitudeData.z,-PI,PI,0,1),
                                   ofMap(_attitudeData.y,-PI,PI,0,1),
                                   ofMap(_attitudeData.x,-PI,PI,0,1));
    cout << attitudeData << endl;
    ofVec3f gyroscopeData = getGyro(_gyroscopeData);
    float geoSize = getSize(_accelerometerData);
    
    geoVector.push_back(vector<ofMesh>());
    geoPosVector.push_back(vector<ofVec3f>());
    geoAxisVector.push_back(vector<ofVec3f>());
    geoRotVector.push_back(vector<float>());
    geoRotSpeedVector.push_back(vector<float>());
    
    ofMesh tempMesh = *new ofMesh;
    if (gyroscopeData.x > gyroscopeData.y && gyroscopeData.x > gyroscopeData.z) {
        tempMesh = ofMesh::box(baseSize*geoSize, baseSize*geoSize, baseSize*geoSize,2,2,2);
    } else if (gyroscopeData.y > gyroscopeData.x && gyroscopeData.y > gyroscopeData.z) {
        tempMesh = ofMesh::icosahedron(baseSize*geoSize);
    } else if (gyroscopeData.z > gyroscopeData.x && gyroscopeData.z > gyroscopeData.y) {
        tempMesh = ofMesh::icosphere(baseSize*geoSize);
    }
    
    for (int i = 0; i < tempMesh.getNumVertices(); i++) {
        ofFloatColor tempColor = ofFloatColor(attitudeData.y+ofRandom(0.0,0.2),
                                              attitudeData.x+ofRandom(0.0,0.2),
                                              attitudeData.z+ofRandom(0.0,0.2));
        tempMesh.addColor(tempColor);
    }
    
    geoVector[geoVector.size()-1].push_back(tempMesh);
    geoPosVector[geoPosVector.size()-1].push_back(ofVec3f(0,0,0));
    geoAxisVector[geoAxisVector.size()-1].push_back(ofVec3f(ofRandom(0.1,1),
                                                            ofRandom(0.1,1),
                                                            ofRandom(0.1,1)));
    geoRotVector[geoRotVector.size()-1].push_back(ofRandom(0,360));
    geoRotSpeedVector[geoRotSpeedVector.size()-1].push_back(_accelerometerData.x);
    
    // PUSH TO MASTER
    masterMesh.append(tempMesh);
    
    int extraMeshCount = 1 + floor(geoSize);
    for (int i = 0; i < extraMeshCount; i++) {
        
        ofMesh extraMesh = *new ofMesh;
        if (gyroscopeData.x > gyroscopeData.y && gyroscopeData.x > gyroscopeData.z) {
            extraMesh = ofMesh::box(baseSize*geoSize, baseSize*geoSize, baseSize*geoSize,2,2,2);
        } else if (gyroscopeData.y > gyroscopeData.x && gyroscopeData.y > gyroscopeData.z) {
            extraMesh = ofMesh::icosahedron(baseSize*geoSize);
        } else if (gyroscopeData.z > gyroscopeData.x && gyroscopeData.z > gyroscopeData.y) {
            extraMesh = ofMesh::icosphere(baseSize*geoSize);
        }
        
        for (int j = 0; j < extraMesh.getNumVertices(); j++) {
            ofFloatColor tempColor = ofFloatColor(attitudeData.y+ofRandom(0.0,0.2),
                                                  attitudeData.x+ofRandom(0.0,0.2),
                                                  attitudeData.z+ofRandom(0.0,0.2));
            extraMesh.addColor(tempColor);
        }
        geoVector[geoVector.size()-1].push_back(extraMesh);
        geoPosVector[geoPosVector.size()-1].push_back(ofVec3f(ofRandom(-baseSize,baseSize),
                                                              ofRandom(-baseSize,baseSize),
                                                              ofRandom(-baseSize,baseSize)));
        geoAxisVector[geoAxisVector.size()-1].push_back(ofVec3f(ofRandom(0.1,1),
                                                                ofRandom(0.1,1),
                                                                ofRandom(0.1,1)));
        geoRotVector[geoRotVector.size()-1].push_back(ofRandom(0,360));
        geoRotSpeedVector[geoRotSpeedVector.size()-1].push_back(_accelerometerData.x);
        
        // PUSH TO MASTER
        masterMesh.append(extraMesh);
    }
    
    for (int i = 0; i < geoVector.size(); i++) {
        colorVector.push_back(vector<vector<ofFloatColor>>());
        colorChangeVector.push_back(vector<vector<ofFloatColor>>());
        for (int j = 0; j < geoVector[i].size(); j++) {
            colorVector[i].push_back(vector<ofFloatColor>());
            colorChangeVector[i].push_back(vector<ofFloatColor>());
            for (int k = 0; k < geoVector[i][j].getNumVertices(); k++) {
                colorVector[i][j].push_back(geoVector[i][j].getColor(k));
                colorChangeVector[i][j].push_back(geoVector[i][j].getColor(k));
            }
        }
    }
}
void GeoRenderer::animateGeo() {
    for (int i = 0; i < geoRotVector.size(); i++) {
        for (int j = 0; j < geoRotVector[i].size(); j++) {
            geoRotVector[i][j] += geoRotSpeedVector[i][j] * 10;
        }
    }
}
void GeoRenderer::animateColor() {
    colorChangeVector = colorVector;
    noiseNum += 1;
    vertexNoiseNum = 0;
    
    for (int i = 0; i < geoVector.size(); i++) {
        for (int j = 0; j < geoVector[i].size(); j++) {
            for (int k = 0; k < geoVector[i][j].getNumVertices(); k++) {
                float noiseVal = ofNoise( (noiseNum + vertexNoiseNum + (i*j*k) ) * 0.01);
                colorChangeVector[i][j][k] = ofFloatColor(colorVector[i][j][k][0] * noiseVal,
                                                          colorVector[i][j][k][1] * noiseVal,
                                                          colorVector[i][j][k][2] * noiseVal);
                geoVector[i][j].setColor(k, colorChangeVector[i][j][k]);
                vertexNoiseNum += 0.01;
                
            }
        }
    }
    
}
float GeoRenderer::getSize(ofVec3f _accelerometerData) {
    float size = _accelerometerData.x;
    
    if (_accelerometerData.y > size) {
        size = _accelerometerData.y;
    }
    if (_accelerometerData.z > size) {
        size = _accelerometerData.z;
    }
    
    // Flip to positive
    if (size < 0) {
        size *= -1;
    }
    
    // Minimum size
    if (size < 1) {
        size = 1;
    }
    
    return size;
}
ofVec3f GeoRenderer::getGyro(ofVec3f _gyroscopeData) {
    // Function gives out values to be used as ofFloatColor
    ofVec3f gyroscopeData = ofVec3f(ofClamp(ofMap(_gyroscopeData.x,-1,1,0,1), 0, 1),
                                    ofClamp(ofMap(_gyroscopeData.y,-1,1,0,1), 0, 1),
                                    ofClamp(ofMap(_gyroscopeData.z,-1,1,0,1), 0, 1));
    
    return gyroscopeData;
}
void GeoRenderer::saveMesh() {
    for (int i = 0; i < geoVector.size();i++) {
        for (int j = 0; j < geoVector[i].size(); j++) {
            geoVector[i][j].save("/output",false);
        }
    }
}
