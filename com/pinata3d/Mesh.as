package com.pinata3d
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.utils.ByteArray;
	import org.flashdevelop.utils.FlashConnect;
 
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
	
	import com.pinata3d.Molehill_obj_parser;
 
	public class Mesh
	{
		//This will be where our VertexData will be stored
		private var vertexBuffer:VertexBuffer3D;
		private var rgbBuffer:VertexBuffer3D;
		private var mesh_has_rgb_in_another_buffer:Boolean = false;
		
		//This will define what order Vertices should be drawn
		private var indexBuffer:IndexBuffer3D;
		
		private var _sx:int; // dimensions
		private var _sy:int;
		private var _sz:int;
		
		public static var MASK:uint = 0x00ff00ff; // magenta, magic pink, the false colour
		
		public function Mesh()
		{
		}
		
		/**
		* Creates mesh from an OBJ file
		*/
		static public function createOBJ(obj_data:Class, scale:Number = 1, data_is_zxy:Boolean = false, texture_flip:Boolean = false):Mesh
		{
			var mesh:Mesh = new Mesh();
			trace("createOBJ is parsing OBJ data...");
			var objmesh:Molehill_obj_parser = new Molehill_obj_parser(obj_data, Pinata.context, scale, data_is_zxy, texture_flip);			
			mesh.vertexBuffer = objmesh.positionsBuffer;
			mesh.indexBuffer = objmesh.indexBuffer;
			mesh.rgbBuffer = objmesh.colorsBuffer;
			mesh.mesh_has_rgb_in_another_buffer = true; 
			return mesh;
		}
		
		static public function omg(val:uint, shift:uint):uint
		{
			// srsly... (short name is for quick lookup)
			var oldvar:uint = val;
			val <<= shift >> 1;
			val |= val >> 3;
			val &= 7;
			if ((shift & 4)==0) val = (~(val ^ (((val >> 2) ^ (val & 1)) ? 6 : 0 ))) & 7;
			trace(oldvar, shift, "=", val);
			return val;
		}
		
		static public function createVoxbox(vox:Voxbox):Mesh
		{
			// optimisation reminder
			var vtx:Vector.<Number> = new Vector.<Number>();
			var idx:Vector.<uint> = new Vector.<uint>();
			var n_idx:uint, n_vtx:uint;
			n_idx = 0;
			n_vtx = 0;
			var mesh:Mesh = new Mesh();
			mesh._sx = vox.sx;
			mesh._sz = vox.sy;
			mesh._sy = vox.sz;
			for (var x:int = 0; x < vox.sx; x++)
			{
				for (var y:int = 0; y < vox.sy; y++)
				{
					for (var z:int = 0; z < vox.sz; z++)
					{
						if (vox.mask(x, y, z)) continue;
						var col:uint = vox.getAt(x, y, z);
						var r:Number = ((col & 0x00ff0000) >> 16) / 255.0,
							g:Number = ((col & 0x0000ff00) >> 8) / 255.0,
							b:Number = ((col & 0x000000ff)) / 255.0;
						
						// it's time for some MAD as3
						
						// this adds some redundant verts, but the process is simpler.
						// constructing vert cube
						for (var c:uint = 0; c < 8; c++)
						{
							// cube has 8 verts, that are represented using 3 bits
							var bx:Number = c >> 2,
								by:Number = (c >> 1) & 1, 
								bz:Number = c & 1;
							//trace(bx, by, bz);
							vtx.push(x + bx, y + by, z + bz, bx, by, bz);
						}
						
						for (var c:uint = 0; c < 6; c++)
						{
							var ax:Vector.<int> = new Vector.<int>();
							
							ax.push(0, 0, 0);
							ax[c >> 1] = (c & 1) ? 1 : -1;
							if (vox.mask(x + ax[0], y + ax[1], z + ax[2]))
							{
								var ix:Vector.<uint> = new Vector.<uint>();
								if (c == 0) ix.push(0, 3, 2, 0, 1, 3);
								if (c == 1) ix.push(7, 4, 6, 7, 5, 4);
								if (c == 2) ix.push(0, 5, 1, 0, 4, 5);
								if (c == 3) ix.push(7, 2, 3, 7, 6, 2);
								if (c == 4) ix.push(0, 6, 4, 0, 2, 6);
								if (c == 5) ix.push(7, 1, 5, 7, 3, 1);
								
								for each (var i:uint in ix) idx.push(n_vtx + i);
								/*
								idx.push(n_vtx + omg(0, c), n_vtx + omg(2, c), n_vtx + omg(3, c), 
										 n_vtx + omg(0, c), n_vtx + omg(3, c), n_vtx + omg(1, c));
								*/
								n_idx += 6;
							}
						}
						n_vtx += 8;
						
						
						
					}
				}
			}
			//for each (var a:uint in idx) trace(a);
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
		* Creates mesh from 1 image
		*/
		/*
		static public function create1(image:Class):Mesh
		{
			
			// do these really need names more than that?
			var vtx:Vector.<Number> = new Vector.<Number>();
			var idx:Vector.<uint> = new Vector.<uint>();
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
						//trace("d: " + tx + " [ " + x + " , " + y + " , " + z + " ]: " + r + " " + g + " " + b);
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
		*/
		
		/**
		* Renders this mesh
		*/
		public function render(context:Context3D):void 
		{
			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			if (!mesh_has_rgb_in_another_buffer)
				context.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
			else
				context.setVertexBufferAt(1, rgbBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context.drawTriangles(indexBuffer, 0, -1);
			//trace("mesh renders!");
		}
	}
}



