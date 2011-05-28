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
 
	public class Entity
	{
		//This will be where our VertexData will be stored
		private var vertexBuffer:VertexBuffer3D;
		
		//This will define what order Vertices should be drawn
		private var indexBuffer:IndexBuffer3D;
		
		//This program will contain two shaders
		//that modify vertex data
		private var program:Program3D;
		
		private var _mesh:Mesh;
		
		//This is a Matrix that will be used by
		//our VertexShader to modify the position
		//of our vertices (don't worry you'll get it)
		
		private var model:Matrix3D = new Matrix3D();
  
		/**
		* Creates an entity from a mesh
		*/
		public function Entity(mesh:Mesh)
		{
			
			create(mesh);
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
		
		/**
		* renders this entity
		*/
		public function render():void
		{
			var matrix:Matrix3D = model;
			 //set the program that will render to screen
			Pinata.context.setProgram(program);
			
			//This is strange??? WHY TWICE?
			//So basically what this will say is in our AGAL code va0 will be our x, y, z
			//and va1 will be our r, g, b
			
			//0<– index va0
			//vertexBuffer <– vertex buffer we will use
			//0<- where to start looking for va0 (0 because x, y, z starts at 0)
			//Context3DVertexBufferFormat.FLOAT_3 <- will have 3 variables to define x, y, z
			
			//1<– index va1
			//vertexBuffer <– vertex buffer we will use
			//3<- where to start looking for va1 (3 because r, g, b starts at 3)
			//Context3DVertexBufferFormat.FLOAT_3 <- will have 3 variables to define r, g, b
			//I think you'd use Context3DVertexBufferFormat.FLOAT_4 if you were using r,g,b,a
			/*
			context3d.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			context3d.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);
			*/
			//Reset our matrix
			matrix.identity();
			//Scale down the triangle by 0.5 on x, y, z
			matrix.appendScale(0.5, 0.5, 0.5);
			
			matrix.append(Pinata.camera.viewproj);
			//Here are saying vc0 will be our model matrix
			//and it will be effecting our vertex data
			Pinata.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix);
			
			_mesh.render(Pinata.context);
			//draw our triangle to screen
			//0 is what index we should start drawing from
			//1 is how many triangles we want to draw
			/*
			context3d.drawTriangles(indexBuffer, 0, 1);
			*/
		}
	}
 
}