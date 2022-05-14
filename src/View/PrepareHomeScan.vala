public class DuplicateFiles.PrepareHomeScan : Gtk.Grid {

    public Gtk.Stack stack;
    public Gtk.Button btn_back;
    private StartHomeScan scan_window;
    private string view_name;

    public PrepareHomeScan( Gtk.Stack stack,
                             Gtk.Button btn_back,
                             StartHomeScan scan_window) {

        this.stack = stack;
        this.btn_back = btn_back;
        this.scan_window = scan_window;
    }

    public void create_ui () {

        var btn_show_scan_window = new Gtk.Button.with_label ("Scan for duplicates");

        var lb_title = new Gtk.Label ("Ready to Scan");
        lb_title.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);

        var lb_subtitle = new Gtk.Label ("Press the button for find all duplicates.");
        lb_subtitle.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        var icon = new Gtk.Image () {
            gicon = new ThemedIcon ("user-home"),
            pixel_size = 128
        };

        var main_hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20) {
            margin = 20,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        var main_vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0) {
            margin = 5,
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        var grid = new Gtk.Grid () {
            margin_top = 15
        };

        var hbox_lb_title = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.START
        };

        hbox_lb_title.add (lb_title);

        main_vbox.add (hbox_lb_title);
        main_vbox.add (lb_subtitle);
        grid.add (btn_show_scan_window);
        main_vbox.add (grid);

        main_hbox.add (icon);
        main_hbox.add (main_vbox);

        add(main_hbox);
        show_all();

        btn_show_scan_window.clicked.connect( ()=> {
            stack.set_visible_child_name("start-home-scan");
            btn_back.set_label("Prepare Scan");
            scan_window.launch_scan();
        });
    }
}
