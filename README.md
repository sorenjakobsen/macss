# Macs/s - Modular audio composition syntax/system

Macs/s is a tool to support a specific method of composing and performing electronic music. The tool comprises a simple musical notation language (syntax) for describing pieces of electronic music, and a program (system) which creates audible, interactive music as described. One primary design goal of Macs/s is to facilitate 'modular' descriptions, i.e. descriptions formed of several components (modules) that may be referenced and interchanged by other components of the same type - possibly in a live performance situation.

## Architecture

The tool is using a client/server architecture, suitable for 'live coding' music. The server is implemented in the Csound file macss.csd and the client is implemented as a package for Atom.

## Prerequisites

* [Csound](http://csound.com/)
* [Atom](https://atom.io/)
* [Macs/s client for Atom](https://github.com/sorenjakobsen/macss-client)
* [TouchOSC](https://hexler.net/software/touchosc) (optional) - configure with the file xypad.touchosc.

## Running the examples

* Start the server by running macss.csd with Csound.
* Open one of the example (.macss) files with Atom.
* Load the samples into the server by pressing 'alt+l' (the Atom window showing the example file must be active).
* Compile the example and load the composition into the server by pressing 'alt+m'.
* Switch to the window running macss.csd and use the keyboard (and TouchOSC) to interact with the music.

## Author

Søren Jakobsen.

## Acknowledgments

Thanks to the Csound community for help with using Csound.
