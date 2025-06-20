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
    subtitle: [A Peer-to-peer Information System Based on the XOR Metric],
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
    - They are opaque
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

== Distance Metric

XOR is a valid distance metric #pause
- Distance to self is 0
- Distance to anything else $> 0$
- Satisfies the triangle property
  - $d(a, b) + d(b, c) >= d(a, c)$

== Distance Example 1

#dht-4-bit.gen-slide(4)
#dht-4-bit.gen-calc-distance(5, 7)

== Distance Example 2

#dht-4-bit.gen-slide(4)
#dht-4-bit.gen-calc-distance(5, 13)

== Distance Example 3

#pdfpc.speaker-note(```md
- In this example, the xor distance does not directly relate to the distance on the line
- Problem: Hamming distance between adjacent entries is not always 1
  - Sometimes it is, but look at the change from 7 to 8. The carry is the problem
- Gray code, where only 1 bit changes for adjacent entries would fix this
```)
#dht-4-bit.gen-slide(4)
#dht-4-bit.gen-calc-distance(11, 12)

== Distance Example 4
#dht-4-bit.gen-slide(4)
#dht-4-bit.gen-calc-distance(4, 5)
= Routing

#slide[
  #quote(attribution: "Petar Maymounkov and David Mazinères", block: true)[
    Kademlia nodes store contact information about each other to route query messages.
    For each $0 <= i < 160$, every node keeps a list of
    $<$IP address, UDP port, Node ID$>$
    triples for nodes of distance between $2^i$ and $2^(i+1)$ from itself.
    We call these lists $k$-buckets.
  ]
]

#slide[
  #align(center)[
    #block(width: 40%)[
      *Great distributed systems embed global properties into algorithms that work locally.*
    ]
  ]
]

== Distance tree

#slide(
  repeat: 8,
  self => [
    *Global State*
    #dht-4-bit.gen-small()
    #align(center)[
      #canvas(
        length: 1.9cm,
        {
          import draw: *
          line((0, 0), (15, 0))
        },
      )
    ]
    #pause
    #stack(
      dir: ltr,
      spacing: 0.5cm,
      [*Local State*],
      canvas({
        import draw: *
        content((0, -1.7), fa-laptop(size: 35pt))
        content((0, -1.65), [n3])
      }),
    )
    #v(-1.5cm)
    #align(center)[
      #canvas(
        length: 1.6cm,
        {
          let gen-children(height) = {
            if height > 0 {
              let children = gen-children(height - 1)
              (([1], ..children), ([0], ..children))
            } else { () }
          }
          import draw: *
          set-style(content: (padding: .1))
          tree.tree(
            grow: 0.6,
            (
              [],
              ..gen-children(4),
            ),
          )
          let put-node(i, cont, fill: black) = {
            content((i, -3.05), fa-laptop(size: 28pt, fill: fill))
            content((i, -3), text(cont, size: 17pt, fill: fill))
          }
          if self.subslide >= 4 {
            put-node(15, "n3")
          }
          let put-n-line(x, i) = {
            line((x, -2.3), (x, -3.3), stroke: red)
            content((x, -3.7), $2^#i$)
          }
          if self.subslide >= 6 {
            put-n-line(14.5, 0)
            put-n-line(13.5, 1)
            put-n-line(11.5, 2)
            put-n-line(7.5, 3)
            put-n-line(-0.5, 4)
          }
          if self.subslide >= 7 {
            put-node(14, "n2")
            put-node(11, "n1")
            put-node(0, "n4")
            put-node(6, "n5")
          }
          if self.subslide == 7 {
            put-node(4, "n6")
          }
          if self.subslide >= 8 {
            put-node(4, "n6", fill: luma(180))
          }
        },
      )
      #if self.subslide == 3 {
        [*Where is n3?*]
      } else if self.subslide == 5 {
        v(-0.5cm)
        quote([... for each $0 <= i < 160$ ... nodes of distance between $2^i$ and $2^(i+1)$ from itself])
      } else if self.subslide == 8 {
        v(-0.8cm)
        move(dx: -5.5cm)[*$K = 2$*]
      }
    ]
  ],
)

== K-Buckets

#slide(
  repeat: 4,
  self => [
    #align(center + top)[
      #v(0.5cm)
      #canvas(
        length: 0.8cm,
        {
          import draw: *
          line((0, 0), (16, 0))
          content((8, 0.5))[Space of 160-bit ID numbers]
          content((0, 0.5))[$11 ... 11$]
          content((16, 0.5))[$00 ... 00$]
          if self.subslide >= 1 {
            // stage 1
            rect((0, -1), (16, -2))
          }
          if self.subslide >= 2 {
            // stage 2
            line((8, -2.5), (4, -3.5))
            line((8, -2.5), (12, -3.5))
            content((4, -3))[1]
            rect((0, -3.5), (8, -4.5))
            content((12, -3))[0]
            rect((8, -3.5), (16, -4.5))
          }
          if self.subslide >= 3 {
            // stage 3
            line((8, -5.5), (4, -6.5))
            line((8, -5.5), (12, -6.5))
            content((4, -6))[1]
            rect((0, -6.5), (8, -7.5))
            content((12, -6))[0]

            line((12, -6.5), (10, -8))
            line((12, -6.5), (14, -8))
            rect((8, -8), (12, -9))
            rect((12, -8), (16, -9))
            content((10, -7.5))[1]
            content((14, -7.5))[0]
          }
          if self.subslide >= 4 {
            // stage 4
            line((8, -10), (4, -11))
            line((8, -10), (12, -11))
            content((4, -10.5))[1]
            rect((0, -11), (8, -12))
            content((12, -10.5))[0]

            line((12, -11), (10, -12.5))
            line((12, -11), (14, -12.5))
            rect((8, -12.5), (12, -13.5))
            content((10, -12))[1]

            line((14, -12.5), (13, -14))
            line((14, -12.5), (15, -14))
            rect((12, -14), (14, -15))
            rect((14, -14), (16, -15))
            content((13, -13.5))[1]
            content((15, -13.5))[0]
          }
        },
      )
    ]
  ],
)

== Routing, cont.

Nodes retain more routing information about closer nodes #pause
- First, take large rough hops
- Eventually, hops become smaller
- $log n$ lookup time

#pause

#v(2cm)
#dht-4-bit.gen-hops(((1, 10, 2), (10, 12, 0.75), (12, 13, 0.5)))
#dht-4-bit.gen-small()

= RPCs

== RPC Overview

Four primary remote procedure calls #pause
- *_ping_* Checks if node is online #pause
- *_store_* Put key-value pair for later retrieval #pause
- *_find\_node_* Returns the nearest $k$ nodes closest to target #pause
- *_find\_value_* Like _find\_node_, but returns value if it exists locally

== Node Lookup

Recursive algorithm
1. Local nodes picks $alpha$ (concurrency param.) nodes closest to target ID #pause
2. Send concurrent, asynchronous _find\_node_ RPCs to the $alpha$ nodes #pause
3. Resend _find\_node_ RPCs to closer nodes it has learned about #pause
  - This recursion can begin before all $alpha$ nodes from previous RPCs have returned #pause
  - Can also use latency information #pause
4. Finish when desired key-value pair is found, or no closer nodes can be found

== Maintenance

- Key-value pairs must be frequently republished, otherwise they expire #pause
  - The authors use a 24 hour expiration time for the use-case of file sharing #pause
- Buckets are kept fresh by traffic going through them


== Load Balancing

#slide(
  repeat: 4,
  self => [
    - Values are re-stored at nodes along the lookup path #pause
    - Requests from different nodes eventually converge to the same path #pause


    #v(2cm)
    #dht-4-bit.gen-hops(((1, 10, 2), (10, 12, 0.75), (12, 13, 0.5)))
    #dht-4-bit.gen-small()
    #align(center)[
      #canvas(
        length: 1.7cm,
        {
          import draw: *
          // to align with previous canvas
          line((-0.5, 0), (15.5, 0), stroke: none)
          if self.subslide >= 3 {
            content((12, 1))[*Found*]
          }
          if self.subslide >= 4 {
            content((10, 1))[*Stored*]
          }
        },
      )
    ]
  ],
)

== Conclusion

Kademlia has some very nice provable properties
- Performance
- Latency-minimizing routing
- Symmetric, unidirectional topology
- Concurrenty parameter $alpha$

#pause

Further discussion:
- How to deal with poor locality?

#pause

#v(2cm)

Sources
#v(0cm)
#text(size: 14pt)[
  1. _Kademlia_ https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf
  2. _Kademlia, Explained_ https://youtu.be/1QdKhNpsj8M?si=AqXuKQymffdI9bpF
]
