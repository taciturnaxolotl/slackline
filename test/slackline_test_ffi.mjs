import { toList } from "./gleam.mjs";

// A log so tests can see which continuations ran.
const log = [];

export function record(entry) {
  log.push(entry);
}

export function recorded() {
  return toList(log);
}

export function new_log() {
  return { entries: [] };
}

export function push(log, entry) {
  log.entries.push(entry);
}

export function entries(log) {
  return toList(log.entries);
}
