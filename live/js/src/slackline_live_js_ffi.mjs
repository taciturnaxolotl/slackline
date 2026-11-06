import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { Ok, Error, toList } from "./gleam.mjs";

export function read_state(name) {
  try {
    return new Ok(
      readFileSync(`${homedir()}/.local/state/slackline-live/${name}`, "utf8"),
    );
  } catch {
    return new Error(undefined);
  }
}

export function argv() {
  return toList(process.argv.slice(2));
}
