public class DuplicateFiles.ItemDuplicateViewer: Gtk.TreeView {

    private Gtk.CellRendererToggle toggle;
    private Gtk.CellRendererText name_file;
    private Gtk.CellRendererPixbuf pixbuf;
    private Gtk.CellRendererText selected;

    private Gtk.TreeViewColumn col_name_file;
    private Gtk.TreeViewColumn col_toggle;
    private Gtk.TreeViewColumn col_pixbuf;
    private Gtk.TreeViewColumn col_selected;

    private Gtk.TreeStore store_model;
    private Gtk.TreeModelFilter filter;

    public ItemDuplicateViewer () {

        this.activate_on_single_click = true;
        store_model = new Gtk.TreeStore(5, typeof(bool), typeof(Gdk.Pixbuf), typeof(string), typeof(string), typeof(string));
        this.set_model(store_model);

        create_cells_and_columns ();
        add_cells_and_columns ();


    }

    public void show_all_categories () {
        restore_original_model ();
    }

    public void show_videos () {
        restore_original_model ();
        set_filter ();
        filter.set_visible_func(filter_show_videos);
        this.set_model(filter);
    }

    public void show_documents () {
        restore_original_model ();
        set_filter ();
        filter.set_visible_func(filter_show_documents);
        this.set_model(filter);
    }

    public void show_applications () {
        restore_original_model ();
        set_filter ();
        filter.set_visible_func(filter_show_applications);
        this.set_model(filter);
    }

    public void show_images () {
        restore_original_model ();
        set_filter ();
        filter.set_visible_func(filter_show_images);
        this.set_model(filter);
    }

    public void set_filter () {
        filter = new Gtk.TreeModelFilter(store_model, null);
    }

    public void restore_original_model () {
        GLib.debug("Restore original model...\n");
        this.model = store_model;
    }

    public async void add(Gee.ArrayList<string> duplicate_file) {
        Gtk.TreeIter? parent = null;
        Gtk.TreeIter? children = null;

        var f = File.new_for_path(duplicate_file.get (1) );
        var mime_type = ContentType.guess(duplicate_file.get (1), new uchar[0], null);
        FileInfo info = f.query_info("standard::*", 0);

        Icon icon = info.get_icon ();
        Gtk.IconInfo icon_24 = Gtk.IconTheme.get_default ().lookup_by_gicon(icon, 32, Gtk.IconLookupFlags.DIR_LTR);
        Gtk.IconInfo icon_16 = Gtk.IconTheme.get_default ().lookup_by_gicon(icon, 24, Gtk.IconLookupFlags.DIR_LTR);

        GLib.Idle.add( () => {
            store_model.append(out parent, null);
            return false;
        });

        string elements_selected = "0 | " + duplicate_file.size.to_string ();
        string file_name_size = info.get_name () + "\n" + GLib.format_size(info.get_size());

        GLib.Idle.add( () => {
            store_model.set(parent, 0, false, 1, icon_24.load_icon(), 2, file_name_size, 3, elements_selected, 4, mime_type, -1);
            foreach(string file in duplicate_file) {
                store_model.append(out children, parent);
                store_model.set(children, 0, false, 1, icon_16.load_icon(), 2, file, 3, "", 4, mime_type, -1);
           }
           return false;
        });
    }

    public void connect_model() {
        this.set_model(store_model);
    }

    public void disconnect_model() {
        this.set_model(null);
    }

    private void create_cells_and_columns () {

        toggle = new Gtk.CellRendererToggle ();
        toggle.toggled.connect ((toggle, path) => {
            GLib.debug("TOOGLE PATH: %s\n", path);
			Gtk.TreePath tree_path = new Gtk.TreePath.from_string (path);
			Gtk.TreeIter iter;
			store_model.get_iter (out iter, tree_path);
			store_model.set (iter, 0, !toggle.active);
           // var parent = iter.get_parent ();
		});

        pixbuf = new Gtk.CellRendererPixbuf ();
        name_file = new Gtk.CellRendererText ();
        selected = new Gtk.CellRendererText ();

        col_toggle = new Gtk.TreeViewColumn ();
        col_pixbuf = new Gtk.TreeViewColumn ();
        col_name_file = new Gtk.TreeViewColumn ();
        col_selected = new Gtk.TreeViewColumn ();

        col_toggle.pack_start(toggle, false);
        col_toggle.add_attribute(toggle, "active", 0);

        col_pixbuf.pack_start(pixbuf, false);
        col_pixbuf.add_attribute(pixbuf, "pixbuf", 1);

        col_name_file.pack_start(name_file, false);
        col_name_file.add_attribute(name_file, "text", 2);

        col_selected.pack_end(selected, false);
        col_selected.add_attribute(selected, "text", 3);
    }

    private void add_cells_and_columns () {
        this.set_headers_visible(false);
        this.append_column(col_toggle);
        this.append_column(col_pixbuf);
        this.append_column(col_name_file);
        this.append_column(col_selected);
    }


    private bool filter_show_videos (Gtk.TreeModel model, Gtk.TreeIter iter) {
        string mime_type;
        model.get(iter, 4, out mime_type);
        if(mime_type.has_prefix("video/")) {
            stdout.printf("Root: video\n");
            return true;
        }
        return false;
    }

    private bool filter_show_applications(Gtk.TreeModel model, Gtk.TreeIter iter) {
        string mime_type;
        model.get(iter, 4, out mime_type);
        if(mime_type.has_prefix("application/")) {
            stdout.printf("Root: applications\n");
            return true;
        }
        return false;
    }

    private bool filter_show_images(Gtk.TreeModel model, Gtk.TreeIter iter) {
        string mime_type;
        model.get(iter, 4, out mime_type);
        if(mime_type.has_prefix("image/")) {
            stdout.printf("Root: images\n");
            return true;
        }
        return false;
    }

    private bool filter_show_documents(Gtk.TreeModel model, Gtk.TreeIter iter) {
        string mime_type;
        model.get(iter, 4, out mime_type);
        if(mime_type.has_prefix("text/")) {
            stdout.printf("Root: text\n");
            return true;
        }
        return false;
    }

}
