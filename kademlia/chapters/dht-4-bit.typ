#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.0": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/fontawesome:0.5.0": *

#let gen-slide(nr) = {
  let numBits = 4
  let numEntries = calc.pow(2, 4)
  align(center)[
    #canvas(
      length: 1.7cm,
      {
        import draw: *
        range(numEntries)
          .map(x => {
            // numbers above the line
            content(
              (x, 1),
              [#x],
            )
            line((x, -0.5), (x, 0.5))
            content(
              (x, -0.9),
              $#if nr > 1 { strfmt("{:04b}", x) }$,
            )
          })
          .join()
        // main middle line
        line((0, 0), (numEntries - 1, 0))
        let put-value(i, cont) = {
          fill(aqua)
          circle((i, -1.7), radius: 0.35)
          content((i, -1.7), cont)
        }
        let put-node(i, cont) = {
          content((i, -1.7), fa-laptop(size: 35pt))
          content((i, -1.65), cont)
        }
        if nr >= 3 {
          put-value(2, [a])
          put-value(3, [b])
          put-value(7, [c])
          put-value(11, [d])
          put-value(13, [e])
          put-value(15, [f])
        }
        if nr >= 4 {
          put-node(1, [n1])
          put-node(4, [n2])
          put-node(5, [n3])
          put-node(10, [n4])
          put-node(12, [n5])
          put-node(14, [n6])
        }
      },
    )
  ]
}

#let gen-small() = {
  let numBits = 4
  let numEntries = calc.pow(2, 4)
  align(center)[
    #canvas(
      length: 1.7cm,
      {
        import draw: *
        range(numEntries)
          .map(x => {
            content(
              (x, 0.5),
              $#strfmt("{:04b}", x)$,
            )
            line((x, -0.2), (x, 0.2))
          })
          .join()
        // main middle line
        line((0, 0), (numEntries - 1, 0))
        let put-value(i, cont) = {
          fill(aqua)
          circle((i, -0.7), radius: 0.35)
          content((i, -0.7), cont)
        }
        let put-node(i, cont) = {
          content((i, -0.7), fa-laptop(size: 35pt))
          content((i, -0.65), cont)
        }
        put-value(2, [a])
        put-value(3, [b])
        put-value(7, [c])
        put-value(11, [d])
        put-value(13, [e])
        put-value(15, [f])
        put-node(1, [n1])
        put-node(4, [n2])
        put-node(5, [n3])
        put-node(10, [n4])
        put-node(12, [n5])
        put-node(14, [n6])
      },
    )
  ]
}

#let gen-calc-distance(a, b) = {
  assert(a < b)
  align(center)[
    #canvas(
      length: 1.7cm,
      {
        import draw: *
        // to align with previous canvas
        line((-0.5, 0), (15.5, 0), stroke: none)
        line((a, 0), (a, -0.5))
        line((b, 0), (b, -1))
        line((a, -0.5), (b, -0.5))
        content((b - 1.5, -2), [XOR])
        content((b, -1.5), $#strfmt("{:04b}", b)$)
        content((b, -2), $#strfmt("{:04b}", a)$)
        line((b - 2.25, -2.5), (b + 0.5, -2.5))
        content((b, -3), $#strfmt("{:04b}", a.bit-xor(b))$)
        content((b - 1.5, -3.5), [*Distance*])
        content((b, -3.5), [*#a.bit-xor(b)*])
      },
    )
  ]
}
