
import std.process;
import std.stdio;
import std.string;
import dyaml;


struct CacheRec {
  string cmd;
  string[] stdout;
  string[] stderr;
  int rc;
}

CacheRec *get_cache_entry(string cmd) {
  return null;
}

void load_cache(string file_name) {
  writeln("loading cache from: " ~ file_name);

  // Read the input.
  Node root = Loader.fromFile(file_name).load();

  // Display the data read.
  foreach(string word; root["Hello World"]) {
    writeln(word);
  }

  writeln("The answer is ", root["Answer"].as!int);

  // Dump the loaded document to output.yaml.
  // dumper(File("output.yaml", "w").lockingTextWriter).dump(root);
}

void save_cache(string file_name) {
  writeln("saving cache to: " ~ file_name);
}

void set_cached(string cmdstr, CacheRec result) {
}


int exec_cmd(string cmd) {
  auto result = executeShell(cmd);
  writeln(result.output);

  return result.status;
}

CacheRec exec_cmd_pipes(string cmd) {
  CacheRec result;

  result.cmd = cmd;

  // my_application writes to stdout and might write to stderr
  auto pipes = pipeShell(cmd, Redirect.stdout | Redirect.stderr);
  // scope(exit) wait(pipes.pid);

  // Store lines of output.
  foreach (line; pipes.stdout.byLine) {
    result.stdout ~= line.idup;
    writeln("stdout: " ~ line.idup);
  }

  // Store lines of errors.
  foreach (line; pipes.stderr.byLine) {
   result.stderr ~= line.idup;
   writeln("stderr: " ~ line.idup);
  }

  result.rc = wait(pipes.pid);

  return result;
}


int main(string[] args) {
  auto cache_file = "~/.cch.cache";
  writeln("cache file name is: " ~ cache_file);

  load_cache(cache_file);

  // just execute the arguments as a command
  auto cmdstr = args[1..$].join(" ");

  auto cached = get_cache_entry(cmdstr);

  if (cached == null) {
    auto result = exec_cmd_pipes(cmdstr);
    set_cached(cmdstr, result);
    save_cache(cache_file);

    return result.rc;
  }
  else {
    foreach(line; cached.stdout) {
      writeln("stdout: " ~ line);
    }
    foreach(line; cached.stderr) {
      writeln("stderr: " ~ line);
    }
    return cached.rc;
  }
}

