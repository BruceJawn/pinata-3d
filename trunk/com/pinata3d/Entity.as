package com.pinata3d
{
	import com.adobe.utils.AGALMiniAssembler;
 
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.display3D.*;
 
	public class Entity
	{
		//This will be where our VertexData will be stored
		private var vertexBuffer:VertexBuffer3D;
		
		//This will define what order Vertices should be drawn
		private var indexBuffer:IndexBuffer3D;
		
		//This program will contain two shaders
		//that modify vertex data
		private var program:Program3D;
		
		// the actual model data and Molehill buffers
		// are parsed and stored here
		private var _mesh:Mesh;
		
		// Matrix variables (position, rotation, etc.)
		// using get and set functions, you don't need
		// to do any matrix math for simple movements etc.
		private var _transform:Matrix3D;
		private var _inverseTransform:Matrix3D;
		private var _transformNeedsUpdate:Boolean;
		private var _valuesNeedUpdate:Boolean;
		private var _x:Number = 0;
		private var _y:Number = 0;
		private var _z:Number = 0;
		private var _rotationDegreesX:Number = 0;
		private var _rotationDegreesY:Number = 0;
		private var _rotationDegreesZ:Number = 0;
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _scaleZ:Number = 1;
		private const RAD_TO_DEG:Number = 180/Math.PI;
		
		// Render modes:
		public var blend_src:String = Context3DBlendFactor.ONE;
		public var blend_dst:String = Context3DBlendFactor.ZERO;
		public var depth_test_mode:String = Context3DCompareMode.LESS;
		public var depth_test:Boolean = true;
		public var culling_mode:String = Context3DTriangleFace.FRONT;
		
		// if this is set entity is "stuck" to another
		public var following:Entity = null;
  
		/**
		* Creates an entity from a mesh
		*/
		public function Entity(mesh:Mesh = null)
		{
			_transform = new Matrix3D();
			if (mesh) create(mesh);
		}
	 
		/**
		* actual creator function
		*/
		public function create(mesh:Mesh):void
		{
			_mesh = mesh;
			/*
			//create the vertex buffer
			//we will have 3 vertices
			//and there will be 6 elements to each vertex x, y, z, r, g, b
			vertexBuffer=context3d.createVertexBuffer(3, 6);
			
			//create the index buffer for vertices (order which the triangle goes)
			//we have one triangle so there are 3 vertices and so there are 3 indices also
			indexBuffer=context3d.createIndexBuffer(3);
			
			//we want to create our vertex data
			//vertex data will contain the position and colour of each vertex
			//Here's an explation of the data below
			//Each vertex will have the position first then the colour
			//x==-1 is the "left side of the screen"
			//x==1 is the "right side of the screen"
			//x==0 is the middle of the screen
			//The same applies for Y
			//Colours are represented as decimals so
			//1, 0, 0 <- full red 255 (r, g, b)
			//0.5, 0, 0 <- half red 128
			
			//The following will define a triangle where
			//The bottom left corner is red
			//The top middle corner is green
			//The bottom right corner is blue
			var vertexData:Vector.<Number>=Vector.<Number>(
			 [
			  -1, -1, 0,  255/255, 0, 0, //<- 1st vertex x,y,z,r,g,b
			  0, 1, 0,  0, 255/255, 0, //<- 2nd vertex x,y,z,r,g,b
			  1, -1, 0,  0, 0, 255/255 //<- 3rd vertex x,y,z,r,g,b
			 ]
			);
			
			//This is the index data we are saying draw the vertices
			//in this order
			//0==first vertex
			//1==second vertex
			//2==third vertex
			var indexData:Vector.<uint>=Vector.<uint>([0, 1, 2]);
			
			//send our vertex data to the the vertex buffer
			vertexBuffer.uploadFromVector(vertexData, 0, 3);
			
			//send our index data to the index buffer
			indexBuffer.uploadFromVector(indexData, 0, 3);
			
			*/
			
			//we are going to need to agal "compiler" one for vertex and the other for fragment
			var agalVertex:AGALMiniAssembler=new AGALMiniAssembler();
			var agalFragment:AGALMiniAssembler=new AGALMiniAssembler();
			
			//So lets do some AGAL
			//AGAL is very "basic"
			//It's made up of statements
			//Each statement has at least the following
			//Operation OutPut, Input1
			//Sometimes you could have two inputs
			//Operation OutPut, Input1, Input2
			
			//So how this works lets say we wanted to do something like
			//I*J==K
			//our agal statement would look something like this
			//mul K, I, J
			
			//mul==Operation
			//K==Output
			//I==Input1
			//J==Input2
			
			//Here are some definitions for things you will see below
			//m44==operation to run a Matrix over your data
			//op==output for where the vertex should be on screen
			//va0==x, y, z of a vertex in our triangle
			//vc0==constant that will be defined later (our matrix for changing vertices)
			//v0==a "variable" that will sit between our vertex shader and fragment shader
			//va1==r, g, b of a vertex
			//source for our VertexShader AGAL program
			
			//Here's a decription of what the following lines are doing:
			//m44 op, va0, vc0 -> apply a 4×4 matrix on our vertex screen and output it
			//mov v0, va1 -> take our colour at this vertex and send it to the fragment shader
			var agalVertexSource:String="m44 op, va0, vc0\n" +
									 "mov v0, va1\n";
			
			//oc==outPut color (colour on screen)
			//v0==Variable that sits between the vertex shader and fragment
			//mov oc, v0 -> take our colour and output it to screen
			var agalFragmentSource:String="mov oc, v0\n";
			
			//compile our AGAL source
			//when we compile we'll get a byteArray that our shaders can use
			agalVertex.assemble(Context3DProgramType.VERTEX, agalVertexSource);
			agalFragment.assemble(Context3DProgramType.FRAGMENT, agalFragmentSource);
			
			//Create a program that will use our shaders
			//Remember our program will contain a Vertex Shader and a Fragment Shader
			program=Pinata.context.createProgram();
			
			//Send our compiled Shaders to the program to use
			//agalCode==bytearray
			program.upload(agalVertex.agalcode, agalFragment.agalcode);
			
			
		}

		public function get transform():Matrix3D
		{
			if(_transformNeedsUpdate)
				updateTransformFromValues();
			return _transform;
		}
		public function set transform(value:Matrix3D):void
		{
			_transform = value;
			_transformNeedsUpdate = false;
			_valuesNeedUpdate = true;
		}

		public function get frontvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(0, 0, 1);
			return transform.deltaTransformVector(vector);
		}

		public function get backvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(0, 0, -1);
			return transform.deltaTransformVector(vector);
		}

		public function get leftvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(-1, 0, 0);
			return transform.deltaTransformVector(vector);
		}

		public function get rightvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(1, 0, 0);
			return transform.deltaTransformVector(vector);
		}

		public function get upvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(0, 1, 0);
			return transform.deltaTransformVector(vector);
		}

		public function get downvector():Vector3D
		{
			var vector:Vector3D = new Vector3D(0, -1, 0);
			return transform.deltaTransformVector(vector);
		}

		public function get rotationTransform():Matrix3D
		{
			var d:Vector.<Vector3D> = transform.decompose();
			d[0] = new Vector3D();
			d[1] = new Vector3D(1, 1, 1);
			var t:Matrix3D = new Matrix3D();
			t.recompose(d);
			return t;
		}

		public function get reducedTransform():Matrix3D
		{
			var raw:Vector.<Number> = transform.rawData;
			raw[3] = 0; // Remove translation.
			raw[7] = 0;
			raw[11] = 0;
			raw[15] = 1;
			raw[12] = 0;
			raw[13] = 0;
			raw[14] = 0;
			var reducedTransform:Matrix3D = new Matrix3D();
			reducedTransform.copyRawDataFrom(raw);
			return reducedTransform;
		}

		public function get invRotationTransform():Matrix3D
		{
			var t:Matrix3D = rotationTransform;
			t.invert();
			return t;
		}

		public function set position(value:Vector3D):void
		{
			_x = value.x;
			_y = value.y;
			_z = value.z;

			_transformNeedsUpdate = true;
		}

		public function get position():Vector3D
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();

			return new Vector3D(_x, _y, _z);
		}

		public function get positionVector():Vector.<Number>
		{
			return Vector.<Number>([_x, _y, _z, 1.0]);
		}

		public function get inverseTransform():Matrix3D
		{
			_inverseTransform = transform.clone();
			_inverseTransform.invert();

			return _inverseTransform;
		}

		// Position:

		public function set x(value:Number):void
		{
			_x = value;
			_transformNeedsUpdate = true;
		}
		public function get x():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _x;
		}

		public function set y(value:Number):void
		{
			_y = value;
			_transformNeedsUpdate = true;
		}
		public function get y():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _y;
		}

		public function set z(value:Number):void
		{
			_z = value;
			_transformNeedsUpdate = true;
		}
		public function get z():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _z;
		}

		// Rotation:

		public function set rotationDegreesX(value:Number):void
		{
			_rotationDegreesX = value;
			_transformNeedsUpdate = true;
		}
		public function get rotationDegreesX():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesX;
		}

		public function set rotationDegreesY(value:Number):void
		{
			_rotationDegreesY = value;
			_transformNeedsUpdate = true;
		}
		public function get rotationDegreesY():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesY;
		}

		public function set rotationDegreesZ(value:Number):void
		{
			_rotationDegreesZ = value;
			_transformNeedsUpdate = true;
		}
		public function get rotationDegreesZ():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _rotationDegreesZ;
		}

		// Scale:

		public function set scale(vec:Vector3D):void
		{
			_scaleX = vec.x;
			_scaleY = vec.y;
			_scaleZ = vec.z;
			_transformNeedsUpdate = true;
		}
		public function get scale():Vector3D
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return new Vector3D(_scaleX, _scaleY, _scaleZ, 1.0);
		}
		public function set scaleXYZ(value:Number):void
		{
			_scaleX = value;
			_scaleY = value;
			_scaleZ = value;
			_transformNeedsUpdate = true;
		}
		public function get scaleXYZ():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleX; // impossible to determine
			_transformNeedsUpdate = true;
		}
		public function set scaleX(value:Number):void
		{
			_scaleX = value;
			_transformNeedsUpdate = true;
		}
		public function get scaleX():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleX;
		}

		public function set scaleY(value:Number):void
		{
			_scaleY = value;
			_transformNeedsUpdate = true;
		}
		public function get scaleY():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleY;
		}

		public function set scaleZ(value:Number):void
		{
			_scaleZ = value;
			_transformNeedsUpdate = true;
		}
		public function get scaleZ():Number
		{
			if(_valuesNeedUpdate)
				updateValuesFromTransform();
			return _scaleZ;
		}

		// Update:

		public function updateTransformFromValues():void
		{
			_transform.identity();

			_transform.appendRotation(
				_rotationDegreesX, Vector3D.X_AXIS);
			_transform.appendRotation(
				_rotationDegreesY, Vector3D.Y_AXIS);
			_transform.appendRotation(
				_rotationDegreesZ, Vector3D.Z_AXIS);

			_transform.appendScale(_scaleX, _scaleY, _scaleZ);

			_transform.appendTranslation(_x, _y, _z);

			_transformNeedsUpdate = false;
		}

		public function updateValuesFromTransform():void
		{
			var d:Vector.<Vector3D> = _transform.decompose();

			var position:Vector3D = d[0];
			_x = position.x;
			_y = position.y;
			_z = position.z;

			var rotation:Vector3D = d[1];
			_rotationDegreesX = rotation.x*RAD_TO_DEG;
			_rotationDegreesY = rotation.y*RAD_TO_DEG;
			_rotationDegreesZ = rotation.z*RAD_TO_DEG;

			var scale:Vector3D = d[2];
			_scaleX = scale.x;
			_scaleY = scale.y;
			_scaleZ = scale.z;

			_valuesNeedUpdate = false;
		}

		// Utils:

		public function pos_string():String
		{
			if (_valuesNeedUpdate)
				updateValuesFromTransform();
			
			return _x.toFixed(2) + ',' 
				+ _y.toFixed(2) + ',' 
				+ _z.toFixed(2);
		}
		
		public function lookAt(target:Vector3D):void
		{
			var position:Vector3D = new Vector3D(_x, _y, _z);

			var yAxis:Vector3D, zAxis:Vector3D, xAxis:Vector3D;
			var upAxis:Vector3D = Vector3D.Y_AXIS;
			zAxis = target.subtract(position);
			zAxis.normalize();
			xAxis = upAxis.crossProduct(zAxis);
			xAxis.normalize();
			yAxis = zAxis.crossProduct(xAxis);

			var raw:Vector.<Number> = new Vector.<Number>(16);
			_transform.copyRawDataTo(raw);

			raw[uint(0)]  = _scaleX*xAxis.x;
			raw[uint(1)]  = _scaleX*xAxis.y;
			raw[uint(2)]  = _scaleX*xAxis.z;

			raw[uint(4)]  = _scaleY*yAxis.x;
			raw[uint(5)]  = _scaleY*yAxis.y;
			raw[uint(6)]  = _scaleY*yAxis.z;

			raw[uint(8)]  = _scaleZ*zAxis.x;
			raw[uint(9)]  = _scaleZ*zAxis.y;
			raw[uint(10)] = _scaleZ*zAxis.z;

			_transform.copyRawDataFrom(raw);

			var d:Vector.<Vector3D> = _transform.decompose();
			var rotation:Vector3D = d[1];
			_rotationDegreesX = rotation.x * RAD_TO_DEG;
			_rotationDegreesY = rotation.y * RAD_TO_DEG;
			_rotationDegreesZ = rotation.z * RAD_TO_DEG;
			
			_transformNeedsUpdate = true; // force update
		}

		public function translate(vec:Vector3D):void
		{
		  	_x += vec.x;
			_y += vec.y;
			_z += vec.z;
			_transformNeedsUpdate = true;
		}
		
		// create an exact duplicate in the game world
		// whle re-using all Molehill objects
		public function clone():Entity
		{
			if(_transformNeedsUpdate)
				updateTransformFromValues();
			var myclone:Entity = new Entity();
			myclone.transform = this.transform.clone();
			myclone._mesh = this._mesh;
			myclone.vertexBuffer = this.vertexBuffer;
			myclone.indexBuffer = this.indexBuffer;
			myclone.program = this.program;
			myclone.blend_src = this.blend_src;
			myclone.blend_dst = this.blend_dst;
			myclone.depth_test_mode = this.depth_test_mode;
			myclone.depth_test = this.depth_test;
			myclone.culling_mode = this.culling_mode;
			myclone.following = this.following;
			myclone.updateValuesFromTransform();
			return myclone;
		}
		
		/**
		* renders this entity
		*/
		private var matrix:Matrix3D = new Matrix3D();
		public function render(view:Matrix3D,projection:Matrix3D):void
		{
			// only render if these are set
			if (!_mesh) return;
			view.invert();
			//Reset our matrix
			matrix.identity();
			matrix.append(transform);
			if (following) matrix.append(following.transform);
			matrix.append(view);
			matrix.append(projection);
			
			//matrix.append(Pinata.camera.viewproj);
			//Here are saying vc0 will be our model matrix
			//and it will be effecting our vertex data
			Pinata.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix,true);
			
			// set the render state
			Pinata.context.setBlendFactors(blend_src, blend_dst);
			Pinata.context.setDepthTest(depth_test,depth_test_mode);
			Pinata.context.setCulling(culling_mode);
				
			// select our shader
			Pinata.context.setProgram(program);

			// render it
			_mesh.render(Pinata.context);
			
		}

	}
 
}