# nvim-config

LazyVim configuration tuned for academic philosophy writing on Omarchy.

## Requires

- `pandoc`, TeX (`lualatex`), Zotero + Better BibTeX
- `sioyek` launcher on PATH (`academic-bootstrap --sioyek`)
- Vault at `~/Vault/Philosophy` (see that README)

## Manuscript keys

| Key | Action |
|-----|--------|
| `<leader>mp` | Compile PDF via vault Makefile |
| `<leader>md` | Compile DOCX |
| `<leader>mo` | Open PDF in Sioyek |
| `<leader>mi` | Open Sioyek capture inbox |
| `<leader>ci` | Insert `[@citekey]` from `references.bib` |
| `<leader>mf` | Insert discursive footnote `^[]` |
| `<leader>ml` | Live preview (inlyne, optional) |

Portable setup docs: `~/dotfiles/academic/README.md`.
