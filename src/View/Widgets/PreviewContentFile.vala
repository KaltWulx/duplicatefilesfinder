public class DuplicateFiles.PreviewContentFile : Gtk.Grid {

    private Gtk.Image image;
    private Gtk.Label lb_file_path;
    private Gtk.Label lb_file_size;
    private Gtk.Label date;
    private Gtk.Label resolution;

    public PreviewContentFile() {
        image = new Gtk.Image ();
        this.add(image);
        show_all();
    }

    public async void load_content_media(string file_path) {
        var mime_type = ContentType.guess(file_path, new uchar[0], null);
        if(mime_type.has_prefix("image/")) {
		    image.set_from_file (file_path);
		    GLib.debug("Cargando imagen: %s\n", file_path);
        }
    }
}
