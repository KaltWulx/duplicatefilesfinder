using Granite;

public class DuplicateFiles.Application : Gtk.Application {

    private Welcome welcome;
    private Gtk.ApplicationWindow window;
    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Gtk.HeaderBar bar;
    public static Gtk.CssProvider css_provider;
    public static GLib.Settings settings;

    public Application() {
        application_id = "com.github.KaltWulx.duplicatefiles";
        flags |= GLib.ApplicationFlags.HANDLES_OPEN;
        settings = new GLib.Settings("com.github.KaltWulx.duplicatefiles");
    }

    protected override void activate() {


        window = new Gtk.ApplicationWindow (this);
		window.window_position = Gtk.WindowPosition.CENTER;
		window.destroy.connect (Gtk.main_quit);

		window.set_size_request(800,550);
		window.get_style_context() .add_class (Granite.STYLE_CLASS_ROUNDED);

		bar = new Gtk.HeaderBar ();
		bar.show_close_button = true;
		bar.set_title ("Duplicate Files Finder");
		window.set_titlebar (bar);

        btn_back = new Gtk.Button.with_label("Welcome window");
        btn_back.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        bar.pack_start(btn_back);
        btn_back.no_show_all = true;

        Preferences preferences = new Preferences(window);

        var btn_config = new Gtk.Button.from_icon_name("preferences-system-symbolic", Gtk.IconSize.BUTTON);
        btn_config.set_tooltip_text("Preferences dialog");
        bar.pack_end(btn_config);

        btn_config.clicked.connect( ()=> {
            preferences.show_all();
        });


        stack = new Gtk.Stack() {
		    transition_type = Gtk.StackTransitionType.CROSSFADE
		};
		stack.set_vexpand(true);
        stack.set_hexpand(false);

		window.add(stack);

		welcome = new Welcome(stack, btn_back);
		welcome.create_ui ();

        window.show_all ();
        window.present();


        Granite.Services.Application.set_progress_visible.begin (true);
		Granite.Services.Application.set_progress.begin (0.2f);
    }

     public override void startup () {
        base.startup ();
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        });

        css_provider = new Gtk.CssProvider ();
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
    }

    public override void quit_mainloop() {
        GLib.debug ("Quitting mainloop\n");
        base.quit_mainloop();
    }


    public static bool scan_hidden_file() {
        return Application.settings.get_boolean("hidden-file");
    }

    public static void set_scan_hidden_file(bool scan_file) {
        Application.settings.set_boolean("hidden-file", scan_file);
    }

    public static bool scan_hidden_directory() {
        return Application.settings.get_boolean("hidden-directory");
    }


    public static void set_scan_hidden_directory(bool scan_directory) {
        Application.settings.set_boolean("hidden-directory", scan_directory);
    }

    public static int minimum_file_size() {
        int setting = Application.settings.get_int("minimum-file-size");
        //1Kb 5Kb 1Mb 5Mb
        switch(setting) {
            case 1:
                return 1024;
            break;

            case 2:
                return 5 * 1024;
            break;

            case 3:
                return 1 * 1024 * 1024;

            break;

            case 4:
                return 5 * 1024 * 1024;
            break;

            default:
                return 1024;
            break;
        }
    }
}

public static int main(string []args) {
    var app = new DuplicateFiles.Application();
    return app.run(args);
}	
