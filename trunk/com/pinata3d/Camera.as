package com.pinata3d
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
 
	public class Camera
	{
		private var _projection:Matrix3D;
		public var _view:Matrix3D;
		private var _viewproj:Matrix3D;
		
		private var _position:Vector3D;
		private var _direction:Vector3D;
		private var _aspect:Number;
		private var _fov:Number;
		private var _near:Number;
		private var _far:Number;
		
		public function Camera()
		{
			_projection = new Matrix3D();
			_view = new Matrix3D();
			_viewproj = new Matrix3D();
			identity();
		}
		
		public function identity():void 
		{
			_projection.identity();
			_view.identity();
			_viewproj.identity();
		}
		
		public function projection(near:Number = 1.0, far:Number = 4096.0,fov:Number=60.0):void
		{
			_aspect = Pinata.width / Pinata.height;
			_near = near;
			_far = far;
			_fov = fov;
			//_projection.perspectiveRH(1.0, 1.0, _near, _far);
			_projection = perspectiveProjection();
		}
		
		public function lookat(at:Vector3D):void 
		{
			_position = _view.position;
			//_view.lookAtRH(_position, at, new Vector3D(0, 1, 0));
			_position = _view.position;
		}
		
		public function set position(pos:Vector3D):void
		{
			_position = pos;
			_view.position = pos;
		}
		
		public function get position():Vector3D
		{
			_position = _view.position;
			return _position;
		}
		
		public function set direction(dir:Vector3D):void
		{
			_position = _view.position;
			lookat(_position.add(dir));
			
		}
		
		public function get direction():Vector3D
		{
			return new Vector3D();
		}
		
		
		
		public function _precalc():void 
		{
				_viewproj = _projection;
				var _tempos:Vector3D = _position;
				_tempos.negate();
				_viewproj.appendTranslation(_tempos.x,_tempos.y,_tempos.z);
				//_viewproj.appendScale(-1,-1,-1);
				//_viewproj.append(_projection);
		}
		
		public function get viewproj():Matrix3D
		{
			return _viewproj;
		}
		
		protected function perspectiveProjection(fov:Number=90,
			aspect:Number=1, near:Number=1, far:Number=2048):Matrix3D {
			var y2:Number = near * Math.tan(fov * Math.PI / 360);
			var y1:Number = -y2;
			var x1:Number = y1 * aspect;
			var x2:Number = y2 * aspect;
      
			var a:Number = 2 * near / (x2 - x1);
			var b:Number = 2 * near / (y2 - y1);
			var c:Number = (x2 + x1) / (x2 - x1);
			var d:Number = (y2 + y1) / (y2 - y1);
			var q:Number = -(far + near) / (far - near);
			var qn:Number = -2 * (far * near) / (far - near);
      
			return new Matrix3D(Vector.<Number>([
				a, 0, 0, 0,
				0, b, 0, 0,
				c, d, q, -1,
				0, 0, qn, 0
			]));
		}
    
	}
}