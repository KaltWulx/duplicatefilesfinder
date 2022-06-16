using Gee;
using GLib;

public class DuplicateFiles.Scanner : GLib.Object {

    private string path;
    private uint64 _count_directories = 0;
    public uint64 _count_files = 0;
    private uint64 _total_size = 0;
    private GLib.ChecksumType hash_type;

    private string _actual_file;
    private uint64 _data_read;
    private string _prepare_file;
    private double _progress = 0.0;
    private bool _flag_prepare_scan;


    public uint64 data_read {
        get { return _data_read; }
    }
    public string actual_file {
        get { return _actual_file; }
    }

    public string prepare_file {
        get { return _prepare_file; }
    }

    public double progress {
        get { return _progress; }
    }

    public bool flag_prepare_scan {
        get { return _flag_prepare_scan; }
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

    private Gee.ArrayList<HardLink> hardlinks;

    public Scanner (string path, ChecksumType hash_type) {
        this.path = path;
        this.hash_type = hash_type;
        map_ocurrences = new HashMap <string, FileOcurrence> ();
        map_ocurrences_clean = new HashMap <string, FileOcurrence> ();
        files = new Gee.ArrayList<string> ();
        hardlinks = new Gee.ArrayList<HardLink>();
    }

    public async void start_scan () {
        cancel_operation = new GLib.Cancellable ();
        new Thread<int> (null, () => {
            try {
                cancel_operation.set_error_if_cancelled ();

                File file_path = File.new_for_path(this.path);
                list_files(file_path);

                _flag_prepare_scan = true;

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
                FileAttribute.STANDARD_ALLOCATED_SIZE,
                FileAttribute.ACCESS_CAN_READ,
                FileAttribute.TIME_MODIFIED,
                FileAttribute.UNIX_NLINK,
                FileAttribute.UNIX_INODE,
                FileAttribute.UNIX_DEVICE,
                FileAttribute.STANDARD_IS_HIDDEN);
    }

    /*
        List a directory recursively and append the regular files not hidden to a list.
        Return a List of string with the absolute path of files.
    */

    private void list_files (GLib.File path) {
        FileEnumerator enumerator = path.enumerate_children(files_attributes (), FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
        FileInfo file_info;

        while((file_info = enumerator.next_file ()) != null) {
        _prepare_file = Path.build_filename(path.get_path (), file_info.get_name ());
            switch(file_info.get_file_type()) {
                case FileType.DIRECTORY:
                    if(Application.scan_hidden_directory () == false) {
                        if(is_hidden_directory(file_info)) {
                            GLib.debug("SALTANDO DIRECTORIO: %s\n", file_info.get_name ());
                            break;
                        }
                        unowned string name = file_info.get_name ();
                        GLib.File location = path.get_child (name);
                        _count_directories++;
                        list_files(location);
                        break;
                    } else {
                        unowned string name = file_info.get_name ();
                        GLib.File location = path.get_child (name);
                        _count_directories++;
                        list_files(location);
                    }
                break;

                case FileType.REGULAR:
                    if(Application.scan_hidden_file () == false) {
                        if(is_hidden_file (file_info)) {
                            break;
                        }

                        uint64 file_size = real_file_size(Path.build_filename(path.get_path (), file_info.get_name ()));

                        if(file_size >= Application.minimum_file_size()) {
                            files.add(Path.build_filename(path.get_path (), file_info.get_name ()));
                            _count_files++;
                            _total_size += file_size;
                            break;
                        }
                    }
                    uint64 file_size = real_file_size(Path.build_filename(path.get_path (), file_info.get_name ()));
                    if(file_size >= Application.minimum_file_size()) {
                        files.add(Path.build_filename(path.get_path (), file_info.get_name ()));
                        _count_files++;
                        _total_size += file_size;
                    }

                break;

                default:
                break;
                }
            }
    }


    private bool is_hidden_file(GLib.FileInfo file_info) {
        GLib.debug("function is_hidden: %s is_hidden?: %s", file_info.get_name (), file_info.get_is_hidden ().to_string ());
        return file_info.get_is_hidden ();
    }

    private bool is_hidden_directory(GLib.FileInfo file_info) {
        return file_info.get_name().get_char(0) == '.';
    }

    private uint64 real_file_size(string file) {
        var f = File.new_for_path(file );
        FileInfo file_info = f.query_info("standard::*", 0);

        uint64 file_size = file_info.get_size ();
        uint64 allocated_size = file_info.get_attribute_uint64 (FileAttribute.STANDARD_ALLOCATED_SIZE);

        if (allocated_size > 0 && allocated_size < file_size) {
            file_size = allocated_size;
        }

        return file_size;
    }

    /*
     Iterate over the files.
    */
    private void check_file_ocurrences() {
        int total = files.size;

        if(total > 0) {
            for(int i = 0; i < total; i++) {
                fill_map(files.get(i));
                _progress = (i + 1) / (double) total;
                GLib.debug("Progress: %f index: %d/%d", _progress, i + 1, total);
                _data_read += real_file_size(files.get(i));
            }
        }
    }

    private bool file_exists (string file) {
        File actual_file = File.new_for_path (file);
	    return actual_file.query_exists ();
    }

    private  void fill_map (string file) {
        _actual_file = file;

        if(file_exists(file)) {
            var key = partial_hash (file);
            if( map_ocurrences.has_key (key) ) {
                var new_ocurrence = map_ocurrences.@get (key);
                new_ocurrence.count = new_ocurrence.count + 1;
                new_ocurrence.paths.add (file);

                map_ocurrences.unset (key, null);
                map_ocurrences.set (key, new_ocurrence);
            } else {
                var mapped_file = new FileOcurrence ();
                mapped_file.paths.add (file);
                mapped_file.count = 1;
                map_ocurrences.@set (key, mapped_file);
            }
        }
    }

    private string partial_hash (string file) {
        var checksum = new Checksum(hash_type);
        unowned string digest_key = "empty";

        try {
            FileStream stream = FileStream.open(file, "rb");
            if(stream == null) {
                GLib.error("El archivo %s es nulo al leerlo", file);
            } else {

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

                digest_key = checksum.get_string ();
            }

        } catch(GLib.Error error ) {
            GLib.error(error.message);
        }

        return digest_key;
    }

    private string complete_hash (string file) {

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


public class DuplicateFiles.HardLink {
    internal uint64 inode;
    internal uint32 device;

    public HardLink(GLib.FileInfo info) {
        this.inode = info.get_attribute_uint64(FileAttribute.UNIX_INODE);
        this.device = info.get_attribute_uint32(FileAttribute.UNIX_DEVICE);
    }
    public uint hash () {
                return direct_hash ((void*) this.inode) ^ direct_hash ((void*) this.device);
            }

            public bool equal (HardLink other) {
                return this.inode == other.inode && this.device == other.device;
            }



}
