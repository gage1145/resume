# Legacy LaTeX source

`resume.tex` here is the original hand-written LaTeX resume, frozen at the point the project was
converted to Quarto. It is kept for reference only and is **not** part of the build.

The live source is `../resume.qmd`; run `quarto render` from the repository root.

To compile this file directly, copy the class next to it first — `\documentclass{resume}` resolves
from the current directory:

```sh
cp ../resume.cls .
pdflatex resume.tex
```
