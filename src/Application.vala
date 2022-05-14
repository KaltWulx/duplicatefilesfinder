using Granite;

public class DuplicateFiles.Application : Gtk.Application {

    private Welcome welcome;

    private Gtk.ApplicationWindow window;
    private Gtk.Stack stack;
    private Gtk.Button btn_back;
    private Gtk.HeaderBar bar;
    public static Gtk.CssProvider css_provider;

    public Application() {

        application_id = "com.github.KaltWulx.duplicatefiles";
        flags |= GLib.ApplicationFlags.HANDLES_OPEN;
    }

    protected override void activate() {

        window = new Gtk.ApplicationWindow (this);
		window.window_position = Gtk.WindowPosition.CENTER;
		window.destroy.connect (Gtk.main_quit);
		//window.set_default_size (700, 450);
		window.set_size_request(800,550);
		//window.expand = false;
        //window.resizable = false;
        //window.set_preferred_size(700, 400);
		window.get_style_context() .add_class (Granite.STYLE_CLASS_ROUNDED);

		bar = new Gtk.HeaderBar ();
		bar.show_close_button = true;
		bar.set_title ("Duplicate Files Finder");

		window.set_titlebar (bar);

        btn_back = new Gtk.Button.with_label("Welcome window");
        btn_back.get_style_context ().add_class (Granite.STYLE_CLASS_BACK_BUTTON);
        bar.pack_start(btn_back);
        btn_back.no_show_all = true;

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

}

public static int main(string []args) {
    var app = new DuplicateFiles.Application();
    return app.run(args);
}	
