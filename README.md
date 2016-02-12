# Trax
Trax was using alot of the features on the map, and using MapKit.
Using MKMapView i had only the Satelitte view. There was preloaded 
waypoints on the map, that when clicked, came up with a small popover,
from there you can click the image for an enlarged view of the picture. 
I then added Edittable waypoints, where if i pressed down and held on the 
map, it would drop a pin and i then was able to edit the name, and a brief 
description of the place. On the iPhone the edit screen comes up modally, 
on the iPad it comes up as a small popOver. Then i used UIImagePickerController
to access the camera, and when someone editted the waypoint, they can take a picture
and use that photo. They can also click on the photo they take and scrollView it. Then i 
added a small containerView for when you are editting a waypoint or viewing one, there will
be an area where the whole map can still be scrolled through and zoomed in on.
