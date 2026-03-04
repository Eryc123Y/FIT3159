#import "@preview/sleek-university-assignment:0.1.0": assignment
#import "@preview/cetz:0.4.2"
#import "@preview/cetz-plot:0.1.3": plot

#show: assignment.with(
  title: "Applied 1",
  authors: (
    (
      name: "Xingyu Yang",
      email: "xyan0147@student.monash.edu",
      student-no: "33533563",
    ),
  ),
  course: "FIT3159 Computer Architecture",

  university-logo: image("../../misc/Monash_University_logo.svg"),
)

= Generative AI Acknowledgement

This assessment was completed with the assistance of generative artificial intelligence. Specifically, Claude (Anthropic, #link("https://claude.ai")[claude.ai]) was used to assist in structuring answers, generating Typst markup, and refining written explanations. All AI-generated content has been reviewed, verified against course materials, and modified as appropriate before inclusion.

= Question 1

*Moore's Law* states that the number of transistors on a microchip doubles approximately every two years, while manufacturing costs remain constant.

*Formula:* $ N(t) = N_0 dot 2^(t / 2) $

where $N_0$ is the initial transistor count and $t$ is time in years.

*Importance:*
- Drives consistent improvements in CPU speed, memory capacity, and energy efficiency.
- Enables smaller, cheaper, and more powerful devices over time.
- Underpins the roadmap for semiconductor R&D and industry investment planning.
- Its slowdown in recent years has pushed the industry moving from scale up to scale out.

#figure(
  caption: [Exponential transistor growth predicted by Moore's Law ($N_0 = 1$)],
  cetz.canvas({
    plot.plot(
      size: (12, 6),
      x-label: [Years since baseline],
      y-label: [Relative transistor count],
      x-tick-step: 2,
      y-tick-step: 200,
      {
        plot.add(
          range(0, 21).map(t => (t, calc.pow(2, t / 2))),
          label: $2^(t\/2)$,
        )
      }
    )
  })
)

= Question 2

*Multi-core processing* places two or more independent CPU cores on one chip, enabling parallel execution of threads.

*Performance improvement:*
- Multiple threads run simultaneously, increasing throughput without raising clock speed on a single core.
- Better performance-per-watt than boosting single-core frequency.

*Challenges:*
- Sequential code gains no benefit; software must be explicitly parallelised.
- Cache coherency and inter-core communication add design complexity.
- Race conditions make concurrent programs harder to debug.

= Question 3

#figure(
  caption: [Truth table for Boolean expressions in X, Y, Z],
  {
    let headers = ([*X*], [*Y*], [*Z*], [*X·Y·Z*], [*X+Y+Z*], [*X'*], [*Y'*], [*X'+Y'+Z*], [*(X+Y')Z'*])
    let cells = ()
    for x in range(2) {
      for y in range(2) {
        for z in range(2) {
          let xp = 1 - x
          let yp = 1 - y
          cells.push([#x])
          cells.push([#y])
          cells.push([#z])
          cells.push([#int(x == 1 and y == 1 and z == 1)])
          cells.push([#int(x == 1 or  y == 1 or  z == 1)])
          cells.push([#xp])
          cells.push([#yp])
          cells.push([#int(xp == 1 or yp == 1 or z == 1)])
          cells.push([#int((x == 1 or yp == 1) and z == 0)])
        }
      }
    }
    table(
      columns: 9,
      align: center,
      fill: (col, row) => if row == 0 { luma(220) },
      stroke: 0.5pt,
      inset: 6pt,
      ..headers,
      ..cells,
    )
  }
)

= Question 4

*Given:*
$ F(A, B, C) = A dot B + A dot overline(B) + B dot C + overline(B) dot C $

*Simplification:*

#table(
  columns: (auto, 1fr, auto),
  align: (center, left, left),
  fill: (col, row) => if row == 0 { luma(220) },
  stroke: 0.5pt,
  inset: 7pt,

  [*Step*], [*Expression*], [*Law applied*],

  [1],
  [$F = A dot B + A dot overline(B) + B dot C + overline(B) dot C$],
  [Given],

  [2],
  [$= A(B + overline(B)) + C(B + overline(B))$],
  [Distributive Law: $X Y + X Z = X(Y+Z)$],

  [3],
  [$= A dot 1 + C dot 1$],
  [Complement Law: $X + overline(X) = 1$],

  [4],
  [$= A + C$],
  [Identity Law: $X dot 1 = X$],
)

*Final result:* $F(A, B, C) = A + C$

= Question 5

*Gate delay* is the propagation delay of a logic gate — the time taken for a change in input to produce a stable, correct output.

#figure(
  caption: [Gate delay: output transitions after propagation delay $t_p$ following input change],
  cetz.canvas({
    import cetz.draw: *

    // Styles
    let sig-height = 0.6
    let gap = 1.4
    let w = 8.0
    let tp = 2.5   // propagation delay position
    let rise = 0.25 // transition width

    // Helper: draw a digital waveform
    let waveform(y, transitions) = {
      let pts = transitions
      for i in range(pts.len() - 1) {
        let (x0, v0) = pts.at(i)
        let (x1, v1) = pts.at(i + 1)
        line((x0, y + v0 * sig-height), (x1, y + v0 * sig-height))
        line((x1, y + v0 * sig-height), (x1, y + v1 * sig-height))
      }
      let (xlast, vlast) = pts.last()
      line((xlast, y + vlast * sig-height), (w, y + vlast * sig-height))
    }

    // Labels — Input on top, Output below
    content((-0.8, gap + sig-height / 2), [*Input*], anchor: "east")
    content((-0.8, sig-height / 2), [*Output*], anchor: "east")

    // Input waveform (top): goes high at x=1, stays high
    waveform(gap, ((0.0, 0), (1.0, 1)))
    // Output waveform (bottom): goes high at x = 1 + tp (delayed), stays high
    waveform(0, ((0.0, 0), (1.0 + tp, 1)))

    // Dashed vertical lines at transition points
    set-style(stroke: (dash: "dashed", paint: gray))
    line((1.0, -0.2), (1.0, gap + sig-height + 0.3))
    line((1.0 + tp, -0.2), (1.0 + tp, gap + sig-height + 0.3))

    // Propagation delay arrow
    set-style(stroke: (dash: "solid", paint: black))
    line((1.0, -0.5), (1.0 + tp, -0.5), mark: (start: ">", end: ">"))
    content(((1.0 + 1.0 + tp) / 2, -0.85), [$t_p$ (gate delay)], anchor: "north")
  })
)

*Significance:*
- It is the fundamental unit of timing in digital circuits.
- The critical path (longest chain of gates) determines the maximum clock frequency: $f_"max" = 1 / t_"critical path"$.
- Minimising gate delay is essential for high-speed circuit design.
- Cumulative delays across gate chains cause timing violations if the clock period is too short, leading to incorrect computation.



= Question 6

*CPU:* Apple M5 @apple2025m5 — *Feature:* GPU-Integrated Neural Accelerators (new in M5; absent in M1–M4).

Each of M5's 10 GPU cores contains a dedicated Neural Accelerator — fixed-function hardware for tensor/matrix operations @wikim5, replacing the prior centralised Neural Engine model.

*Benefits for on-device AI inference:*
- *4× peak GPU AI compute* vs. M4 @apple2025m5 — parallelised across all cores.
- Runs LLMs locally (e.g. LM Studio, Draw Things) @apple2025m5.
- *153 GB/s unified memory* eliminates CPU↔GPU transfer bottlenecks @apple2025m5.
- Lower latency and improved privacy — no cloud required @charlton2025m5.

#bibliography("refs.bib", title: "References", style: "ieee")
