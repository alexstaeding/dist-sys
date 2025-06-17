#import "@preview/fletcher:0.5.8": diagram, node, edge


#let client-server() = {
  let style = (radius: 15mm, stroke: 3pt)
  diagram(
    spacing: 2em,
    {
      let arrow(..args) = edge(..args, stroke: 2pt, "-|>")

      node((0, 0), name: <server>, [Server], fill: aqua, ..style)
      node((-1, -1), name: <n1>, [Node 1], fill: silver, ..style)
      node((1, -1), name: "n2", [Node 2], fill: silver, ..style)
      node((1, 1), name: "n3", [Node 3], fill: silver, ..style)
      node((-1, 1), name: "n4", [Node 4], fill: silver, ..style)
      arrow(<server>, <n1>)
      arrow(<server>, <n2>)
      arrow(<server>, <n3>)
      arrow(<server>, <n4>)
    },
  )
  // canvas({
  //   import draw: *
  //   fill(red)
  //   circle((0,0), name: "server")
  //   fill(gray)
  //   circle((3, 3), name: "n1")
  //   circle((-3, 3), name: "n2")
  //   circle((3, -3), name: "n3")
  //   circle((-3, -3), name: "n4")

  //   let arrow(..args) = line(..args, mark: (end: ">"))
  //   arrow("server", "n1")
  //   arrow("server", "n2")
  //   arrow("server", "n3")
  //   arrow("server", "n4")
  // })
}
