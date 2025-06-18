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
              [#if nr > 1 { strfmt("{:04b}", x) }],
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
          put-node(5, [n2])
          put-node(10, [n3])
          put-node(12, [n4])
          put-node(14, [n5])
        }
      },
    )
  ]
}
