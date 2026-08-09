# Gage Rowden's Resume

Welcome to my resume repository! Here, you'll find my up-to-date professional resume, authored in [Quarto](https://quarto.org) and typeset with a custom $\LaTeX$ class.

---

## About Me
I am the Lead Technical R&D Scientist at Priogen Corporation and a Researcher IV at the Minnesota Center for Prion Research & Outreach at the University of Minnesota. My background is in biotechnology, molecular biology, prion biology, and data analysis. I have contributed to numerous scientific publications, developed open-source software for data analysis, and implemented efficient laboratory workflows.

---

## Resume Details
- **Format:** Quarto source, rendered to PDF and HTML
- **Last Updated:** 3/14/2025
- **Contact Information:**
  - 📍 St. Paul, MN
  - 📧 [gage.rowden1145@gmail.com](mailto:gage.rowden1145@gmail.com)
  - 📞 [+1-806-577-8008](tel:+1-806-577-8008)
  - 🔗 [LinkedIn](https://www.linkedin.com/in/gagerowden)
  - 🖥️ [GitHub](https://github.com/gage1145)
  - 🎵 [Bandcamp](https://ganymede1.bandcamp.com) | [Spotify](https://open.spotify.com/artist/23DyBlyjDtXfYo333RBWj7?si=wZcmKk7hQICzxbMIfN2bnQ)

---

## Building

Requires [Quarto](https://quarto.org/docs/get-started/) and a TeX distribution
(`quarto install tinytex` will provide one).

```sh
quarto render              # both formats -> resume.pdf and resume.html
quarto render --to pdf     # just the PDF
quarto preview             # live-reloading HTML preview
```

### How it fits together

| File | Role |
| --- | --- |
| `resume.qmd` | The content: contact details in YAML, everything else in Markdown |
| `resume.cls` | The LaTeX class that defines the print format |
| `template.tex` | Minimal pandoc template that hands the body to `resume.cls` |
| `resume.lua` | Maps Markdown fenced divs onto the class's environments |
| `resume.css` | HTML counterpart to `resume.cls` |
| `legacy/resume.tex` | The pre-Quarto LaTeX source, kept for reference |

Sections are written as fenced divs named after the environments in `resume.cls`:

```markdown
::: {.twocolentry right="Jan 2024--present"}
**Lead Data Scientist**, Priogen Corporation --- St.\ Paul, MN
:::

::: onecolentry
::: highlights
- A bullet point.
:::
:::
```

`resume.lua` turns those into `\begin{twocolentry}{Jan 2024--present}` and friends for
the PDF, and leaves them as `<div class="twocolentry">` for the HTML. Adding a new
environment to `resume.cls` means adding one line to the `ENVS` table in `resume.lua`.

---

## Contributions & Feedback
If you have suggestions for improving my resume formatting or structure, feel free to open an issue or submit a pull request.

## License
This repository is for personal and professional use. Please do not redistribute or modify the content without permission.

---

Thanks for visiting my resume repository! Feel free to connect with me if you have any questions or opportunities.

