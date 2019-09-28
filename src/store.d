
import dyaml: Node;
import std.process;
import std.stdio;
import std.string;
import std.conv;
import std.traits;


struct CacheRec {
  string stdout_lines;
  string stderr_lines;
  int rc;

  const int opCmp(ref const CacheRec c) {
    if (stdout_lines != c.stdout_lines)  { return -1; }
    if (stderr_lines != c.stderr_lines) { return -1; }
    if (rc  != c.rc) { return rc  - c.rc; }

    return 0;
  }

  this(string stdout_lines, string stderr_lines, int rc) {
    this.stdout_lines = stdout_lines;
    this.stderr_lines = stderr_lines;
    this.rc = rc;
  }

  this(const Node node, string tag) @safe {
    if (tag == "!cache-rec") {
      stdout_lines = node["stdout"].as!string;
      stderr_lines = node["stderr"].as!string;
      rc = node["rc"].as!int;
    }
  }
}


CacheRec[string] records;

import dyaml;

CacheRec[string] load_cache(string file_name) {
  CacheRec[string] recs;

  import dyaml: Loader, Node, YAMLException;
  import dyaml.constructor;

  writeln("loading cache from: " ~ file_name);

  try {
    auto root = Loader.fromFile(file_name).load();

    // the root is a mapping
    foreach (pair; root.mapping) {
      auto cmd = pair.key.as!string;
 
      writeln("loaded command: " ~ cmd);
      recs[cmd] = pair.value.as!CacheRec;
    }
  }
  catch(YAMLException e) {
    writeln(e.msg);
  }

  return recs;
}
unittest {
  auto recs = load_cache("/tmp/test.yaml");
  assert(recs.length == 2);
}


void save_cache(string file_name, CacheRec[] recs) {
  import dyaml : dumper, Node, YAMLException;

  writeln("saving cache to: " ~ file_name);
  // auto root = Node(recs);
  auto root = Node([1,2,3,4]);

  try {
    //dumper.dump(File(file_name, "w").lockingTextWriter, recs);
    dumper.dump!char(File(file_name, "w").lockingTextWriter, root);
    writeln("cache saved");
  }
  catch(YAMLException e) {
    writeln(e.msg);
  }
}
unittest {
  CacheRec[string] recs;
  auto rec = CacheRec("this is stdout", "this is stderr", 99 );
  // recs["a_cmd"] = rec;

  // save_cache("/tmp/test_cache.yaml", recs);
}


