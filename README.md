# Macs/s - Modular audio composition syntax/system

Macs/s is a tool to support a specific method of composing (sequencing) and performing electronic music. The tool comprises a simple music notation language (syntax) for describing pieces of electronic music, and a program (system) which creates audible, interactive music as described. One primary design goal of Macs/s is to facilitate 'modular' descriptions, i.e. descriptions formed of several components (modules) that may be referenced and interchanged with other components of the same type - possibly in a [live (coding)](https://en.wikipedia.org/wiki/Live_coding) performance situation.

## Background

Text editing software is for many people the tool of choice when composing letters and articles - many people have developed habits as to efficiently use this software (and keyboards) in their creative processes of drafting, structuring, writing, editing and managing their texts.

Text editing software may also be used for composing electronic music, but then a complex [formal language](https://en.wikipedia.org/wiki/Formal_language) - e.g. [Chuck](http://chuck.cs.princeton.edu/), [Csound](http://www.csounds.com/) or [SuperCollider](https://supercollider.github.io/) - is required for the machine to 'understand' the text. Thus - in spite of possible benefits to the creative process - text editing software is not so often used for composing electronic music.

Macs/s shares a vision with [TidalCycles](https://tidalcycles.org/) and [ixi lang](https://en.wikipedia.org/wiki/Ixi_lang), to offer a formal language that is simpler - is aimed less at supporting sound and instrument design work and more at making the work of sequencing music fast and enjoyable. The syntax/language of Macs/s is however different from both TidalCycles and ixi lang in that it

* is not designed for automating (by algorithms) the creation of musical events, but more for simply notating such events 'manually'.
* is [declarative](https://en.wikipedia.org/wiki/Declarative_programming) but not [functional](https://en.wikipedia.org/wiki/Functional_programming).
* is [compiled](https://en.wikipedia.org/wiki/Compiler) and not [interpreted](https://en.wikipedia.org/wiki/Interpreter_computing).
* is less flexible and enforces certain limitations.
* provides a powerful - concise and expressive - way of describing and composing musical events 'modularly'.
* supports a mode of interaction which is not by inputting text statements, but where musical changes may be activated by pressing only one button.

## Concept

Many composers of electronic music will be familiar with [Ableton Live](https://www.ableton.com/), where a basic 'building block' of a composition is the 'clip', which may 'modularly' be combined and interchanged with other clips. Macs/s - being a type of programming language - takes this idea of modularity some steps further by letting the user define even an abstract sequence of integers as a module. Another module may then reference such sequences to describe how specific musical parameters - volume, pitch, etc. - are to be changed over time. And where the integers reference steps in scales, the scales may in turn be defined by another type of 'scale module', and so on.

With this level of, more 'granular', modularity Macs/s can offer some possibilities for live performance - and for efficient musical experimentation - somewhat beyond combining 'clips' in different ways. Also, it can facilitate a classical music composition technique - creating a coherent composition by reusing and reworking only some few basic concepts (representable e.g. by certain integer sequences).

## Program

The Macs/s program is using a client/server architecture. The client is implemented as a package for [Atom](https://atom.io/) and facilitates syntax highlighting and compilation of Macs/s 'scores'. The server creates audible, interactive music from the compiled scores and is implemented in the [Csound](http://csound.com/) file macss.csd.

## Running the examples

The best way to learn the Macs/s syntax is to play around with the example scores.

* Install [Csound](http://csound.com/), [Atom](https://atom.io/) and [Macs/s client for Atom](https://github.com/sorenjakobsen/macss-client).
* Pull all the files of this repository to your local machine.
* Adapt line 3 of macss.csd for your audio interface setup.
* Start the server (macss.csd) with csound: on Windows, double click macss.bat - on other systems, open a terminal, navigate to the folder of macss.csd and enter 'csound macss.csd -d -m0'.
* Open an example score (e.g. example/score1.macss) with Atom.
* Load the samples from the audio folder into the server: while Atom is showing the score, press 'alt+l'.
* Compile the score, load it into the server and start 'performance mode': press 'alt+d'.
* Perform the music: use keys of your keyboard corresponding to modules in the score and mix alternate versions of modules by holding an arrow
key while pressing the module keys.
* Exit 'performance mode', change the score and reload: press 'escape' or move the mouse, type changes in the score and press 'alt+d'.
* Stop the music: press 'alt+o'.

## Author

[Søren Jakobsen](mailto:skj@jakobsen-it.dk)

## Acknowledgments

Thanks to the Csound community for help with using Csound.
