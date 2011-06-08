package
{
	import com.pinata3d.Engine;
	import com.pinata3d.Pinata;
	import com.pinata3d.Key;
	import com.pinata3d.Mouse;
	import com.pinata3d.Mesh;
	import com.pinata3d.Entity;
	import com.pinata3d.Voxbox;
	import flash.geom.Vector3D;

	public class Main extends Engine
	{
		
		public var time:Number = 0;
		private var triangle:Entity;
		
		[Embed(source = 'gfx/hut_front.png')]
		private const FRONT:Class;
		
		[Embed(source = 'gfx/hut_side.png')]
		private const SIDE:Class;
		
		public function Main()
		{
			super(800, 600, 0);
		}
		
		override public function init():void
		{
			add(new Entity(Mesh.createVoxbox(Voxbox.createDouble(FRONT,SIDE))));
			
			Pinata.debug_camera.identity();
			Pinata.use_debug_camera = false;
			Pinata.debug_camera.position = new Vector3D(20, 20, 20);
			Pinata.debug_camera.lookAt(new Vector3D(0, 0, 0));
		}
		
		override public function update():void
		{
			time += .1;
			
			//
			Pinata.debug_camera.getInput();
			Pinata.camera.identity();
			Pinata.camera.projection(.1, 4096, 40);
			//Pinata.camera.rotationDegreesY = -20;
			//Pinata.camera.position = new Vector3D(Math.cos(time) * 20, 20, Math.sin(time) * 20);
			Pinata.camera.position = Pinata.debug_camera.position;
			Pinata.camera.rotationDegreesY = Pinata.debug_camera.rotationDegreesY;
			Pinata.camera.rotationDegreesZ = Pinata.debug_camera.rotationDegreesZ;
			//Pinata.camera.lookAt(new Vector3D(0, 0, 0));
			//Junk.camera.position = new Vector3D(0,0,10);
			//trace(Pinata.debug_camera.pos_string());
			
			
			//Junk.camera.lookat(new Vector3D(1, 1, 1));
			
			
		}
	}
}