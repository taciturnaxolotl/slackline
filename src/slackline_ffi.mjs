import { Ok, Error as GError, BitArray } from "./gleam.mjs";

export function erlang_only() {
  throw new Error("slackline/httpc and slackline/stream/httpc only work on the Erlang target, use slackline/fetch or slackline/stream/fetch instead");
}

export async function gunzip(data) {
  try {
    const stream = new Blob([data.rawBuffer])
      .stream()
      .pipeThrough(new DecompressionStream("gzip"));
    const buffer = await new Response(stream).arrayBuffer();
    return new Ok(new BitArray(new Uint8Array(buffer)));
  } catch {
    return new GError(undefined);
  }
}

export function now_seconds() {
  return Math.floor(Date.now() / 1000);
}

export function now_ms() {
  return Math.floor(performance.now());
}

export function set_timeout(milliseconds, callback) {
  setTimeout(() => callback(), milliseconds);
}

export function new_cell(value) {
  return { value };
}

export function cell_get(cell) {
  return cell.value;
}

export function cell_set(cell, value) {
  cell.value = value;
}
