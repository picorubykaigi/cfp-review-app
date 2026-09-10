// lex_prism.js をこのアプリに繋ぐ。ここだけがブラウザと ReviewApp を知っている。
//
// @bjorn3/browser_wasi_shim v0.4.2 (MIT)
// Source: https://github.com/bjorn3/browser_wasi_shim
import { WASI } from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.4.2/dist/index.js";
import { createPrismLexer } from "./lex_prism.js";

// WASI をまだ持たないブラウザがあるので、prism.wasm が要求する
// wasi_snapshot_preview1 は shim で埋める。
window.lexPrism = await createPrismLexer({ wasi: new WASI([], [], []) });
window.prismReady = true;

window.dispatchEvent(new Event("prism-ready"));
