public class DuplicateFiles.DuplicateViewer : Gtk.Grid {

    private Gtk.Grid main_box;
    private Gee.ArrayList<string> list_files;
    private Gtk.ListStore list_store;
    private Gtk.TreeView tree_view;
    private Gtk.EventBox event_box;
    private Gtk.Stack stack_tree;
    private Gtk.Label lb_count_selected;
    private int instance;

    private string _content_type;
    private int64 _size_sum;

    public int64 size_sum {
        get {return _size_sum; }
    }
    public string content_type {
        get { return _content_type; }
    }

    public DuplicateViewer( Gee.ArrayList<string> list_files, int instance) {
        this.list_files = list_files;
        this.instance = instance;
        create_widget();
    }

    public void create_widget() {

        event_box = new Gtk.EventBox() {
            vexpand = false,
            valign = Gtk.Align.START,
            halign = Gtk.Align.START,
        };
        event_box.name = "duplicate-viewer-"+ instance.to_string();

        stack_tree = new Gtk.Stack() {
		    transition_type = Gtk.StackTransitionType.SLIDE_DOWN,
		    hexpand = true,
		    halign = Gtk.Align.START,
		};

        main_box = new Gtk.Grid() {
		    halign = Gtk.Align.START,
		    expand = true,
		    margin = 3,
		};
        main_box.attach(stack_tree, 0, 1, 3, 1);
        add(main_box);

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 3) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            expand = true,
            margin_left = 5,
        };

        lb_count_selected = new Gtk.Label("0 | " + list_files.size.to_string ());
        lb_count_selected.halign = Gtk.Align.END;

        var file = File.new_for_path(list_files.get(0));
        _content_type = ContentType.guess(list_files.get(0), new uchar[0], null);

        FileInfo file_info = file.query_info("standard::*", 0);
        Icon icon = file_info.get_icon ();

        Gtk.IconInfo icon_info = Gtk.IconTheme.get_default().lookup_by_gicon(icon, 32, Gtk.IconLookupFlags.DIR_LTR);
        var icon_pixbuf = new Gtk.Image.from_pixbuf(icon_info.load_icon ());

        box.pack_start(icon_pixbuf, true, true, 0);

        var lb_file_name = new Gtk.Label(file_info.get_name ());
        lb_file_name.halign = Gtk.Align.START;
        lb_file_name.valign = Gtk.Align.START;

        var lb_size = new Gtk.Label(GLib.format_size(file_info.get_size()));
        lb_size.halign = Gtk.Align.START;

        var box_info_file = new Gtk.Box(Gtk.Orientation.VERTICAL, 0) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.START,
            expand = true,
        };

        box_info_file.pack_start(lb_file_name, false, false, 0);
        box_info_file.pack_start(lb_size, false, false, 0);

        box.pack_start(box_info_file, true, true, 0);
        box.pack_end(lb_count_selected, true, true, 0);

        event_box.add(box);
        main_box.attach(event_box, 0, 0, 3, 1);
        show_all();
        add_treeview();

        event_box.button_press_event.connect(() => {
            if(stack_tree.get_visible_child_name() == "tree_view") {
                stack_tree.set_visible_child_name("empty-box");
                tree_view.visible = false;
                string css_effect = "#"+ event_box.name +" {background-color: transparent;}";
                Application.css_provider.load_from_data(css_effect);

            } else {
                tree_view.visible = true;
                stack_tree.set_visible_child(tree_view);
                string css_effect = "#"+ event_box.name +" {background-color: rgba(213, 235, 253, 1);}";
                Application.css_provider.load_from_data(css_effect);
            }
         return true;
        });
    }

    private void add_treeview() {

        //Columns Toogle | Pixbuf | Path/File name
        list_store = new Gtk.ListStore(3, typeof(bool), typeof(Gdk.Pixbuf), typeof(string));
        tree_view = new Gtk.TreeView.with_model(list_store);
        tree_view.set_headers_visible (false);
        tree_view.margin_left = 10;

        var toggle = new Gtk.CellRendererToggle();
        toggle.toggled.connect ((toggle, path) => {
			Gtk.TreePath tree_path = new Gtk.TreePath.from_string (path);
			Gtk.TreeIter iter;
			list_store.get_iter (out iter, tree_path);
			list_store.set (iter, 0, !toggle.active);
		});

        var pixbuf = new Gtk.CellRendererPixbuf();
        var file_name = new Gtk.CellRendererText();
        file_name.width_chars = 100;
        file_name.ellipsize = Pango.EllipsizeMode.MIDDLE;

        var col_toggle = new Gtk.TreeViewColumn();
        col_toggle.pack_start(toggle, false);
        col_toggle.add_attribute(toggle, "active", 0);


        var col_pixbuf = new Gtk.TreeViewColumn();
        col_pixbuf.pack_start(pixbuf, false);
        col_pixbuf.add_attribute(pixbuf, "pixbuf", 1);

        var col_file_name = new Gtk.TreeViewColumn();
        col_file_name.pack_start(file_name, false);
        col_file_name.add_attribute(file_name, "text", 2);

        tree_view.append_column(col_toggle);
        tree_view.append_column(col_pixbuf);
        tree_view.append_column(col_file_name);

        stack_tree.add_named(tree_view, "tree_view");

        var empty_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        empty_box.visible = true;
        stack_tree.add_named(empty_box, "empty-box");
        stack_tree.set_visible_child_name("empty-box");
        add_rows.begin();
    }

    private async void add_rows () {
        Gtk.TreeIter iter;

        for(int i = 0; i < list_files.size; i++) {

            list_store.append(out iter);

            var f = File.new_for_path(list_files.get (i) );
            FileInfo info = f.query_info("standard::*", 0);

            _size_sum += info.get_size ();

            Icon icon = info.get_icon ();
            Gtk.IconInfo icon_info = Gtk.IconTheme.get_default ().lookup_by_gicon(icon, 16, Gtk.IconLookupFlags.DIR_LTR);
            list_store.set(iter, 0, false, 1, icon_info.load_icon (), 2, list_files.get (i));
            GLib.Idle.add(add_rows.callback);
            yield;
        }
    }

    public void display_treeview() {
        if(stack_tree.get_visible_child_name() == "tree_view") {
                stack_tree.set_visible_child_name("empty-box");
                tree_view.visible = false;
            } else {
                tree_view.visible = true;
                stack_tree.set_visible_child(tree_view);
         }
    }
}
