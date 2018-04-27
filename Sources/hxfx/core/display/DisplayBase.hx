package hxfx.core.display;

/**
 *  Base class for display pieces - use this for all items that need to output to display or svg
 */
class DisplayBase {

    public function render(g2: Graphics): Void {
        throw "render not implemented";
    }

    public function svg(svgXml:Xml): Void {
        throw "svg not implemented";
    }

}