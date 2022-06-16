public class DuplicateFiles.Preferences : Gtk.Dialog {
    private Gtk.Stack stack;

    public Preferences(Gtk.Window window) {
        Object(use_header_bar: 1);

        this.set_transient_for(window);
        this.set_modal(true);

        load_default_preferences();

        this.delete_event.connect( ()=> {
            this.hide_on_delete ();
            return true;
        });
    }

    public void load_default_preferences() {
        create_ui_elements ();
    }

    public void create_ui_elements() {

        var header_bar = this.get_header_bar ();

        var stack_switcher = new Gtk.StackSwitcher () {
            icon_size = 24,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
        };

        stack = new Gtk.Stack () {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
        };
        stack_switcher.stack = stack;

        create_general_ui ();
        create_exclude_ui ();

        header_bar.pack_start(stack_switcher);

        var container = this.get_content_area ();
        container.add(stack);
    }

    private void create_general_ui() {
        var grid  = new Gtk.Grid() {
            valign = Gtk.Align.CENTER,
            halign = Gtk.Align.CENTER,
            row_spacing  = 15,
            column_spacing  = 20,
            row_homogeneous = true,
            margin = 10,
        };

        var list_file_size = new Gtk.ListStore(1, typeof (string));
        var cell_sizes = new Gtk.CellRendererText ();

        var combo_file_size = new Gtk.ComboBox ();
        combo_file_size.set_model(list_file_size);

        combo_file_size.pack_start(cell_sizes, true);
        combo_file_size.add_attribute(cell_sizes, "text", 0);

        Gtk.TreeIter iter;

        list_file_size.append(out iter);
        list_file_size.set(iter, 0, "Automatic", -1);//1KB 5 KB 1Mb 5Mb 20Mb 200Mb

        list_file_size.append(out iter);
        list_file_size.set(iter, 0, "1 KB", -1);//1KB 5 KB 1Mb 5Mb 20Mb 200Mb

        list_file_size.append(out iter);
        list_file_size.set(iter, 0, "5 KB", -1);

        list_file_size.append(out iter);
        list_file_size.set(iter, 0, "1 MB", -1);

        list_file_size.append(out iter);
        list_file_size.set(iter, 0, "5 MB", -1);

        var list_checksum_type = new Gtk.ListStore (1, typeof (string));
        var combo_checksum_type = new Gtk.ComboBox ();
        combo_checksum_type.set_model(list_checksum_type);

        var cell_checksum = new Gtk.CellRendererText ();
        combo_checksum_type.pack_start(cell_checksum, true);
        combo_checksum_type.add_attribute(cell_checksum, "text", 0);

        Gtk.TreeIter iter_checksum;

        list_checksum_type.append(out iter_checksum);
        list_checksum_type.set(iter_checksum, 0, "MD5", -1);

        list_checksum_type.append(out iter_checksum);
        list_checksum_type.set(iter_checksum, 0, "SHA-128", -1);

        var lb_file_size = new Gtk.Label("Minimun file size");
        lb_file_size.halign = Gtk.Align.START;

        var lb_checksum_type = new Gtk.Label("Checksum algorithm type");
        lb_checksum_type.halign = Gtk.Align.START;

        combo_file_size.set_active(Application.settings.get_int("minimum-file-size"));
        combo_checksum_type.set_active(Application.settings.get_int("checksum-type"));

        combo_file_size.changed.connect( () => {
            Application.settings.set_int("minimum-file-size", combo_file_size.get_active ());
            int data = Application.settings.get_int("minimum-file-size");
            stdout.printf("Valor del archivo minimo: %d\n", data);
        });

        combo_checksum_type.changed.connect( () => {
            Application.settings.set_int("checksum-type", combo_checksum_type.get_active ());
        });

        grid.attach(lb_file_size, 0, 0, 1, 1);
        grid.attach(combo_file_size, 1, 0, 1, 1);
        grid.attach(lb_checksum_type, 0, 1, 1, 1);
        grid.attach(combo_checksum_type, 1, 1, 1, 1);

        stack.add_titled(grid, "general", "General Config");

        var value_data = new GLib.Value(typeof (string));
        value_data.set_string ("preferences-system-symbolic");
        stack.child_set_property(grid, "icon-name", value_data);
    }

    private void create_exclude_ui() {

        var grid = new Gtk.Grid () {
            margin = 5,
            row_spacing = 10,

        };

        stack.add_titled(grid, "exclude", "Exclude elements");

        var value_data = new GLib.Value(typeof (string));
        value_data.set_string ("emblem-unreadable-symbolic");

        var list_type = new Gtk.ListBox();
        var list_paths = new Gtk.ListBox();
        var list_folder = new Gtk.ListBox();

        var btn_add_path = new Gtk.Button.from_icon_name("list-add-symbolic");
        btn_add_path.clicked.connect( ()=> {
            Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
		    "Select your favorite file", (Gtk.Window) this, Gtk.FileChooserAction.SELECT_FOLDER,
		    "_Cancelar",
		    Gtk.ResponseType.CANCEL,
		    "_Seleccionar",
		    Gtk.ResponseType.ACCEPT);
		    chooser.set_modal(true);
		    chooser.set_transient_for(this);

            if(chooser.run() == Gtk.ResponseType.ACCEPT) {
                SList<string> uris = chooser.get_uris ();
                foreach(var data in uris) {

                }
                list_paths.add(new DuplicateFiles.ExcludeListRow("folder", chooser.get_filename ()));
            }
            chooser.close ();
        });


        var btn_add_folder = new Gtk.Button.from_icon_name("list-add");

        var btn_del_path = new Gtk.Button.from_icon_name("list-remove-symbolic");
        var btn_del_folder = new Gtk.Button.from_icon_name("list-remove");

        var stack_list = new Gtk.Stack() {
            transition_type = Gtk.StackTransitionType.CROSSFADE,
        };

        var vseparator = new Gtk.Separator(Gtk.Orientation.VERTICAL);
        var hseparator = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);

        var hbox_btn_paths = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
        hbox_btn_paths.pack_start(btn_add_path, false, false);
        hbox_btn_paths.pack_start(btn_del_path, false, false);

        var grid_exclude_paths = new Gtk.Grid () {
            margin_bottom = 5,
        };


        grid_exclude_paths.attach(list_paths, 0, 0, 1, 1);
        grid_exclude_paths.attach(hseparator, 0, 1, 1, 1);
        grid_exclude_paths.attach(hbox_btn_paths, 0, 2, 1, 1);

        list_type.add(new DuplicateFiles.ExcludeListRow("folder", "Excluded directories"));
        list_type.add(new DuplicateFiles.ExcludeListRow("application-octet-stream", "Files extensions"));



        var lb_hidden_file = new Gtk.Label("Scan hidden files");
        lb_hidden_file.halign = Gtk.Align.START;
        var lb_hidden_directory = new Gtk.Label("Scan hidden folders");
        lb_hidden_directory.halign = Gtk.Align.START;

        var cb_file = new Gtk.CheckButton();
        var cb_directory = new Gtk.CheckButton();


        cb_file.set_active(Application.scan_hidden_file ());
        cb_directory.set_active(Application.scan_hidden_directory ());

        cb_file.toggled.connect( ()=> {
                Application.set_scan_hidden_file (cb_file.active);
        });

        cb_directory.toggled.connect( ()=> {
                Application.set_scan_hidden_directory (cb_directory.active);
        });

        var grid_hidden_setup = new Gtk.Grid() {
            column_homogeneous = true,
            row_spacing = 8,
            column_spacing = 15,
        };

        grid_hidden_setup.attach(lb_hidden_file, 0, 0, 1 , 1);
        grid_hidden_setup.attach(cb_file, 1, 0, 1, 1);
        grid_hidden_setup.attach(lb_hidden_directory, 0, 1, 1, 1);
        grid_hidden_setup.attach(cb_directory, 1, 1, 1, 1);

        grid.attach(grid_hidden_setup, 0, 0, 1, 1);

        grid.attach(list_type, 0, 1, 1, 1);
        grid.attach(vseparator, 1, 1, 1, 1);
        grid.attach(stack_list, 2, 1, 1, 1);

        stack.child_set_property(grid, "icon-name", value_data);

        stack_list.add_named(grid_exclude_paths, "exclude-paths");

        list_type.row_activated.connect( ()=> {
            stack_list.set_visible_child_name("exclude-paths");
        });
    }
}



