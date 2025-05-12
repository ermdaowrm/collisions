# collisions

collisions is a collision library
there is many functions they are pretty self explanetory
they help you to do math with different shapes because collisions in lua are hard
so
...
the functions are
CreateRectHitbox(x,y,width,height,id) this creates a hitbox to the system with an id
CreateCircHitbox(x,y,radius,id) creates a circle hitbox
CreatePolygonHitbox(vertices,id) creates a hitbox for a polygon, vertices are a table you put in
CreateGroup(id,ids) creates a group of ids that can all be acted apon by different things except for change values. in that case you would have to change every value.
ChangeValue(id,NewValues) asigns newValues to every hitbox type if it is polygon then put a table
objectTouch(id1,id2) checks if objects are touching
CheckClick(id) checks if you click on an id

all you have to do is import the collision.lua and require it and you can use those functions

