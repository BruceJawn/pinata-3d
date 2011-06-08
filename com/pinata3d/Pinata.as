package com.pinata3d
{
	import flash.display3D.Context3D;
	
	public class Pinata
	{
		public static var camera:Camera;
		public static var debug_camera:FreeCamera = new FreeCamera();
		public static var use_debug_camera:Boolean = false;
		public static var width:Number;
		public static var height:Number;
		public static var context:Context3D;
	}
}