
import std.process;
import std.stdio;
import std.string;


int exec_cmd(string cmd) {
  auto result = executeShell(cmd);
  writeln(result.output);

  return result.status;
}


int main(string[] args) {
  // just execute the arguments as a command
  auto cmdstr = args[1..$].join(" ");

  auto status = exec_cmd(cmdstr);

  return status;
}

