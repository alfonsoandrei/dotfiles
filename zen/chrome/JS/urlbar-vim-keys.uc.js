// ==UserScript==
// @name           urlbar-vim-keys
// @description    Ctrl+J and Ctrl+K move the selection in the address bar dropdown
// ==/UserScript==

window.addEventListener(
  "keydown",
  (event) => {
    if (event.target !== gURLBar.inputField || !gURLBar.view.isOpen) return;
    if (!event.ctrlKey || event.metaKey || event.altKey || event.shiftKey || event.isComposing) return;

    const reverse = { j: false, k: true }[event.key];
    if (reverse === undefined) return;

    event.preventDefault();
    event.stopPropagation();
    gURLBar.view.selectBy(1, { reverse });
  },
  true,
);
