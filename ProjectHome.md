[![](http://www.pinata3d.com/Pinata3d_logo_v01.jpg)](http://www.pinata3d.com)

A 3D voxel engine for upcoming Flash 11 "Molehill" platform.  Written in pure AS3 by [Sos](http://www.sos.gd/) and [McFunkypants](http://www.mcfunkypants.com/), this free game engine features massive polygon crunching power, low-fi retro styled pixel-art graphics, delicious frilly bits... plus CANDY ON THE INSIDE!

Project Goals:
  * image-based geometry creation using axis-projection
  * simplistic engine structure: no hierarchical scene graph
  * blazingly fast FPS due to simple AGAL shaders
  * one million polygon scenes at 60fps
  * keyboard and mouse input functions
  * animated voxel-based game entities
  * voxel terrain and geometry
  * two example games
  * free

Proposed Middleware:
  * bullet physics engine for true 3d simulation
  * box2d physics for 2.5d simulation
  * perlin noise terrain helpers
  * bsfxr sound effects engine
  * a-star pathfinding AI
  * eaze-tween animation
  * minimalcomps gui

The concept behind Pinata3d:

This game engine is based around image-based-geometry.  We're not trying to duplicate the look of Minecraft, but instead the hope is to allow people to make really complex 3d shapes with nothing more than bitmaps as the source.  Imagine being able to make a 3d videogame without ever sculpting a mesh in 3dsmax! Geometry will instead be created with "geometry images" and perlin noise.  Using multiple images, each image representing a side of a shape, you can create 3d geometry.  Project pixels toward the center to derive 3d voxels where they "meet".  For example, draw the side view and front view of a house, embed them in the Pinata3d engine.  Automagically you have a (retro pixelly) 3d voxelly house!

![http://www.pinata3d.com/pinata3d_tech.jpg](http://www.pinata3d.com/pinata3d_tech.jpg)

Coming soon to a party near you - see http://www.pinata3d.com