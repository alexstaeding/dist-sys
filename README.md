# Welcome to my presentations on distributed systems

## Kademlia

To compile the pdf, run 
```sh
cd kademlia # if not already in directory
typst compile presentation.typ --root ..
```

To compile the pdfpc notes, run
```sh
cd kademlia # if not already in directory
typst query --root .. ./presentation.typ --field value --one "<pdfpc-file>" > ./presentation.pdfpc
```

To run the slides with pdfpc, run
```sh
cd kademlia # if not already in directory
pdfpc presentation.pdf
```
