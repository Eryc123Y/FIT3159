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

## Answer Style Requirements (from Marking Rubric)

Applied answers are marked on written quality (50%) and verbal explanation (50%).

**Accepted formats:**
- Short paragraphs
- Bullet point lists
- Tables (preferred for comparisons)

**Writing rules:**
- Stay within the word limit — no words beyond the limit are evaluated.
- Answer only what is asked; no unnecessary background or filler phrases.
- Use bullet points to structure; use tables when comparing two or more things.
- Provide an example instead of a lengthy explanation where possible.
- Use diagrams/figures where a process or logic structure is involved.
- Do not repeat definitions already stated earlier in the answer.
- If asked for differences between A and B, describe the differences — not just what A and B are individually.

**Marking bands (written):**
| Score | Criteria |
|-------|----------|
| 90–100% | Clear, concise, entirely correct |
| 70–89% | Mostly clear, minor errors only |
| 50–69% | Main points addressed, some errors or verbosity |
| 30–49% | Frequently misses the point, several factual errors |
| 0–29% | Unclear, lengthy, incorrect or irrelevant |

**In-class verbal explanation (60 seconds per question):**
- Focus on the single most important idea.
- Be direct — do not read from the document.
- Engagement and bringing new perspectives earns participation marks.

## Agent/Assistant Scope in This Repo
When helping in this repo, the assistant should:
- Prioritize weekly applied completion and submission quality.
- Default to creating or improving Typst/LaTeX source, not only plain notes.
- Keep solutions concise but complete enough for marking — target 90–100% band.
- Prefer bullet points and tables over prose paragraphs.
- Add figures/visualisations where a concept has a visual form (e.g. formulas, truth tables, graphs).
- Preserve academic integrity and avoid fabricating references.
