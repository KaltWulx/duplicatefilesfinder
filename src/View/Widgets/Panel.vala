public class DuplicateFiles.Panel: Gtk.Grid {
    public Gtk.ListBox list_box;
    private Categories categories;
    private CategorySizeSum size_sum;
    private CategoryListRow row_all;
    private CategoryListRow row_apps;
    private CategoryListRow row_audio;
    private CategoryListRow row_document;
    private CategoryListRow row_image;
    private CategoryListRow row_video;

	public Panel (Categories categories, CategorySizeSum size_sum) {
		orientation = Gtk.Orientation.HORIZONTAL;
		this.categories = categories;
		this.size_sum = size_sum;

		list_box = new Gtk.ListBox() {
		    vexpand = true,
		    activate_on_single_click = true,
            selection_mode = Gtk.SelectionMode.SINGLE
		};

        add(list_box);
        create_ui ();
	}

    public void update_ui() {

        var total_size_sum = size_sum.application + size_sum.audio + size_sum.document + size_sum.image + size_sum.video;
        row_all.lb_len_data.set_markup ("<small><b>"+GLib.format_size(total_size_sum)+"</b></small>");

		if(categories.application) {
			row_apps.lb_len_data.set_markup ("<small><b>"+GLib.format_size(size_sum.application)+"</b></small>");
	    } else {
		    list_box.remove(row_apps);
	    }

        if(categories.audio) {
        	row_audio.lb_len_data.set_markup ("<small><b>"+GLib.format_size(size_sum.audio)+"</b></small>");
	    } else {
            list_box.remove(row_audio);
	    }

	    if(categories.document) {
	        row_document.lb_len_data.set_markup ("<small><b>"+GLib.format_size(size_sum.document)+"</b></small>");
	    } else {
            list_box.remove(row_document);
	    }

	    if(categories.image) {
	        row_image.lb_len_data.set_markup ("<small><b>"+GLib.format_size(size_sum.image)+"</b></small>");
	    } else {
            list_box.remove(row_image);
	    }

	    if(categories.video) {
	        row_video.lb_len_data.set_markup ("<small><b>"+GLib.format_size(size_sum.video)+"</b></small>");
	    } else {
           list_box.remove(row_video);
	    }
    }

	public void create_ui () {
        row_all = new DuplicateFiles.CategoryListRow ("application-octet-stream", "All Duplicates", "...");
        row_apps = new CategoryListRow ("application-x-desktop", "Applications", "...");
        row_audio = new CategoryListRow ("audio-x-generic", "Audio", "...");
        row_document = new CategoryListRow ("text-x-generic", "Documents", "...");
        row_image = new CategoryListRow ("image-x-generic", "Images", "...");
        row_video = new CategoryListRow ("folder-videos", "Video", "...");

        list_box.add(row_all);
        list_box.add(row_apps);
        list_box.add(row_audio);
        list_box.add(row_document);
        list_box.add(row_image);
        list_box.add(row_video);
	}
}
