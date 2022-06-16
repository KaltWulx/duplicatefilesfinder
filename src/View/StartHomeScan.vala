using GLib;

public class DuplicateFiles.StartHomeScan: Gtk.Grid {

    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Gtk.ProgressBar progress_bar;
    private uint source;
    private Gtk.Label lb_file;
    private Gtk.Label lb_count;
    private Gtk.Button btn_start_scan;
    private Gtk.Label lb_title;
    private Gtk.Label lb_subtitle;


    private Scanner scanner;
    private Resume resume;

    public StartHomeScan (Gtk.Stack stack, Gtk.Button btn_back, Resume resume) {
        this.resume = resume;
        this.stack = stack;
        this.btn_back = btn_back;

        GLib.ChecksumType type = 0;
        if(Application.settings.get_int("checksum-type") == 0) {
            type = GLib.ChecksumType.MD5;
        }
        if(Application.settings.get_int("checksum-type") == 1) {
            type = GLib.ChecksumType.SHA1;
        }

        scanner = new Scanner("/home/kaltwulx/Descargas", type);
    }


//home/kaltwulx/.local/share/gvfs-metadata/home-0a45b383.log

    public void create_ui () {

        btn_start_scan = new Gtk.Button.with_label("Start scan");

        progress_bar = new Gtk.ProgressBar ();

        lb_title = new Gtk.Label ("Press start button");
        lb_title.get_style_context ().add_class(Granite.STYLE_CLASS_H2_LABEL);

        lb_subtitle = new Gtk.Label ("");
        lb_subtitle.get_style_context ().add_class (Granite.STYLE_CLASS_H4_LABEL);

        lb_file = new Gtk.Label (" ");

        lb_file.set_ellipsize (Pango.EllipsizeMode.MIDDLE);
        lb_file.width_chars = 50;
        lb_file.max_width_chars = 1;
        lb_count = new Gtk.Label (" ");

        var btn_cancel = new Gtk.Button.with_label ("Stop");

        var icon = new Gtk.Image () {
            gicon = new ThemedIcon ("user-home"),
            pixel_size = 128
        };

        var hbox_lb_title = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.START,
        };

        var hbox_btn_cancel = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.START,
        };

        var hbox_lb_subtitle = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            halign = Gtk.Align.START,
        };

        hbox_lb_subtitle.add(lb_subtitle);

        var hbox_count_cancel = new Gtk.Box (Gtk.Orientation.HORIZONTAL,  5) {
            halign = Gtk.Align.START,
            valign = Gtk.Align.BASELINE
        };

        hbox_lb_title.add (lb_title);

        var main_hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20){
            halign = Gtk.Align.CENTER,
            valign = Gtk.Align.CENTER
        };

        hbox_btn_cancel.pack_start (btn_start_scan, false, false, 0);
        hbox_btn_cancel.pack_start (btn_cancel, false, false, 10);
        hbox_count_cancel.pack_start (hbox_btn_cancel, false, false, 0);
        hbox_count_cancel.pack_end (lb_count, false, false, 5);

        var grid_aux = new Gtk.Grid();
        grid_aux.expand = false;
        grid_aux.hexpand = false;
        grid_aux.attach(hbox_lb_title, 0,0,1,1);
        grid_aux.attach(hbox_lb_subtitle, 0,1,1,1);
        grid_aux.attach(lb_file, 0,2,1,1);
        grid_aux.attach(progress_bar, 0,3,1,1);
        grid_aux.attach(hbox_count_cancel, 0,4,1,1);

        main_hbox.pack_start(icon, false, false, 0);
        main_hbox.pack_start(grid_aux, false, false, 0);

        add (main_hbox);
        show_all();

        progress_bar.set_text ("");
        progress_bar.set_show_text (false);
        progress_bar.visible = false;

        btn_start_scan.clicked.connect( ()=> {
            scanner.start_scan.begin();
            GLib.Idle.add( () => {
                lb_title.label = "Scan in progress";
                lb_subtitle.label = "Preparing files for scan...";
                lb_file.label = scanner.prepare_file;
                string data = "Directories: " + scanner.count_directories.to_string () +
                " Files: " + scanner.count_files.to_string () +
                " Total size: " + GLib.format_size(scanner.total_size);

                lb_count.label = data;

                if(scanner.flag_prepare_scan) {
                    lb_subtitle.label = "Scanning files...";
                    progress_bar.visible = true;
                    double progress = scanner.progress;

                    progress_bar.set_fraction (progress);

                    string data_read = "Reading "+ GLib.format_size(scanner.data_read);
                    lb_count.label  = data_read;
                    lb_file.label = scanner.actual_file;
                    return progress_bar.fraction < 1.0;
                }

                return true;
            });
        });

        btn_cancel.clicked.connect ( () => {
            scanner.cancel_operation.cancel ();
            progress_bar.set_fraction (0.0);
            progress_bar.set_show_text (true);
            progress_bar.set_text ("Canceled");
        });

        progress_bar.notify.connect( () =>{

            if(progress_bar.fraction >= 1.0) {
                stack.set_visible_child_name("resume");

                scanner.clean_map();

                resume.set_data(scanner);
                resume.disable_ui ();

                resume.fill_resume.begin( (obj, res) => {
                    var result = resume.fill_resume.end(res);
                    if(result) {
                        resume.fill_panel_categories.begin( (obj, res) => {
                            var end = resume.fill_panel_categories.end(res);
                            if(end) {
                                resume.hide_info_bar();
                            }
                        });
                    }
                });

                //progress_bar.fraction = 0.0;
            }
        });
    }
}



/*

*/
