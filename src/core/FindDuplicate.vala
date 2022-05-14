public class DuplicateFiles.DuplicateFile : Object {

    public DuplicateFile() {

    }

    public static Gee.ArrayList<string> simpleFind(Gee.ArrayList<string> files) {
        Gee.ArrayList<string> clean_list = prepare_list();
    }


    //Would be nice have a config param for this part, like size, extension, type, etc...
    //For now, only get a list of file with
    private void prepare_list() {
        foreach(file in files) {
            File f = File.new_for_path(file);

        }
    }

    private double size() {
        uint64 file_size = file_info.get_size ();
        uint64 allocated_size = file_info.get_attribute_uint64 (FileAttribute.STANDARD_ALLOCATED_SIZE);

        if (allocated_size > 0 && allocated_size < file_size) {
            file_size = allocated_size;
        }

    }
}
