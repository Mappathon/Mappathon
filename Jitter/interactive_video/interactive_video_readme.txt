This patch consist in two major things. On one side, we take to movies using the object jit.qt.movie and we apply properties of color and temporality using the objects (jit.chromakey , jit.xfade ) and we send it to one matrix through the object jit.pwindow. 

To send and image or movie manipulated in Max Jitter we need to send the matrix (video) and draw it into a 3d texture with the objective of rendering. It is important to send a trigger bang and erase to the hit.gl.gridshape so it doesn't get stuck in one frame and can clean the buffer and render in real time. 

The video is now drawn into a 3d context. next we render that object using jit.gl.render and once its rendered we send it to a video plane (jit.gl.videoplane ) .

To connect to madmapper we need a syphon object (download syphon library from cycling 74). Our rendered texture can now be send to the syphon server just like we send it to the video plane. 
In this patch we use the kinect for motion detection , it is important to download the freenect.grab library from 
cycling 74. We transform the image into black and white so when can use the threshold to produce data, that way we send bangs that can be used in different way. In this patch is used to control the temporality and the crossfade explained in the first paragraph. 

Ps. for this patch the kinect should be plugged in first before running the patch. also don't forget to place the media that you use inside of the folder where the patch is. Also there is a sub patch called "amibang" that should be in the same folder ( i attach it here too). 
