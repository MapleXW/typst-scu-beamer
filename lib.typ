// SCU Beamer for Typst
// A Sichuan University presentation theme built on Touying 0.7.4.
//
// The visual language follows the accompanying LaTeX SCU.sty:
// smoothbars navigation, SCU red, frame-title band, circular list markers,
// section outline slides, and a two-row footer.

#import "@preview/touying:0.7.4": *

// Backward-compatible defaults for small standalone helpers.
#let c-scu = rgb("#952A1F")
#let c-scu-dark = rgb("#4A150F")
#let c-scu-soft = rgb("#F7EFED")
#let f-body = ((name: "Liberation Sans", covers: "latin-in-cjk"), "KaiTi", "Noto Sans SC")
#let f-head = ((name: "Liberation Sans", covers: "latin-in-cjk"), "Noto Sans SC")


/// Theme color palette. Override any value and pass the result to `scu-theme`.
#let scu-colors(
  primary: rgb("#952A1F"),
  primary-dark: rgb("#4A150F"),
  primary-soft: rgb("#F7EFED"),
  text: rgb("#211F1E"),
  muted: rgb("#A7A3A1"),
  paper: white,
) = (
  primary: primary,
  primary-dark: primary-dark,
  primary-soft: primary-soft,
  text: text,
  muted: muted,
  paper: paper,
)


/// Theme font families and scale.
///
/// `main` and `heading` are font fallback lists: the first family that exists on
/// the machine wins the Latin/digit coverage, and the CJK families that follow
/// supply the Chinese glyphs. `Noto Sans SC` and `KaiTi` are the portable
/// fallbacks; install `Source Han Sans SC` for the closest match to the original
/// design. See README.md for per-platform font installation notes.
#let scu-fonts(
  main: (
    (name: "Liberation Sans", covers: "latin-in-cjk"),
    "KaiTi",
    "Noto Sans SC",
  ),
  heading: (
    (name: "Liberation Sans", covers: "latin-in-cjk"),
    "Noto Sans SC",
  ),
  mono: ("Noto Sans Mono", "DejaVu Sans Mono", "Consolas", "Courier New"),
  body-size: 18pt,
  navigation-size: 0.56em,
  frame-title-size: 1.08em,
  title-size: 1.55em,
  subtitle-size: 0.92em,
  cover-info-size: 0.78em,
  outline-size: 1.08em,
  footer-size: 0.52em,
  focus-size: 1.55em,
  caption-size: 0.62em,
) = (
  main: main,
  heading: heading,
  mono: mono,
  body-size: body-size,
  navigation-size: navigation-size,
  frame-title-size: frame-title-size,
  title-size: title-size,
  subtitle-size: subtitle-size,
  cover-info-size: cover-info-size,
  outline-size: outline-size,
  footer-size: footer-size,
  focus-size: focus-size,
  caption-size: caption-size,
)


// ---------------------------------------------------------------------------
// Public content helpers

/// Use a slightly smaller body size on dense slides.
#let small(body) = {
  set text(size: 0.86em)
  body
}

/// A numbered code listing with an optional descriptive title.
///
/// Usage: `#code-block(title: [结构优化 INCAR])[```text ... ```]`
#let _code-counter = counter("scu-code-listing")
#let _named-code-active = state("scu-named-code", false)
#let code-block(title: none, prefix: [代码], body) = touying-fn-wrapper(
  (self: none) => {
    _code-counter.step()
    context {
      let number = _code-counter.get().first()
      block(
        width: 100%,
        stroke: 0.6pt + self.colors.primary.lighten(62%),
        radius: 4pt,
        clip: true,
        breakable: false,
      )[
        #block(
          width: 100%,
          fill: self.colors.primary,
          inset: (x: 10pt, y: 3pt),
        )[
          #text(
            font: self.store.fonts.heading,
            fill: self.colors.paper,
            weight: "bold",
            size: 0.62em,
          )[
            #prefix #number#if title != none { [、#title] }
          ]
        ]
        #v(-1.15em)
        #block(
          width: 100%,
          fill: self.colors.primary-soft,
          stroke: (
            left: 2.6pt + self.colors.primary,
            right: none,
            top: none,
            bottom: none,
          ),
          inset: (left: 10pt, right: 8pt, y: 6pt),
        )[
          #_named-code-active.update(true)
          #body
          #_named-code-active.update(false)
        ]
      ]
    }
  },
)

/// A Beamer-style content block.
/// `kind` can be `"normal"`, `"example"`, or `"alert"`.
#let scu-block(title: none, kind: "normal", body) = touying-fn-wrapper(
  (self: none) => {
    let colors = self.colors
    let fonts = self.store.fonts
    let is-example = kind == "example"
    let is-alert = kind == "alert"
    let head-fill = if is-example { colors.paper } else if is-alert {
      colors.primary-dark
    } else {
      colors.primary
    }
    let head-ink = if is-example { colors.primary } else { colors.paper }
    let body-fill = if is-example { colors.paper } else { colors.primary-soft }
    let frame = if is-example { 0.7pt + colors.primary.lighten(55%) } else { none }

    block(
      width: 100%,
      radius: 4pt,
      clip: true,
      stroke: frame,
      breakable: false,
    )[
      #if title != none {
        block(
          width: 100%,
          fill: head-fill,
          inset: (x: 9pt, y: 4pt),
        )[
          #text(font: fonts.heading, fill: head-ink, weight: "bold", size: 0.76em)[
            #title
          ]
        ]
      }
      #block(width: 100%, fill: body-fill, inset: (x: 10pt, y: 7pt))[
        #text(size: 0.82em)[#body]
      ]
    ]
  },
)

/// Normal red block.
#let titled-block(title: none, body) = scu-block(title: title, body)

/// Alert block with a darker title band.
#let alert-block(title: [注意], body) = scu-block(title: title, kind: "alert", body)

/// Example block with a white title band and red text.
#let example-block(title: [示例], body) = scu-block(title: title, kind: "example", body)

/// Compact aliases for common callouts.
#let tip(body) = scu-block(title: [提示], body)
#let warn(body) = alert-block(title: [注意], body)

/// Red table-header cell.
#let th(body, color: c-scu) = table.cell(fill: color)[
  #text(
    font: f-head,
    fill: white,
    weight: "bold",
    size: 0.84em,
  )[#body]
]

/// Booktabs-like table with alternating light-red rows.
#let stable(
  columns,
  row-fill: c-scu-soft,
  line-color: c-scu,
  ..cells,
) = table(
  columns: columns,
  inset: (x: 8pt, y: 5pt),
  stroke: none,
  fill: (x, y) => if y > 0 and calc.even(y) { row-fill },
  table.hline(stroke: 1pt + line-color),
  ..cells,
  table.hline(stroke: 1pt + line-color),
)

/// Filled process step and matching arrow.
#let pill(body, fill: c-scu, ink: white) = box(
  fill: fill,
  radius: 4pt,
  inset: (x: 10pt, y: 5pt),
  text(
    fill: ink,
    font: f-head,
    weight: "bold",
    size: 0.72em,
    body,
  ),
)
#let arr = text(fill: c-scu, size: 0.9em, sym.arrow.r)


// ---------------------------------------------------------------------------
// Navigation data and chrome

/// Sections and their physical slide markers, used by the smoothbars header.
#let _navigation-sections() = {
  let headings = query(heading.where(level: 1, outlined: true))

  if headings.len() == 0 {
    ()
  } else {
    let skipped = query(<scu-skip-navigation>).map(it => it.location().page())
    let markers = query(<scu-slide-marker>).map(it => it.location())
    let marker-pages = markers.map(it => it.page())
    let heading-pages = headings.map(it => it.location().page())
    let last-page = calc.max(..(heading-pages + marker-pages + skipped))
    let result = ()

    for (index, heading) in headings.enumerate() {
      let start = heading.location().page()
      let stop = if index + 1 < headings.len() {
        headings.at(index + 1).location().page()
      } else {
        last-page + 1
      }
      result.push((
        title: heading.body,
        location: heading.location(),
        markers: markers
          .filter(location => start <= location.page() and location.page() < stop)
          .filter(location => location.page() not in skipped),
      ))
    }
    result
  }
}

/// Beamer smoothbars-like top navigation.
#let _navigation-band(self) = context {
  let sections = _navigation-sections()
  let page-number = here().page()
  let current = -1
  for (index, section) in sections.enumerate() {
    if section.location.page() <= page-number {
      current = index
    }
  }

  block(
    width: 100%,
    height: 1.35em,
    fill: self.colors.primary-dark,
    inset: (x: 1.45em),
  )[
    #align(left + horizon)[
      #set text(font: self.store.fonts.heading, size: self.store.fonts.navigation-size)
      #if sections.len() > 0 {
        grid(
          columns: sections.map(_ => auto),
          column-gutter: 1.35em,
          ..sections.enumerate().map(((index, section)) => {
            let active = index == current
            let ink = if active {
              self.colors.paper
            } else {
              self.colors.paper.transparentize(58%)
            }
            let dots = if section.markers.len() == 0 {
              h(0pt)
            } else {
              stack(
                dir: ltr,
                spacing: 3.5pt,
                ..section.markers.map(location => link(location, circle(
                  radius: 2.2pt,
                  stroke: 0.8pt + ink,
                  fill: if location.page() == page-number { ink } else { none },
                ))),
              )
            }
            stack(
              dir: ttb,
              spacing: 0.12em,
              link(section.location, text(fill: ink, weight: "bold", section.title)),
              dots,
            )
          }),
        )
      }
    ]
  ]
}

/// Fixed-height SCU-red frame-title band.
#let _title-band(self) = {
  let title = utils.call-or-display(self, self.store.header-title)
  if title != none {
    block(
      width: 100%,
      height: 2em,
      fill: self.colors.primary,
      inset: (x: 1.45em),
    )[
      #grid(
        columns: (1fr, auto),
        column-gutter: 0.8em,
        align: (left + horizon, right + horizon),
        move(
          dy: 0.12em,
          text(
            font: self.store.fonts.heading,
            fill: self.colors.paper,
            weight: "bold",
            size: self.store.fonts.frame-title-size,
            title,
          ),
        ),
        if self.info.logo != none { move(dy: 0.12em, self.info.logo) },
      )
    ]
  }
}

#let _header(self) = stack(
  dir: ttb,
  spacing: 0pt,
  _navigation-band(self),
  _title-band(self),
)

/// Fixed-height, edge-to-edge SCU-red footer band.
#let _footer(self) = {
  let info-or(field, fallback: none) = if (
    field in self.info
      and self.info.at(field) != none
      and self.info.at(field) != auto
  ) {
    self.info.at(field)
  } else {
    fallback
  }
  let talk-title = info-or("short-title", fallback: info-or("title"))
  let counter = context utils.slide-counter.display()

  set text(
    font: self.store.fonts.main,
    size: self.store.fonts.footer-size,
    fill: self.colors.paper,
  )
  block(
    width: 100%,
    height: 34pt,
    fill: self.colors.primary,
    inset: (x: 1.45em, y: 3pt),
  )[
    #align(center + horizon)[
      #stack(
        dir: ttb,
        grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          talk-title,
          counter,
        ),
      )
    ]
  ]
}


// ---------------------------------------------------------------------------
// Slide types

/// Standard content slide. Heading-based slides use this automatically.
#let slide(
  title: auto,
  header: auto,
  footer: auto,
  align: auto,
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto { self.store.align = align }
  if title != auto { self.store.header-title = title }
  if header != auto { self.store.slide-header = header }
  if footer != auto { self.store.slide-footer = footer }

  let slide-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    hide[#"" <scu-slide-marker>]
    body
  }
  touying-slide(
    self: self,
    config: config,
    repeat: repeat,
    setting: slide-setting,
    composer: composer,
    ..bodies,
  )
})

/// Cover slide. Named arguments override fields from `config-info`.
#let title-slide(config: (:), ..args) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
    config-page(header: none, footer: none, margin: (x: 1.8em, y: 1.4em)),
  )
  let info = self.info + args.named()
  let fonts = self.store.fonts

  touying-slide(self: self)[
    #align(center + horizon)[
      #block(
        width: 100%,
        fill: self.colors.primary,
        radius: 4pt,
        inset: (x: 1em, y: 0.72em),
      )[
        #text(
          font: fonts.heading,
          fill: self.colors.paper,
          weight: "bold",
          size: fonts.title-size,
        )[#info.title]
        #if info.subtitle != none {
          parbreak()
          v(0.22em)
          text(
            font: fonts.heading,
            fill: self.colors.paper.transparentize(15%),
            size: fonts.subtitle-size,
            info.subtitle,
          )
        }
      ]
      #v(1.1em)
      #if "reporter" in info and info.reporter != none {
        text(size: fonts.cover-info-size)[报告人：#info.reporter]
        parbreak()
      } else if info.author != none {
        text(size: fonts.cover-info-size)[#info.author]
        parbreak()
      }
      #if "supervisor" in info and info.supervisor != none {
        text(size: fonts.cover-info-size)[指导教师：#info.supervisor]
        parbreak()
      }
      #if info.institution != none {
        text(size: fonts.cover-info-size)[#info.institution]
        parbreak()
      }
      #if info.date != none {
        text(size: fonts.cover-info-size)[#utils.display-info-date(self)]
      }
    ]
  ]
})

/// Shared outline renderer. If `current-only` is true, other sections are gray.
#let _outline-body(self, current-only: false) = context {
  let sections = _navigation-sections()
  let page-number = here().page()
  let current = -1
  for (index, section) in sections.enumerate() {
    if section.location.page() <= page-number { current = index }
  }

  set text(font: self.store.fonts.heading, size: self.store.fonts.outline-size)
  block(width: 100%)[
    #stack(
      dir: ttb,
      spacing: 0.85em,
      ..sections.enumerate().map(((index, section)) => {
        let active = not current-only or index == current
        let ink = if active { self.colors.primary } else { self.colors.muted }
        let badge = box(
          width: 1.3em,
          height: 1.3em,
          fill: if active { self.colors.primary } else { self.colors.muted.lighten(25%) },
          radius: 50%,
          place(
            center + horizon,
            text(fill: self.colors.paper, size: 0.7em, weight: "bold", str(index + 1)),
          ),
        )
        box(link(section.location, stack(
          dir: ltr,
          spacing: 0.6em,
          badge,
          text(fill: ink, weight: if active { "bold" } else { "regular" }, section.title),
        )))
      }),
    )
  ]
}

/// Full presentation outline.
#let outline-slide(title: [目录], config: (:)) = touying-slide-wrapper(self => {
  self.store.header-title = title
  touying-slide(
    self: self,
    config: config,
    align(left + horizon, _outline-body(self)),
  )
})

/// Compatibility alias.
#let toc-slide = outline-slide

/// Automatic section-start outline, mirroring LaTeX `AtBeginSection`.
#let section-outline-slide(config: (:), level: 1, numbered: false, body) = touying-slide-wrapper(self => {
  self.store.header-title = [目录]
  self = utils.merge-dicts(
    self,
    config-page(
      header: self => std.align(top, _header(self)),
      footer: self => std.align(bottom, _footer(self)),
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.65em, bottom: 2em, x: 1.8em),
    ),
  )
  touying-slide(
    self: self,
    config: config,
    align(left + horizon, _outline-body(self, current-only: true)),
  )
})

/// Full-bleed SCU-red focus/Q&A slide; not included in the slide counter.
#let focus-slide(body, align: center + horizon, config: (:)) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(fill: self.colors.primary, header: none, footer: none, margin: 2em),
  )
  set text(
    font: self.store.fonts.heading,
    fill: self.colors.paper,
    weight: "bold",
    size: self.store.fonts.focus-size,
  )
  touying-slide(self: self, config: config)[
    #hide[#"" <scu-skip-navigation>]
    #std.align(align, body)
  ]
})


// ---------------------------------------------------------------------------
// Theme entry point

/// Sichuan University Beamer-style Touying theme.
///
/// Pass presentation metadata using Touying's `config-info(...)`.
///
/// The `logo` argument defaults to `none` so that a project only needs an
/// image file if it actually wants one. For the SCU wordmark, pass
/// `logo: image("assets/scu-logo-white-transparent.png", height: 1.45em)`.
#let scu-theme(
  aspect-ratio: "4-3",
  align: top,
  theme-colors: scu-colors(),
  theme-fonts: scu-fonts(),
  display-section-outlines: true,
  logo: none,
  header-title: self => utils.display-current-heading(depth: self.slide-level),
  ..args,
  body,
) = {
  let fonts = theme-fonts

  let render-header(self) = {
    set text(font: fonts.main)
    std.align(top, utils.call-or-display(self, self.store.slide-header))
  }
  let render-footer(self) = {
    set text(font: fonts.main)
    std.align(bottom, utils.call-or-display(self, self.store.slide-footer))
  }

  show: touying-slides.with(
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      fill: theme-colors.paper,
      header: render-header,
      footer: render-footer,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 3.65em, bottom: 2em, x: 1.8em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: if display-section-outlines { section-outline-slide } else { none },
    ),
    config-colors(..theme-colors),
    config-info(logo: logo),
    config-store(
      fonts: fonts,
      align: align,
      header-title: header-title,
      slide-header: _header,
      slide-footer: _footer,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(font: fonts.main, size: fonts.body-size, fill: self.colors.text, lang: "zh")
        set par(leading: 0.72em)
        set list(marker: (
          text(fill: self.colors.primary, size: 0.62em)[●],
          text(fill: self.colors.primary, size: 0.78em)[▸],
        ))
        set enum(numbering: n => box(
          fill: self.colors.primary,
          radius: 50%,
          inset: (x: 4pt, y: 0.4pt),
          baseline: 18%,
          text(font: fonts.heading, fill: self.colors.paper, size: 0.64em, weight: "bold", str(n)),
        ))
        show strong: set text(font: fonts.heading, weight: "bold")
        show raw.where(block: false): box.with(
          fill: self.colors.primary-soft,
          outset: (x: 2.5pt),
          radius: 2pt,
        )
        show raw.where(block: true): code => context {
          if _named-code-active.get() {
            set text(font: fonts.mono, size: 0.70em, fill: self.colors.text)
            code
          } else {
            block(
              width: 100%,
              fill: self.colors.primary-soft,
              stroke: (
                left: 2.6pt + self.colors.primary,
                right: 0.6pt + self.colors.primary.lighten(62%),
                top: 0.6pt + self.colors.primary.lighten(62%),
                bottom: 0.6pt + self.colors.primary.lighten(62%),
              ),
              radius: 4pt,
              inset: (left: 10pt, right: 8pt, y: 6pt),
              breakable: false,
              clip: true,
            )[
              #set text(
                font: fonts.mono,
                size: 0.70em,
                fill: self.colors.text,
              )
              #code
            ]
          }
        }
        show figure.caption: set text(size: fonts.caption-size)
        show heading: set text(font: fonts.heading, fill: self.colors.primary, weight: "bold")
        show link: link-element => if type(link-element.dest) == str {
          text(fill: self.colors.primary, link-element)
        } else {
          link-element
        }
        body
      },
      alert: utils.alert-with-primary-color,
    ),
    ..args,
  )

  body
}
