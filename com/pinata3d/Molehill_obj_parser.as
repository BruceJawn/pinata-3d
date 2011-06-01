// OBJ file format parser for Molehill - version 2.2
//
// A one-file, zero dependencies solution!
// Just drop into your project and enjoy.
//
// This class only does ONE thing:
// it turns an OBJ file into Molehill buffers.
//
// example:
//
// [Embed (source = "mesh.obj", mimeType = "application/octet-stream")] 
// private var my_obj_data:Class;
//
// ... set up your transforms, texture, vertex and fragment programs as normal ...
//
// var my_mesh:Molehill_obj_parser = new Molehill_obj_parser(my_obj_data);
// context3D.setVertexBufferAt(0, my_mesh.positionsBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
// context3D.setVertexBufferAt(1, my_mesh.uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
// context3D.drawTriangles(my_mesh.indexBuffer, 0, my_mesh.indexBufferCount);
//
// [Some older exporters (eg 3dsmax9) format things differently: zxy instead of xyz:]
// [var my_mesh:Molehill_obj_parser = new Molehill_obj_parser(my_obj_data, 1, true);]
// [Also, some exporters flip the U texture coordinate:]
// [var my_mesh:Molehill_obj_parser = new Molehill_obj_parser(my_obj_data, 1, true, true);]
//
// Note: no quads allowed!
// If your model isn't working, check that you 
// have triangulated your mesh so each polygon uses
// exactly three vertexes - no more and no less.
//
// No groups or sub-models - one mesh per file.
// No .mat material files are used - geometry only.

package com.pinata3d
{

import flash.geom.Vector3D;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.display3D.Context3D;
import flash.display3D.IndexBuffer3D;
import flash.display3D.VertexBuffer3D;

public class Molehill_obj_parser
{
// older versions of 3dsmax use an invalid vertex order: 
private var _vertex_data_is_zxy:Boolean = false;
// some exporters mirror the UV texture coordinates
private var _mirror_uv:Boolean = false;
// OBJ files do not contain vertex colors
// but many shaders will require this data
// if false, the buffer is filled with pure white
private var _random_vertex_colors:Boolean = true;
// constants used in parsing OBJ data
private const LINE_FEED:String = String.fromCharCode(10);
private const SPACE:String = String.fromCharCode(32);
private const SLASH:String = "/";
private const VERTEX:String = "v";
private const NORMAL:String = "vn";
private const UV:String = "vt";
private const INDEX_DATA:String = "f";
// temporary vars used during parsing OBJ data
private var _scale:Number;
private var _faceIndex:uint;
private var _vertices:Vector.<Number>;
private var _normals:Vector.<Number>;
private var _uvs:Vector.<Number>;
private var _cachedRawNormalsBuffer:Vector.<Number>;
// the raw data that is used to create Molehill buffers
protected var _rawIndexBuffer:Vector.<uint>;
protected var _rawPositionsBuffer:Vector.<Number>;
protected var _rawUvBuffer:Vector.<Number>;
protected var _rawNormalsBuffer:Vector.<Number>;
protected var _rawColorsBuffer:Vector.<Number>;
// the final buffers in Molehill-ready format
protected var _indexBuffer:IndexBuffer3D;
protected var _positionsBuffer:VertexBuffer3D;
protected var _uvBuffer:VertexBuffer3D;
protected var _normalsBuffer:VertexBuffer3D;
protected var _colorsBuffer:VertexBuffer3D;
// the context3D that we want to upload the buffers to
private var _context3d:Context3D;
	
// the class constructor - where everything begins
public function Molehill_obj_parser(objfile:Class, 
	acontext:Context3D, scale:Number = 1, 
	data_is_zxy:Boolean = false, texture_flip:Boolean = false)
{
	_vertex_data_is_zxy = data_is_zxy;
	_mirror_uv = texture_flip;

	_rawColorsBuffer = new Vector.<Number>();
	_rawIndexBuffer = new Vector.<uint>();
	_rawPositionsBuffer = new Vector.<Number>();
	_rawUvBuffer = new Vector.<Number>();
	_rawNormalsBuffer = new Vector.<Number>();
	_scale = scale;
	_context3d = acontext;

	// Get data as string.
	var definition:String = readClass(objfile);

	// Init raw data containers.
	_vertices = new Vector.<Number>();
	_normals = new Vector.<Number>();
	_uvs = new Vector.<Number>();

	// Split data in to lines and parse all lines.
	var lines:Array = definition.split(LINE_FEED);
	var loop:uint = lines.length;
	for(var i:uint = 0; i < loop; ++i)
		parseLine(lines[i]);
}

private function readClass(f:Class):String
{
	var bytes:ByteArray = new f();
	return bytes.readUTFBytes(bytes.bytesAvailable);
}

private function parseLine(line:String):void
{
	// Split line into words.
	var words:Array = line.split(SPACE);

	// Prepare the data of the line.
	if (words.length > 0)
		var data:Array = words.slice(1);
	else
		return;

	// Check first word and delegate remainder to proper parser.
	var firstWord:String = words[0];
	if (firstWord == VERTEX)
		parseVertex(data);
	else if (firstWord == NORMAL)
		parseNormal(data);
	else if (firstWord == UV)
		parseUV(data);
	else if (firstWord == INDEX_DATA)
		parseIndex(data);
}

private function parseVertex(data:Array):void
{
	if ((data[0] == '') || (data[0] == ' ')) 
		data = data.slice(1); // delete blanks
	if (_vertex_data_is_zxy)
	{
		//if (!_vertices.length) trace('zxy parseVertex: ' + data[1] + ',' + data[2] + ',' + data[0]);
		_vertices.push(Number(data[1])*_scale);
		_vertices.push(Number(data[2])*_scale);
		_vertices.push(Number(data[0])*_scale);
	}
	else // normal operation: x,y,z
	{
		//if (!_vertices.length) trace('parseVertex: ' + data);
		var loop:uint = data.length;
		if (loop > 3) loop = 3;
		for (var i:uint = 0; i < loop; ++i)
		{
			var element:String = data[i];
			_vertices.push(Number(element)*_scale);
		}
	}
}

private function parseNormal(data:Array):void
{
	if ((data[0] == '') || (data[0] == ' ')) 
		data = data.slice(1); // delete blanks
	//if (!_normals.length) trace('parseNormal:' + data);
	var loop:uint = data.length;
	if (loop > 3) loop = 3;
	for (var i:uint = 0; i < loop; ++i)
	{
		var element:String = data[i];
		if (element != null) // handle 3dsmax extra spaces
			_normals.push(Number(element));
	}
}

private function parseUV(data:Array):void
{
	if ((data[0] == '') || (data[0] == ' ')) 
		data = data.slice(1); // delete blanks
	//if (!_uvs.length) trace('parseUV:' + data);
	var loop:uint = data.length;
	if (loop > 2) loop = 2;
	for (var i:uint = 0; i < loop; ++i)
	{
		var element:String = data[i];
		_uvs.push(Number(element));
	}
}

private function parseIndex(data:Array):void
{
	//if (!_rawIndexBuffer.length) trace('parseIndex:' + data);
	var triplet:String;
	var subdata:Array;
	var vertexIndex:int;
	var uvIndex:int;
	var normalIndex:int;
	var index:uint;

	// Process elements.
	var i:uint;
	var loop:uint = data.length;
	var starthere:uint = 0;
	while ((data[starthere] == '') || (data[starthere] == ' ')) starthere++; // ignore blanks

	loop = starthere + 3;

	// loop through each element and grab values stored earlier
	// elements come as vertexIndex/uvIndex/normalIndex
	for(i = starthere; i < loop; ++i)
	{
		triplet = data[i]; 
		subdata = triplet.split(SLASH);
		vertexIndex = int(subdata[0]) - 1;
		uvIndex     = int(subdata[1]) - 1;
		normalIndex = int(subdata[2]) - 1;

		// sanity check
		if(vertexIndex < 0) vertexIndex = 0;
		if(uvIndex < 0) uvIndex = 0;
		if(normalIndex < 0) normalIndex = 0;

		// Extract from parse raw data to mesh raw data.

		// Vertex (x,y,z)
		index = 3*vertexIndex;
		_rawPositionsBuffer.push(_vertices[index + 0], 
			_vertices[index + 1], _vertices[index + 2]);

		// Color (vertex r,g,b,a)
		if (_random_vertex_colors)
			_rawColorsBuffer.push(Math.random(), 
				Math.random(), Math.random(), 1);
		else
			_rawColorsBuffer.push(1, 1, 1, 1); // pure white

		// Normals (nx,ny,nz) - *if* included in the file
		if (_normals.length)
		{
			index = 3*normalIndex;
			_rawNormalsBuffer.push(_normals[index + 0], 
				_normals[index + 1], _normals[index + 2]);
		}

		// Texture coordinates (u,v)
		index = 2*uvIndex;
		if (_mirror_uv)
			_rawUvBuffer.push(_uvs[index+0], 1-_uvs[index+1]);
		else
			_rawUvBuffer.push(1-_uvs[index+0],1-_uvs[index+1]);
	}

	// Create index buffer - one entry for each polygon
	_rawIndexBuffer.push(_faceIndex+0,_faceIndex+1,_faceIndex+2);
	_faceIndex += 3;
}

// These functions return Molehill buffers
// (uploading them first if required)

public function get colorsBuffer():VertexBuffer3D
{
	if(!_colorsBuffer)
		updateColorsBuffer();
	return _colorsBuffer;
}

public function get positionsBuffer():VertexBuffer3D
{
	if(!_positionsBuffer)
		updateVertexBuffer();
	return _positionsBuffer;
}

public function get indexBuffer():IndexBuffer3D
{
	if(!_indexBuffer)
		updateIndexBuffer();
	return _indexBuffer;
}

public function get indexBufferCount():int
{
	return _rawIndexBuffer.length / 3;
}

public function get uvBuffer():VertexBuffer3D
{
	if(!_uvBuffer)
		updateUvBuffer();
	return _uvBuffer;
}

public function get normalsBuffer():VertexBuffer3D
{
	if(!_normalsBuffer)
		updateNormalsBuffer();
	return _normalsBuffer;
}

// convert RAW buffers to Molehill compatible buffers
// uploads them to the context3D first

public function updateColorsBuffer():void
{
	if(_rawColorsBuffer.length == 0) 
		throw new Error("Raw Color buffer is empty");
	var colorsCount:uint = _rawColorsBuffer.length/4; // 4=rgba
	_colorsBuffer = _context3d.createVertexBuffer(colorsCount, 4);
	_colorsBuffer.uploadFromVector(
		_rawColorsBuffer, 0, colorsCount);
}

public function updateNormalsBuffer():void
{
	// generate normals manually 
	// if the data file did not include them
	if (_rawNormalsBuffer.length == 0)
		forceNormals();
	if(_rawNormalsBuffer.length == 0)
		throw new Error("Raw Normal buffer is empty");
	var normalsCount:uint = _rawNormalsBuffer.length/3;
	_normalsBuffer = _context3d.createVertexBuffer(normalsCount, 3);
	_normalsBuffer.uploadFromVector(
		_rawNormalsBuffer, 0, normalsCount);
}

public function updateVertexBuffer():void
{
	if(_rawPositionsBuffer.length == 0)
		throw new Error("Raw Vertex buffer is empty");
	var vertexCount:uint = _rawPositionsBuffer.length/3;
	_positionsBuffer = _context3d.createVertexBuffer(vertexCount, 3);
	_positionsBuffer.uploadFromVector(
		_rawPositionsBuffer, 0, vertexCount);
}

public function updateUvBuffer():void
{
	if(_rawUvBuffer.length == 0)
		throw new Error("Raw UV buffer is empty");
	var uvsCount:uint = _rawUvBuffer.length/2;
	_uvBuffer = _context3d.createVertexBuffer(uvsCount, 2);
	_uvBuffer.uploadFromVector(
		_rawUvBuffer, 0, uvsCount);
}

public function updateIndexBuffer():void
{
	if(_rawIndexBuffer.length == 0)
		throw new Error("Raw Index buffer is empty");
	_indexBuffer = 
		_context3d.createIndexBuffer(_rawIndexBuffer.length);
	_indexBuffer.uploadFromVector(
		_rawIndexBuffer, 0, _rawIndexBuffer.length);
}

public function restoreNormals():void
{	// utility function
	_rawNormalsBuffer = _cachedRawNormalsBuffer.concat();
}

public function get3PointNormal(
	p0:Vector3D, p1:Vector3D, p2:Vector3D):Vector3D
{	// utility function
	// calculate the normal from three vectors
	var p0p1:Vector3D = p1.subtract(p0);
	var p0p2:Vector3D = p2.subtract(p0);
	var normal:Vector3D = p0p1.crossProduct(p0p2);
	normal.normalize();
	return normal;
}

public function forceNormals():void
{	// utility function
	// useful for when the OBJ file doesn't have normal data
	// we can calculate it manually by calling this function
	_cachedRawNormalsBuffer = _rawNormalsBuffer.concat();
	var i:uint, index:uint;
	// Translate vertices to vector3d array.
	var loop:uint = _rawPositionsBuffer.length/3;
	var vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
	var vertex:Vector3D;
	for(i = 0; i < loop; ++i)
	{
		index = 3*i;
		vertex = new Vector3D(_rawPositionsBuffer[index],
			_rawPositionsBuffer[index + 1], 
			_rawPositionsBuffer[index + 2]);
		vertices.push(vertex);
	}
	// Calculate normals.
	loop = vertices.length;
	var p0:Vector3D, p1:Vector3D, p2:Vector3D, normal:Vector3D;
	_rawNormalsBuffer = new Vector.<Number>();
	for(i = 0; i < loop; i += 3)
	{
		p0 = vertices[i];
		p1 = vertices[i + 1];
		p2 = vertices[i + 2];
		normal = get3PointNormal(p0, p1, p2);
		_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
		_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
		_rawNormalsBuffer.push(normal.x, normal.y, normal.z);
	}
}

} // end class

} // end package




