package com.pinata3d
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.utils.ByteArray;
 
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.display.Bitmap;
 
	public class Mesh
	{
		//This will be where our VertexData will be stored
		private var vertexBuffer:VertexBuffer3D;
		
		//This will define what order Vertices should be drawn
		private var indexBuffer:IndexBuffer3D;
		
		private var _dx:int; // dimensions
		private var _dy:int;
		private var _dz:int;
		
		public function Mesh()
		{
			
			
		}
		
		/**
		* Creates mesh from 1 image
		*/
		static public function create1(image:Class):Mesh
		{
			
			// do these really need names more than that?
			var vtx:Vector.<Number> = new Vector.<Number>();
			var idx:Vector.<uint> = new Vector.<uint>();;
			var n_idx:uint, n_vtx:uint;
			n_idx = 0;
			n_vtx = 0;
			
			
			
			var bmp:Bitmap = new image();
			//var pixels:ByteArray = bmp.bitmapData.getPixels(bmp.bitmapData.rect);
			var mesh:Mesh = new Mesh();
			mesh._dx = bmp.bitmapData.width;
			mesh._dz = mesh._dx;
			mesh._dy = bmp.bitmapData.height;
			for (var x:int = -mesh._dx; x < mesh._dx; x++)
			{
				for (var y:int = 0; y < mesh._dy; y++)
				{
					for (var z:int = -mesh._dz; z < mesh._dz; z++)
					{
						var tx:int, ty:int; // text position
						var r:Number, g:Number, b:Number;
						var px:uint;
						tx = Math.sqrt(x * x + z * z);
						if (tx >= mesh._dx) continue;
						px = bmp.bitmapData.getPixel32(tx, y);
						if ((px & 0x00ffffff) == 0x00ff00ff) continue;
						r = (px & 0x00ff0000) >> 16;
						g = (px & 0x0000ff00) >> 8;
						b = (px & 0x000000ff);
						r /= 255;
						b /= 255;
						g /= 255;
						vtx.push(x - 1.0, y, z - 1.0, r, g, b);
						vtx.push(x + 1.0, y, z + 1.0, r, g, b);
						vtx.push(x, y + 1.0, z, r, g, b);
						idx.push(n_vtx, n_vtx + 1, n_vtx + 2);
						n_vtx += 3;
						n_idx += 3;
						trace("d: " + tx + " [ " + x + " , " + y + " , " + z + " ]: " + r + " " + g + " " + b);
						
						
					}
				}
			}
			
			trace("Created mesh size: " + n_idx + "/" + n_vtx);
			mesh.vertexBuffer = Pinata.context.createVertexBuffer(n_vtx, 6);
			mesh.indexBuffer=Pinata.context.createIndexBuffer(n_idx);
			//send our vertex data to the the vertex buffer
			mesh.vertexBuffer.uploadFromVector(vtx, 0,n_vtx);
			
			//send our index data to the index buffer
			mesh.indexBuffer.uploadFromVector(idx, 0, n_idx);
			
			return mesh;
			
		}
		
		/**
		* Renders this mesh
		*/
		public function render(context:Context3D):void 
		{
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
			context.drawTriangles(indexBuffer, 0, -1);
			//trace("mesh renders!");
		}
	}
}