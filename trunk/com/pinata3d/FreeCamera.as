package com.pinata3d
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
 
	public class FreeCamera extends Camera
	{
		public function getInput():void
		{
			if (Key.isDown(87))
			{
				translate(frontvector);
			}
			
			if (Key.isDown(83))
			{
				translate(backvector);
			}
			
			if (Key.isDown(65))
			{
				translate(leftvector);
			}
			
			if (Key.isDown(68))
			{
				translate(rightvector);
			}
			
			if (Key.isDown(17)) // ctrl
			{
				rotationDegreesY = rotationDegreesY - Mouse.rx;
				rotationDegreesZ = rotationDegreesZ - Mouse.ry;
				if (rotationDegreesZ < 90) rotationDegreesZ = 90;
				if (rotationDegreesZ > 270) rotationDegreesZ = 270;
			}
		}

	}
}