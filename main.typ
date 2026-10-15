// ===========================================================================
// SCU Beamer for Typst — 演示与用法示例
//
// 这是一份可以直接替换内容的模板。编译：
//     typst compile main.typ
// 若希望保存时自动重新编译：
//     typst watch main.typ
//
// 所有元数据都写在下面的 config-info 中。
// ===========================================================================

#import "lib.typ": *

#show: scu-theme.with(
  aspect-ratio: "4-3",        // 也可改为 "16-9"
  config-info(
    title: [演示文稿标题],
    short-title: [页脚短标题],   // 页脚显示的短标题，可省略
    subtitle: [副标题：研究主题或课程名称],
    author: [报告人姓名],
    institution: [四川大学 · 学院或研究所],
    date: datetime(year: 2026, month: 1, day: 1),
  ),
  // 如需在标题栏右侧显示川大标志，取消下一行注释
  // logo: image("assets/scu-logo-white-transparent.png", height: 1.45em),
)

// 项目内自定义的小工具（可按需删改）
#let term(body) = text(fill: c-scu, weight: "bold", body)
#let tiny(body) = {
  set text(size: 0.68em)
  body
}

// ---------------------------------------------------------------------------
// 封面与目录

#title-slide()

#outline-slide()

// ---------------------------------------------------------------------------
// 正文章节。一级标题（=）会自动生成一张带进度高亮的目录页。

= 第一部分：排版元素

== 文字、列表与强调

你可以像写普通 Typst 文档一样书写正文。主题已经预设好：

- 无序列表使用红色圆点和三角标记
- 有序列表使用红色圆形数字 #text(fill: c-scu)[1] #text(fill: c-scu)[2] #text(fill: c-scu)[3]
- #strong[加粗文字] 会自动切换到标题字体
- #term[自定义强调色] 可通过 `term()` 帮助函数实现
- 行内代码 `POSCAR`、`INCAR` 自带浅红底色

#v(0.4em)
#small[`small(...)` 可以把整段内容缩小到 0.86 倍，适合信息密集的页面。]

== 两种颜色分栏

#grid(
  columns: (1fr, 1.2fr),
  gutter: 1.3em,
  [
    #titled-block(title: [左侧标题])[
      1. 第一个要点
      2. 第二个要点
      3. 第三个要点
    ]
  ],
  [
    #text(weight: "bold", fill: c-scu)[用 grid 手写分栏]

    #v(0.35em)
    - `columns: (1fr, 1.2fr)` 控制两栏宽度比
    - `gutter: 1.3em` 控制栏间距
    - 任意一栏都可以继续嵌套 `grid`

    #v(0.45em)
    #example-block(title: [示例])[
      示例块使用白色标题栏与红色文字，适合放具体例子。
    ]
  ],
)

== 提示块：正常、示例、警告

#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    #titled-block(title: [普通块])[
      `titled-block` 为红底白字的标题栏。
    ]

    #v(0.6em)
    #tip[`tip[...]` 是普通块的快捷写法。]
  ],
  [
    #example-block(title: [示例块])[
      `example-block` 用于举例说明。
    ]

    #v(0.6em)
    #warn[`warn[...]` 或 `alert-block[...]` 使用深红标题栏，用于提醒与警告。]
  ],
)

== 表格

#stable(
  (0.7fr, 1fr, 1.3fr),
  th[列一], th[列二], th[列三],
  [第一行], [内容说明], [补充说明],
  [第二行], [内容说明], [补充说明],
  [第三行], [内容说明], [补充说明],
)

#v(0.6em)
#tip[`stable(列宽, th[表头], ...单元格)` 会自动生成红色上下边线和浅红隔行底色。]

== 代码块

#grid(
  columns: (1fr, 1fr),
  gutter: 1.1em,
  [
    #text(weight: "bold")[默认代码块]
    ```python
    import numpy as np

    x, y = np.loadtxt("data/raw/result.dat", unpack=True)
    print(x.shape, y.max())
    ```
  ],
  [
    #text(weight: "bold")[带编号标题的代码块]

    #code-block(title: "示例脚本")[```bash
    #!/bin/bash
    #PBS -N demo
    #PBS -l nodes=1:ppn=32
    mpirun -np 32 ./program > out.log
    ```]
  ],
)

#tiny[`code-block` 会自动编号，便于在正文中用“代码 1”指代。较长的代码建议单独占满一页。]

== 流程与箭头

#align(center + horizon)[
  #grid(
    columns: (1fr, auto, 1fr, auto, 1.45fr),
    gutter: 0.5em,
    align: horizon,
    titled-block(title: [1 第一步])[
      说明文字

      #text(fill: c-scu, weight: "bold")[关键输出]
    ],
    text(fill: c-scu, size: 1.55em, sym.arrow.r),
    titled-block(title: [2 第二步])[
      说明文字

      #text(fill: c-scu, weight: "bold")[关键输出]
    ],
    text(fill: c-scu, size: 1.55em, sym.arrow.r),
    titled-block(title: [3 第三步])[
      #grid(
        columns: (1fr, 1fr),
        gutter: 0.35em,
        [结果 A], [结果 B],
        [结果 C], [结果 D],
      )
    ],
  )
]

#v(0.5em)
#tip[也可以用 `pill[...] #arr pill[...]` 画更紧凑的流程条。]

== 图片与图注

#grid(
  columns: (1.6fr, 0.8fr),
  gutter: 1em,
  align: horizon,
  [
    #figure(
      image("assets/scu-logo.png", width: 55%),
      caption: [图片下方会自动使用小字号图注],
    )
  ],
  [
    #term[放图片的方式]

    - 用 `figure(image(...), caption: [...])` 自动编号
    - 建议导出 PDF 或 SVG 矢量图
    - 位图分辨率不低于 300 dpi
    - 图片宽度用百分比，便于适配两种画幅
  ],
)

// ---------------------------------------------------------------------------
// 第二章节

= 第二部分：常用的几种页面

== 三段并列

#grid(
  columns: (1fr, 1fr, 1fr),
  gutter: 0.8em,
  titled-block(title: [要点一])[
    适合放一段两三行的简短说明。
  ],
  titled-block(title: [要点二])[
    三栏等宽，视觉上比较均衡。
  ],
  titled-block(title: [要点三])[
    超过三栏建议改用表格。
  ],
)

#v(0.8em)
#example-block(title: [小结])[把一页只讲一件事作为默认原则，信息过多时拆成两页。]

== 左右图文

#grid(
  columns: (1fr, 1fr),
  gutter: 1.2em,
  [
    #titled-block(title: [左侧文字])[
      - 第一点说明
      - 第二点说明
      - 第三点说明
    ]

    #v(0.4em)
    #tiny[小字号用于脚注性质的补充说明。]
  ],
  [
    #align(center + horizon)[
      #image("assets/scu-logo.png", width: 70%)
    ]
  ],
)

== 公式

行内公式写作 `$E = m c^2$`，显示为 $E = m c^2$。独立公式会自动居中：

$ integral_0^infinity e^(-x^2) dif x = frac(sqrt(pi), 2) $

#v(0.4em)
#tip[公式的字体跟随 `scu-fonts(main: ...)` 的设置；如需数学字体单独定制，在 `scu-theme` 之后追加 `show math.equation: set text(font: ...)`。]

// ---------------------------------------------------------------------------
// 结束页

#focus-slide[谢谢，欢迎提问]

// ---------------------------------------------------------------------------
// 备注（可选）
//
// · 画幅：默认 4-3，改为 16-9 只需修改 scu-theme 的 aspect-ratio。
// · 配色：传入 scu-colors(primary: rgb("#..."), ...) 即可整体换色。
// · 字号：传入 scu-fonts(body-size: 19pt, ...) 可整体缩放。
// · 章节目录页由 display-section-outlines: true 自动生成；
//   若不需要，设为 false，再用 #outline-slide() 手动放置。
