import { vec3 } from 'gl-matrix';
import Drawable from '../rendering/gl/Drawable';
import { gl } from '../globals';

class OBJObject extends Drawable {
  indices: Uint32Array;
  positions: Float32Array;
  normals: Float32Array;

  constructor(center: vec3) {
    super();
  }

  async loadFromOBJ(filepath: string) {
    const response = await fetch(filepath);
    const objText = await response.text();
    
    const tempPositions: vec3[] = [];
    const tempNormals: vec3[] = [];
    
    const finalPositions: number[] = [];
    const finalNormals: number[] = [];
    const indices: number[] = [];
    
    const lines = objText.split('\n');
    
    for (const line of lines) {
      const parts = line.trim().split(/\s+/);
      
      if (parts[0] === 'v') {
        tempPositions.push(vec3.fromValues(
          parseFloat(parts[1]),
          parseFloat(parts[2]),
          parseFloat(parts[3])
        ));
      } else if (parts[0] === 'vn') {
        tempNormals.push(vec3.fromValues(
          parseFloat(parts[1]),
          parseFloat(parts[2]),
          parseFloat(parts[3])
        ));
      }
    }
    
    for (const line of lines) {
      const parts = line.trim().split(/\s+/);
      
      if (parts[0] === 'f') {
        const numVertices = parts.length - 1;
        
        for (let i = 1; i <= numVertices - 2; i++) {
          for (let j = 0; j < 3; j++) {
            const vertIdx = j === 0 ? 1 : i + j;
            const faceData = parts[vertIdx].split('/');
            
            const vIdx = parseInt(faceData[0]) - 1;
            const nIdx = faceData.length > 2 && faceData[2] ? 
                         parseInt(faceData[2]) - 1 : vIdx;
            
            if (vIdx >= 0 && vIdx < tempPositions.length) {
              finalPositions.push(
                tempPositions[vIdx][0],
                tempPositions[vIdx][1],
                tempPositions[vIdx][2],
                1.0
              );
            }
            
            if (nIdx >= 0 && nIdx < tempNormals.length) {
              finalNormals.push(
                tempNormals[nIdx][0],
                tempNormals[nIdx][1],
                tempNormals[nIdx][2],
                0.0
              );
            } else {
              finalNormals.push(0.0, 1.0, 0.0, 0.0);
            }
            
            indices.push(indices.length);
          }
        }
      }
    }
    
    this.indices = new Uint32Array(indices);
    this.positions = new Float32Array(finalPositions);
    this.normals = new Float32Array(finalNormals);
  }

  create() {
    this.generateIdx();
    this.generatePos();
    this.generateNor();

    this.count = this.indices.length;
    
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.bufIdx);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, this.indices, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufPos);
    gl.bufferData(gl.ARRAY_BUFFER, this.positions, gl.STATIC_DRAW);

    gl.bindBuffer(gl.ARRAY_BUFFER, this.bufNor);
    gl.bufferData(gl.ARRAY_BUFFER, this.normals, gl.STATIC_DRAW);
  }
}

export default OBJObject;