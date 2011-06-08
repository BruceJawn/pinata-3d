package com.pinata3d
{
	import flash.display.Bitmap;
	
	public class Voxbox {
	
		public var box:Vector.<uint>;
		public var size:uint;
		public var sx:uint;
		public var sy:uint;
		public var sz:uint;
	
		function Voxbox(sx:uint, sy:uint, sz:uint)
		{
			this.sx = sx;
			this.sy = sy;
			this.sz = sz;
			this.size = sx * sy * sz;
			trace(size);
			box = new Vector.<uint>(size, true);
			for (var c:uint = 0; c < size; c++) box[c] = Mesh.MASK;
		}
	
		public function getAt(x:uint, y:uint, z:uint):uint
		{
			if (x >= sx || y >= sy || z >= sz || x < 0 || y < 0 || z < 0) return Mesh.MASK;
			return box[x * sy * sz + y * sz + z];
		}
	
		public function setAt(x:uint, y:uint, z:uint,colour:uint):void
		{
			box[x * sy * sz + y * sz + z] = colour; // we could store arbitrary info in alpha
		}
	
		public function mask(x:uint, y:uint, z:uint):Boolean
		{
			//var ret:Boolean;
			if (x >= sx || y >= sy || z >= sz || x < 0 || y < 0 || z < 0) return true;
			if ((box[x * sy * sz + y * sz + z] & 0x00ffffff) == Mesh.MASK) return true; else return false;
			//return ret;
		}
		/*
		function neighbours(x:uint, y:uint, z:uint):Boolean
		{
			return box[x * sy * sz + y * sz + sz]&0x00ffffff==Mesh.MASK;
		}
		*/
		
		// this one is broken...
		static public function createSpin(image:Class):Voxbox
		{
			var bmp:Bitmap = new image();
			var vox:Voxbox= new Voxbox(bmp.bitmapData.width*2,bmp.bitmapData.height,bmp.bitmapData.width*2);
			trace(vox.sx, vox.sy, vox.sz,vox.size);
			for (var x:int = 0; x < vox.sx; x++)
			{
				for (var y:int = 0; y < vox.sy; y++)
				{
					for (var z:int = 0; z < vox.sz; z++)
					{
						var tx:int, ty:int,bx:int,bz:int;
						var col:uint;
						var d:Number;
						bx = x - vox.sx / 2;
						bz = z - vox.sz / 2;
						d = bx * bx + bz * bz
						tx = Math.sqrt(d);
						//tx = x / 2;
						if (tx >= bmp.bitmapData.width) continue;
						ty = y;
						
						col = bmp.bitmapData.getPixel32(tx, ty);
						var r:Number = ((col & 0x00ff0000) >> 16) ,// 255.0,
							g:Number = ((col & 0x0000ff00) >> 8) ,// 255.0,
							b:Number = ((col & 0x000000ff)) ;// 255.0;
						trace(tx,ty,r,g,b);
						vox.setAt(x, y, z, col);
					}
				}
			}
			return vox;
		}
		
		static public function createDouble(front_image:Class,side_image:Class):Voxbox
		{
			var front:Bitmap = new front_image();
			var side:Bitmap = new side_image();
			if (front.bitmapData.height != side.bitmapData.height); // scream and puke
			var vox:Voxbox= new Voxbox(front.bitmapData.width,front.bitmapData.height,side.bitmapData.width);
			trace(vox.sx, vox.sy, vox.sz);
			for (var x:int = 0; x < vox.sx; x++)
			{
				for (var y:int = 0; y < vox.sy; y++)
				{
					for (var z:int = 0; z < vox.sz; z++)
					{
						var col1:uint,col2:uint,col:uint;
						col1 = front.bitmapData.getPixel32(x, y);
						col2 = side.bitmapData.getPixel32(z, y);
						if ((col1 & 0xffffff) == Mesh.MASK || (col2 & 0xffffff) == Mesh.MASK) continue;
						/*
						var r1:Number = ((col & 0x00ff0000) >> 16) ,// 255.0,
							g1:Number = ((col & 0x0000ff00) >> 8) ,// 255.0,
							b1:Number = ((col & 0x000000ff)) ;// 255.0;
						trace(tx,ty,r,g,b);
						*/
						vox.setAt(x, y, z, col1);
					}
				}
			}
			return vox;
		}
	}
}