using Gee;
using GLib;
public class DuplicateFiles.FileOcurrence {

        public int count;
        public Gee.ArrayList <string> paths;

        public FileOcurrence () {
            count = 0;
            paths = new Gee.ArrayList<string> ();
        }
    }
