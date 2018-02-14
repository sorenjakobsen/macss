# Macs/s - Modular audio composition syntax/system

Macs/s is a tool to support a specific method of composing (sequencing) and performing electronic music. The tool comprises a simple musical notation language (syntax) for describing pieces of electronic music, and a program (system) which creates audible, interactive music as described. One primary design goal of Macs/s is to facilitate 'modular' descriptions, i.e. descriptions formed of several components (modules) that may be referenced and interchanged by other components of the same type - possibly in a live performance situation.

## Architecture

The tool is using a client/server architecture, suitable for '[live coding](https://en.wikipedia.org/wiki/Live_coding)' music. The server is implemented in the Csound file macss.csd and the client is implemented as a package for Atom.

## Requirements

To use Macs/s the following software must be installed.

* [Csound](http://csound.com/)
* [Atom](https://atom.io/)
* [Macs/s client for Atom](https://github.com/sorenjakobsen/macss-client)

## Running the examples

The best way to learn Macs/s is to play around with the examples.

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
