export function erlang_only() {
  throw new Error("slackline/httpc only works on the Erlang target, use slackline/fetch instead");
}

export function now_seconds() {
  return Math.floor(Date.now() / 1000);
}
