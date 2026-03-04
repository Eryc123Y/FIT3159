# AGENTS.md

## Purpose
This repository is for learning Monash FIT3159 (Computer Architecture).

Primary goal each week:
- Complete the weekly `applied` exercises.
- Submit a clean, reproducible report using Typst or LaTeX.

## Working Principles
- Be consistent: use one standard workflow each week.
- Be verifiable: every answer should be traceable to class materials or your own derivation.
- Be submission-ready: compile to PDF before considering a task done.
- Be ethical: no plagiarism, no collusion, cite all external references.

## Repository Layout (Current)
- `w1-boolean algebra/`
  - `applied/`
  - `workshop/`
- `w2-data-representation/`
  - `applied/`
  - `workshop/`
- `Verilog/` (labs/experiments as needed)

Recommended per-week layout extension:
- `wX-topic/applied/`
  - `assets/` (images/figures)
  - `submission/` (final PDF only)
  - `typst/` or `latex/` (source files)
  - `notes.md` (key ideas, mistakes, follow-ups)

## Weekly Execution Workflow
1. **Preview (before class)**
   - Read workshop slides and identify required concepts.
   - List formulas, laws, and definitions needed for applied questions.

2. **Solve (during/after class)**
   - Solve all applied questions manually first.
   - For logic/boolean tasks, show simplification steps and law names.
   - For architecture/data representation tasks, show assumptions and units.

3. **Write-up (Typst or LaTeX)**
   - Convert rough solutions into a structured report.
   - Include: problem statement, method, working, final answer, quick verification.

4. **Self-check**
   - Recompute numeric/boolean results.
   - Confirm diagrams/tables match expressions.
   - Compile PDF successfully.

5. **Submit and Archive**
   - Place final PDF in `submission/`.
   - Keep source (`.typ` or `.tex`) and assets in repo.
   - Add a brief reflection in `notes.md`.

## Report Template Requirements
Every submission should include:
- Title: unit code, week number, task name, your name, date.
- Section per question:
  - Given
  - Approach
  - Working
  - Final answer
  - Verification (brief)
- References section if external material is used.

## Typst Workflow
Suggested files:
- `main.typ`
- `sections/*.typ`
- `assets/*`

Build command:
```bash
typst compile main.typ ../submission/FIT3159_WX_Applied.pdf
```

## LaTeX Workflow
Suggested files:
- `main.tex`
- `sections/*.tex`
- `assets/*`

Build command:
```bash
latexmk -pdf -interaction=nonstopmode -halt-on-error main.tex
```

## Quality Gate Before Submission
- All questions answered.
- No missing steps for derivations/simplifications.
- Tables/figures are numbered and referenced.
- PDF compiles with no errors.
- Filename follows convention:
  - `FIT3159_WX_Applied_<YourName>.pdf`

## Definition of Done (Per Week)
A week is complete only when all are true:
- Applied tasks are solved.
- One final PDF is generated and stored in `submission/`.
- Source files are committed to the weekly folder.
- `notes.md` captures:
  - what was hard,
  - common mistakes,
  - what to review before next week.

## Suggested Cadence
- Mon-Tue: preview workshop materials.
- Wed-Thu: draft solutions.
- Fri: produce Typst/LaTeX report.
- Sat: verification pass.
- Sun: submit and archive.

## Agent/Assistant Scope in This Repo
When helping in this repo, the assistant should:
- Prioritize weekly applied completion and submission quality.
- Default to creating or improving Typst/LaTeX source, not only plain notes.
- Keep solutions concise but complete enough for marking.
- Preserve academic integrity and avoid fabricating references.
