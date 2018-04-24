# HxFx Coding Concepts

The goal of HxFx is to create a business application development framework.

Kha is currently the back end, but this could be traded out in the future. Kha was chosen because of it's simple design and forward looking rendering system. OpenFL, NME, (and eventually HashLink?) would also be good interface layers. While comparing available targets, it appears that Kha is the simplest to build a new custom framework on.

hxfx.Window is the layer between the GUI and back end hardware - it 'translates' what the back end does into the hxfx concepts described below. Currently hxfx.Window receives Kha events and converts them to data updates. All events above hxfx.Window are handled by the bindx2 library with the goal to make everything event driven. In essence, when a property changes, the bindings create a cascade of updates as required. These updates notify the hxfx.Window.Stage instance to render the next frame.

All layout and component display objects inherit from NodeBase. Everything is built in a Tree Graph structure.

NodeBase is used to subscribe to events. When the 'subscribe' boolean is true, the request goes up the parent chain to the Window.Stage which then updates the events down the chain. All position type events are relative to the child (the child does not need to know it's position relative to the Window).

TODO: key events, only propagate to 'focused' child?

Each Node handles it's own internal layout and size. Position and overflow of child nodes is handled by the parent.

TODO: Parents need to tell children what space they have available, but children sometimes need to tell a parent what size they want to be. How to handle this? A 'minimum size' property of the child would handle most of it.
- Currently resolved by providing the child with available layout space, child decides on a final size (which can be larger than the layout space).
- Positioning becomes difficult if the child is larger than layout space and the parent 'stretches'. What to do with relative/percent based position and sizes?
	As parent size changes the child would adjust too, causing a feedback loop...

TODO: Can a node have more than one parent? this would be useful instead of cloning nodes between parents, but would also get difficult to manage
- Currently a child can have only one parent. However a cached image of a child could be stored and displayed to improve render performance (wrap a shared canvas inside each child, when the cached canvas changes it would display across all child nodes without needing a redraw each time)

TODO: CSS/style updates based on binding callbacks - how to manage a style update, and how should styles/layout be determined internally. My guess is that each component would need to have custom code to interpret style settings, so a universal or function callback system to handle styles would not work. It would be great to have styles be a Haxe enum type, but then customized styles would be a problem because they would need to be compiled into the style enum (maybe a workaround for this?)

TODO: How to add effects? Render loop draws parent then children, so a drop shadow would need to be a parent, which works but gets confusing. Maybe a pre-render child list and a post-render child list so an effect could be drawn before the parent.
- The mouse in bounds and content outline can be the same, but the in bounds checking should be done with multiple shapes to allow more complexity and create drop shadows that better match the real shape. For example a rounded-corner container needs a drop shadown and in-bounds (hitbox) that matches. Make the in bounds checking based on all children combined, and allow rect, triangle, circle as the core bounds checking - this should allow enought complexity without slowing down bounds check much (polygon/beizer would be too slow?)

Note to self: Text should be in blocks to allow the font to handle layout properly. I had originally considered breaking Text into individual chars/glyphs and each would handle it's own layout, but this breaks the internal kerning/etc of the font (each char is unaware of it's neighbors). A 'word processor' type app would need to manage breaking text apart if parts of it became styled differently - not going down that rabbit hole for now :)

Goal #1: create an editable text field
X	1. Create a Text node that can display characters
X	2. Get character locations of the Text node
X	3. Capture mouse position and highlight characters
X	4. Capture up/down click and perform highlighting
	- click without drag needs to set cursor position
	5. Capture keyboard to handle text field changes and special commands
	6. Capture right-click - need a way to do a popup box...

TODO: How to handle redraw requests with current binding model? Problem is that modifying redraw area array or setting a flag fires the callback immediately, but all layout changes should be calculated before the final render call happens.
 - this is handled by layout and then render paths:
The basic concept is:
1. A child changes (added to parent, layout change, some other update)
2. The node is marked layoutIsValid=false, the parent listens and propagates up the stack
3. At some point a fixed size container is reached (Window, Dialog, etc) - this fixed size container then blocks propagation and calls layoutToSize down the stack
4. When all layoutToSize calls complete the child will set layoutIsValid to true, which triggers the fixed size container to push a dirty rectangle up the stack
5. At the top of the stack (window/stage), the dirty rectangle is accepted and render engine processes


4/23/2018 - updates to layout enum concepts
It's a hassle to parse the layout rules to find the correct property. When the property updates, push to a read-only variable to make look ups easier. This could be in a separate data structure (see MouseData), that can be bound to and keeps the main class code cleaner. This would also allow a typedef for the layout settings to be passed in to the ctor?

More ideas: Swap in typedef for all layout rules. Typedefs can cascade (http://old.haxe.org/ref/type_advanced), this would allow child classes to extend the original layout typedef and keep everything in one spot. Layout rules would still be enum types to control settings, but they would be applied directly to the layout typedef instead of setLayoutRule system. Bindx can only handle class instance binding, typedef binding does not work. Layout rules would need to be a class instance.