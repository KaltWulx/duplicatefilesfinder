using Gee;
using GLib;

public class DuplicateFiles.Scanner : GLib.Object {

    private string path;
    private uint64 _count_directories = 0;
    public uint64 _count_files = 0;
    private uint64 _total_size = 0;
    private GLib.ChecksumType hash_type;

    private string _actual_file;
    private double _progress = 0.0;

    public string actual_file {
        get { return _actual_file; }
    }

    public double progress {
        get { return _progress; }
    }

    public uint64 count_directories {
        get { return _count_directories; }
    }

    public uint64 count_files {
        get { return _count_files; }
    }

    public uint64 total_size {
        get { return _total_size; }
    }

    public HashMap <string, FileOcurrence ?> map_ocurrences;
    public HashMap <string, FileOcurrence ?> map_ocurrences_clean;

    private Gee.ArrayList<string> files;
    public GLib.Cancellable cancel_operation;

    public Scanner (string path, ChecksumType hash_type) {
        this.path = path;
        this.hash_type = hash_type;
        map_ocurrences = new HashMap <string, FileOcurrence> ();
        map_ocurrences_clean = new HashMap <string, FileOcurrence> ();
        files = new Gee.ArrayList<string> ();
    }

    public async void start_scan () {

        cancel_operation = new GLib.Cancellable ();
        new Thread<int> (null, () => {
            try {
                cancel_operation.set_error_if_cancelled ();
                File file_path = File.new_for_path(path);

                list_files(file_path);
                check_file_ocurrences();

                start_scan.callback();
                return 0;
            } catch (GLib.Error e) {
                GLib.warning (e.message);
                return -1;
            }
        });
        yield;
    }

    public void clean_map () {
        foreach(var entry in this.map_ocurrences.entries) {
            if(entry.value.count > 1) {
                this.map_ocurrences_clean.set(entry.key, entry.value);
            }
        }
        map_ocurrences.clear();
    }

    private string files_attributes () {
        return string.join (",",
                FileAttribute.STANDARD_NAME,
                FileAttribute.STANDARD_TYPE,
                FileAttribute.STANDARD_SIZE,
                FileAttribute.STANDARD_ALLOCATED_SIZE);
    }

    /*
        Return true if the file is a directory and is not hidden.
        Otherwise return false;
    */
    private bool file_validation (FileInfo file_info, GLib.File path) {
        var file_to_path = Path.build_filename (
                        path.get_path (),
                        file_info.get_name ());
        return
            FileUtils.test (file_to_path, FileTest.IS_DIR)
            &&
            (file_info.get_name ().get_char ().to_string () == ".") == false;
    }

    private bool is_regular (FileInfo file) {
        return file.get_file_type () == FileType.REGULAR;
    }


    /*
        List a directory recursively and append the regular files not hidden to a list.
        Return a List of string with the absolute path of files.
    */
    private void list_files (GLib.File path) {
        try {
                FileEnumerator enumerator = path.enumerate_children(files_attributes (), FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                FileInfo file_info;

                while((file_info = enumerator.next_file ()) != null) {

                    if(file_validation (file_info, path)) {
                            unowned string name = file_info.get_name ();
                            GLib.File location = path.get_child (name);
                            _count_directories++;
                            list_files(location);

                    } else if (is_regular(file_info)) {
                        files.add(Path.build_filename(path.get_path (), file_info.get_name ()));
                        _count_files++;

                        uint64 file_size = file_info.get_size ();
                        uint64 allocated_size = file_info.get_attribute_uint64 (FileAttribute.STANDARD_ALLOCATED_SIZE);

                        if (allocated_size > 0 && allocated_size < file_size) {
                            file_size = allocated_size;
                        }
                        _total_size += file_size;
                    }
                }
            } catch(Error e) {
                GLib.debug("¡Error!: %s\n", e.message);
            }
    }

    /*
     Iterate over the files.
    */
    private void check_file_ocurrences() {
        int total = files.size;

        if(total > 0) {
            foreach(string file in files) {
                fill_map(file);
                _progress = (files.index_of(file) + 1) / (double) total;
            }
        }
    }

    private  void fill_map (string file) {
        _actual_file = file;
        var key = partial_hash(file);

        if( map_ocurrences.has_key (key) ) {
            var new_ocurrence = map_ocurrences.get (key);
            new_ocurrence.count = new_ocurrence.count + 1;
            new_ocurrence.paths.add (file);

            map_ocurrences.unset (key, null);
            map_ocurrences.set (key, new_ocurrence);
        } else {
            var mapped_file = new FileOcurrence ();
            mapped_file.paths.add (file);
            mapped_file.count = 1;
            map_ocurrences.set (key, mapped_file);
        }
    }

    private string partial_hash (string file) {
        var checksum = new Checksum(hash_type);
        FileStream stream = FileStream.open(file, "rb");

        assert(stream != null);

        uint8[] buffer = new uint8[1024];

        stream.seek(0, GLib.FileSeek.END);
        long size = stream.tell();
        stream.rewind();
        size_t data;

        stream.seek( (long) Math.floor(size * 20 /100) , GLib.FileSeek.CUR);
        data = stream.read(buffer);
        checksum.update(buffer, data);

        stream.seek( (long) Math.floor(size * 55 /100) , GLib.FileSeek.CUR);
        data = stream.read(buffer);
        checksum.update(buffer, data);

        stream.seek ((long) Math.floor(size * 85 / 100), GLib.FileSeek.CUR);
        data = stream.read(buffer);
        checksum.update(buffer, data);

        unowned string digest_key = checksum.get_string ();
        return digest_key;
    }

    private string calculate_hash (string file) {

        var checksum = new Checksum ( this.hash_type);

        FileStream stream = FileStream.open ( file, "rb");
        assert(stream != null);

        uint8 buffer[8192]; //8 MegaBytes
        size_t data;

        while( (data = stream.read (buffer)) > 0) {
                checksum.update(buffer, data);
        }
        unowned string digest_key = checksum.get_string ();
        return digest_key;
    }
}
