public class DuplicateFiles.Welcome : Gtk.Grid {


    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Gtk.HeaderBar bar;
    private Granite.Widgets.Welcome welcome;

    private PrepareHomeScan prepare_home_scan;
    private StartHomeScan start_home_scan;
    private Resume resume;


    public Welcome (Gtk.Stack stack, Gtk.Button btn_back) {
        this.stack = stack;
        this.btn_back = btn_back;
    }


    public void create_ui () {

	    welcome = new Granite.Widgets.Welcome ("Duplicate Files Finder", "Choose a option.");
        welcome.append ("user-home", "Scan home folder", "The easy option for start a cleaning.");
        welcome.append ("folder-open", "Scan a custom folder", "Search dupes of a selected folder.");
        welcome.append ("text-x-generic", "Single file", "Scan for a dupes of a single file.");


        stack.add_named(welcome, "main");


        var box_view_home = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
            name = "prepare-home-scan",
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        var box_view_scan = new Gtk.Grid(){
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };
        box_view_scan.hexpand = false;
        box_view_scan.name = "start-home-scan";

        /*
        var box_view_scan = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
            name = "start-home-scan",
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER,
            expand = false
        };
        */

        var box_view_resume = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0) {
            name = "resume",
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        create_view_objects();
        load_views_in_background.begin();

        box_view_scan.attach(start_home_scan, 0, 0, 1, 1);
        box_view_home.set_center_widget(prepare_home_scan);
        box_view_resume.set_center_widget(resume);


        stack.add_named(box_view_home, box_view_home.name);
        stack.add_named(box_view_scan, box_view_scan.name);
        stack.add_named(box_view_resume, box_view_resume.name);


        btn_back.clicked.connect(btn_back_action);

        welcome.activated.connect ((index) => {
            switch (index) {

                case 0:
                    try {
                        scan_home();
                    } catch (Error e) {
                        warning (e.message);
                    }
                    break;

                case 1:
                    try {
                       scan_custom_folder();
                    } catch (Error e) {
                        warning (e.message);
                    }
                    break;

                case 2:
                    try {
                       scan_file();
                    } catch(Error e) {
                        warning(e.message);
                    }
                    break;
            }
        });
        stack.set_visible_child_name("main");
        show_all();
	}

	private void create_view_objects() {
	    resume = new Resume(stack, btn_back);
        start_home_scan = new StartHomeScan (stack, btn_back, resume);
        prepare_home_scan = new PrepareHomeScan (stack, btn_back, start_home_scan);
    }

    private async void load_views_in_background() {
        GLib.debug("Build widgets in background....\n");

        prepare_home_scan.create_ui ();
        GLib.debug("Prepare Home Scan created...\n");
        resume.create_ui ();

        GLib.debug("Resume created...\n");
        start_home_scan.create_ui ();

        GLib.debug("Start Home Scan created...\n");
        GLib.debug("Widgets are now created.\n");
    }

	private void scan_home() {
	    stdout.printf("You select 0\n");
        stack.set_visible_child_name("prepare-home-scan");
        stdout.printf("SCAN HOME - Child-visible: %s\n", stack.get_visible_child().name);
        btn_back.no_show_all = false;
        btn_back.show_all();
	}

    private void scan_custom_folder() {
        stdout.printf("You selected  1\n");
        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
		    "Select your favorite file", null, Gtk.FileChooserAction.SELECT_FOLDER,
		    "_Cancelar",
		    Gtk.ResponseType.CANCEL,
		    "_Seleccionar",
		    Gtk.ResponseType.ACCEPT);

        if(chooser.run() == Gtk.ResponseType.ACCEPT) {
            SList<string> uris = chooser.get_uris ();
		    print ("Selection:\n");

		    foreach (unowned string uri in uris) {
		        print (" %s\n", uri);
	        }
        }
        chooser.close ();
    }

    private void scan_file() {
        Gtk.FileChooserDialog chooser = new Gtk.FileChooserDialog (
		    "Select your favorite file", null, Gtk.FileChooserAction.OPEN,
		    "_Cancelar",
		    Gtk.ResponseType.CANCEL,
		    "_Seleccionar",
		    Gtk.ResponseType.ACCEPT);

        chooser.select_multiple = false;

        if(chooser.run() == Gtk.ResponseType.ACCEPT) {

            SList<string> uris = chooser.get_uris ();
			stdout.printf("File selected:\n");

			foreach (unowned string uri in uris) {
			    stdout.printf ("%s\n", uri);
			}
        }

        chooser.close ();
    }

    private void btn_back_action() {
        var widget = stack.get_visible_child();
        stdout.printf("The widget that was visible : %s\n", widget.name);

        if(widget.name == "start-home-scan") {
            btn_back.set_label("Welcome window");
            stack.set_visible_child_name("prepare-home-scan");
        } else {
            stack.set_visible_child_name("main");
            btn_back.visible = false;
        }
    }
}


