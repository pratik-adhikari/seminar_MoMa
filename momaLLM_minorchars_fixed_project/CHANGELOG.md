## Minor text cleanup (requested)

- Fixed a broken in-text string in Appendix A.20 where a `\verifycite{...}` call was accidentally rendered as plain text
  (`erifyciteHonerkamp20241Abstract, para 1MoMa-LLM, ...`). Rewrote the sentence cleanly and re-attached a proper `\verifycite`.
- Replaced literal command mentions like `\verifycite` in Appendix F (“citation audit checklist”) with plain wording (“verification box”).
- Prevented ugly intra-word hyphenation in the subsection title “mobile manipulation” by forcing a line break (`mobile\\manipulation`)
  while keeping the TOC entry unchanged.
- Updated `\verifycite` to print a clean numeric citation **without duplicating the page number**
  (citation is `[n]`, the yellow box carries page/paragraph/snippet).
