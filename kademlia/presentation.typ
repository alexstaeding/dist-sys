#import "@preview/touying:0.6.1": *
#import themes.metropolis: *
#import "@preview/fontawesome:0.5.0": *
#import "@preview/ctheorems:1.1.3": *
#import "@preview/cetz:0.4.0": *
#import "@preview/numbly:0.1.0": numbly
#import "@preview/jumble:0.0.1": bytes-to-hex, sha1, xor-bytes
#import "@preview/suiji:0.4.0": gen-rng-f, integers-f
#import "@preview/oxifmt:1.0.0": strfmt
#import "../utils.typ": *
#import "../common/diagram/network.typ"
#import "chapters/dht-4-bit.typ"
#import "chapters/xor-example.typ"

// Pdfpc configuration
// typst query --root . ./example.typ --field value --one "<pdfpc-file>" > ./example.pdfpc
#let pdfpc-config = pdfpc.config(
  duration-minutes: 30,
  start-time: datetime(hour: 14, minute: 10, second: 0),
  end-time: datetime(hour: 14, minute: 40, second: 0),
  last-minutes: 5,
  note-font-size: 12,
  disable-markdown: false,
)

#let proof = thmproof("proof", "Proof")
#let rng = gen-rng-f(12093)

#show: metropolis-theme.with(
  aspect-ratio: "16-9",
  footer: self => self.info.institution,
  config-common(
    // handout: true,
    preamble: pdfpc-config,
  ),
  config-info(
    title: [Kademlia],
    subtitle: [How do distributed hash tables work?],
    author: author_list((
      (first_author("Alexander Städing Dominguez"), "alexander.staedingdominguez@unisg.ch"),
    )),
    date: datetime.today().display("[day] [month repr:long] [year]"),
    // institution: [University of Bologna],
    // logo: align(right)[#image("images/disi.svg", width: 55%)],
  ),
)

#set text(font: "Fira Sans", weight: "light", size: 20pt)
#show math.equation: set text(size: 20pt)

#set raw(tab-size: 4)
#show raw: set text(size: 1em)
#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: (x: 1em, y: 1em),
  radius: 0.7em,
  width: 100%,
)

#show bibliography: set text(size: 0.75em)
#show footnote.entry: set text(size: 0.75em)

// #set heading(numbering: "1.1")
#title-slide()

= Hash Tables
#slide(
  repeat: 2,
  self => [
    #let (uncover, only, alternatives) = utils.methods(self)
    #show table.cell.where(y: 0): strong

    #let kvPairs = (
      "foo": "bar",
      "sudo": "magic word",
      "scala": "cool language",
    )

    #table(
      stroke: none,
      align: center,
      columns: (2fr, 10fr, 1fr, 5fr),
      rows: (1fr, 1fr, 1fr),
      gutter: 10mm,
      table.header(
        table.cell([Key], stroke: (bottom: 2pt)),
        uncover(2)[#table.cell([Hash], stroke: (bottom: 2pt))],
        [],
        table.cell([Value], stroke: (bottom: 2pt)),
      ),

      ..kvPairs
        .pairs()
        .map(((k, v)) => ([#k], uncover(2)[#bytes-to-hex(sha1(k))], [#fa-arrow-right(size: 30pt)], [#v]))
        .flatten()
    )
  ],
)

== Keyspace

#let bitData = (4, 8, 16, 256)

#table(
  stroke: none,
  columns: (2fr, 5fr, 5fr),
  rows: (1fr, 1fr, 1fr, 1fr),
  ..bitData
    .map(k => (
      [#k bits],
      truncStr(content: chunked-hex(range(k).map(_ => "0").join()), maxLen: 28, fill: "..."),
      [#if k < 32 { calc.pow(2, k) } else { strfmt("{:.4e}", calc.pow(2.0, k)) } values],
    ))
    .flatten(),
)

= DHT, why?

#let (rng, rngValues) = integers-f(rng, low: 5, high: 28, size: 12)
#let cmpRowspan = 3

#assert(calc.rem(rngValues.len(), cmpRowspan) == 0)

#let numCmp = calc.trunc(rngValues.len() / cmpRowspan)

#slide(
  repeat: numCmp + 1,
  self => [

    #table(
      stroke: (x, y) => if self.subslide != 1
        and self.subslide >= calc.trunc(y / cmpRowspan) + 1
        and x != 0
        and calc.rem(y, cmpRowspan) == 0 {
        (top: 1pt)
      } else if self.subslide == numCmp + 1 and y == rngValues.len() - 1 {
        (bottom: 1pt)
      },
      align: (center, right, center, left),
      row-gutter: 3pt,
      columns: (2fr, 2fr, 1fr, 6fr),
      rows: 1fr,
      ..rngValues
        .enumerate()
        .map(((y, v)) => (
          if calc.rem(y, cmpRowspan) == 0 {
            table.cell(rowspan: cmpRowspan)[#uncover(str(calc.trunc(y / cmpRowspan) + 2) + "-")[#fa-computer(
                  size: 40pt,
                )]]
          } else {
            ()
          },
          [#truncStr(content: chunked-hex(bytes-to-hex(sha1(v.to-bytes()))), maxLen: 12, fill: "...")],
          [#fa-arrow-right(size: 30pt)],
          [#range(v).map(_ => [█]).join()],
        ))
        .flatten()
    )
  ],
)

- The size of the hash table can exceed the capabilities of a single host #pause
  - *Q1: Which key-value pairs are stored on which hosts?* #pause
  - *Q2: How can we find a remote key-value pair?*

= 4-Bit DHT

#slide({
  pdfpc.speaker-note(```md
  ## Slide 1 - Simple DHT

  - A 4 bit DHT is nice, because there are only 16 values
  ```)
  dht-4-bit.gen-slide(1)
})

#slide({
  pdfpc.speaker-note(```md
  ## Slide 2 - Convert to binary
  ```)
  dht-4-bit.gen-slide(2)
})

#slide({
  pdfpc.speaker-note(```md
  ## Slide 3 - Add values

  - We now place some values at the position corresponding to their key
  - Key value pairs
  - Values could be anything

  ### Problem: Computers do not intrinsically relate to anything in the keyspace

  - Computers exist in the physical realm
  - So far, everything has been in a "keyspace"
  - How do we connect them?
  - Solution: put the computers in the keyspace!
  ```)
  dht-4-bit.gen-slide(3)
})

#slide({
  pdfpc.speaker-note(```md
  ## Slide 4 - Each computer gets an identity in the keyspace

  - Unlike key-value pairs, the hash does not have to match a specific property of the object
  - Can be pseudorandom, e.g. hashing some device identifiers
  - Most modern hash functions distribute their outputs well, so over time, this will work well
  - Must be the same size as keys in the keyspace
  - Of course, we assume no collisions (with other nodes, and with key-value pairs)
  ```)
  dht-4-bit.gen-slide(4)
})

== Distance

Nodes are responsible for nearby values #pause
- *How is distance measured?*

== XOR

#align(center)[
  #image("../resources/XOR_ANSI.svg", width: 30%)
  #pause
  #block(
    width: 40%,
    inset: 8pt,
    stroke: 1pt,
    radius: 10pt,
    table(
      stroke: none,
      columns: (1fr, 1fr, 1fr),
      table.header([*A*], [*B*], [*$A xor B$*]),
      [0], [0], [0],
      [0], [1], [1],
      [1], [0], [1],
      [1], [1], [0],
    ),
  )
]

== XOR Example

#align(center)[
  #xor-example.gen("hello", "there", 1)
]

#align(center)[
  #xor-example.gen("hello", "there", 4)
]
