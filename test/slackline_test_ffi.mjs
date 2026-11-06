import { toList } from "./gleam.mjs";

// A log so tests can see which continuations ran.
const log = [];

export function record(entry) {
  log.push(entry);
}

export function recorded() {
  return toList(log);
}
