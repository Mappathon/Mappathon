# Mappathon Examples
Some examples on how to get Syphon+MadMapper talking together in OSX.

## Processing
1. Make sure to have MadMapper and processing 2.0b8 installed.
2. Download the Syphon processing library from here: <a href="http://bit.ly/OS81FB" title="Download">http://bit.ly/OS81FB</a>
3. Unzip and copy the 'Syphon' folder to your Processing libraries folder.
<pre>Documents -> Processing -> Libraries</pre>
4. Download the Processing example above and copy to your Processing folder as well.
5. Run the examples and view the Syphon output via MadMapper.

Anything drawn between <b>canvas.beginDraw()</b> and <b>canvas.endDraw()</b> will be outputted to Syphon. Remember to use <b>server.sendImage(canvas)</b> at the end of your sketch to send to MaddMapper.

When trying to port over more complex sketches remember to include the 'canvas.' prefix when drawing. A quick hack can be to use a PImage and get() to capture the screen context and send that through Syphon as an image. See the image and video sketches for an example of this.

<pre>

// you must call beginDraw() to render to the server
canvas.beginDraw();

// all drawing calls are part of the PGraphics context
canvas.background(255);
canvas.stroke(0);
canvas.fill(175);
canvas.ellipse(x,y,32,32);

// it's necessary to end the renderer with endDraw()
canvas.endDraw();

// draw the buffer in your processing window
image(canvas, 0, 0);

//send the buffer via syphon
server.sendImage(canvas);

</pre>

## openFrameworks
1. Clone the ofxSyphon addon into your addons folder. 

<pre>
cd openFrameworks/addons/
git clone https://github.com/astellato/ofxSyphon
</pre>

2. Copy the emptySyphonExample from the openFrameworks folder to your apps directory
3. Make sure you place the example one level deep in your apps folder... for example:

<pre>
openFrameworks -> apps -> mappathonExamples -> emptySyphonExample
</pre>


## Max+Jitter
Make sure you are using the latest version of Max 6.1
NB : the openGL capture example will not work with Max 5 !


1. Download the Max6 Syphon objects from: <a href="http://bit.ly/1dj1Hm2" title="Download">http://bit.ly/1dj1Hm2</a> 

2. Install the objects in your Cycling '74 directory (you can make a new folder for this)

<pre>
Applications -> Cycling '74 -> Your Folder
</pre>

Ex1. The following example shows how to send out a regular jitter matrix through syphon : <a href="http://bit.ly/OOhZrV" title="Example1">http://bit.ly/OOhZrV</a>

Ex2. This example shows how to use jit.gl.node to capture a 3d context to a texture and send it out via syphon: <a href="http://bit.ly/1gS3kSx" title="Example2">http://bit.ly/1gS3kSx</a> 
