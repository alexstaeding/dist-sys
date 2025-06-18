#import "@preview/touying:0.6.1": *
#import "@preview/cetz:0.4.0": *
#import "@preview/oxifmt:1.0.0": strfmt
#import "@preview/fontawesome:0.5.0": *
#import "@preview/jumble:0.0.1": sha1

#let gen(word1, word2, num-bytes) = {
  let word1Bytes = array(sha1(word1).slice(20 - num-bytes, 20))
  let word2Bytes = array(sha1(word2).slice(20 - num-bytes, 20))
  let xorBytes = word1Bytes.zip(word2Bytes).map(((a, b)) => a.bit-xor(b))
  let fmt(b) = b.map(b => strfmt("{:08b}", b)).join(" ")
  block(
    // width: 40%,
    table(
      stroke: none,
      columns: (1fr, 2fr),
      rows: (1fr, 1fr, 1fr, 1fr),
      [#word1], $... #fmt(word1Bytes)$,
      [#word2], $... #fmt(word2Bytes)$,
      [$xor$], $... #fmt(xorBytes)$,
      [*Distance*], [*#xorBytes.rev().enumerate(start: 0).fold(0, (a, (i, v)) => a + calc.pow(2, 8 * i) * v)*],
    ),
  )
}
