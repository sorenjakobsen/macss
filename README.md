# Macs/s - Modular audio composition syntax/system

Macs/s is a tool to support a specific method of composing and performing electronic music. The tool comprises a simple musical notation language (syntax) for describing pieces of electronic music, and a program (system) which creates audible, interactive music as described. One primary design goal of Macs/s is to facilitate 'modular' descriptions, i.e. descriptions formed of several components (modules) that may be referenced and interchanged by other components of the same type - possibly in a live performance situation.

## Architecture

The tool is using a client/server architecture, suitable for '[live coding](https://en.wikipedia.org/wiki/Live_coding)' music. The server is implemented in the Csound file macss.csd and the client is implemented as a package for Atom.

## Requirements

To use Macs/s the following software must be installed.

* [Csound](http://csound.com/)
* [Atom](https://atom.io/)
* [Macs/s client for Atom](https://github.com/sorenjakobsen/macss-client)

## Running the example

The best way to learn Macs/s is to play around with the example.

* Pull all the files of this repository to your local machine.
* Adapt line 3 of macss.csd for your audio interface setup.
* Start the server (macss.csd) with csound - in a command line type 'csound macss.csd'.
* Open the example score - example.macss - with Atom.
* Load the samples from the audio folder into the server - while Atom is showing the score, press 'alt+l'.
* Compile the score, load it into the server and start 'performance mode' - press 'alt+d'.
* Interact with music - use keys of your keyboard corresponding to codes in the composition, interpolate between alternate versions of the '1' and '2' modules by holding shift and using the numeric keys and the row of keys starting with 'qwe' (American keyboard layout assumed).
* Exit 'performance mode', change the composition and reload - press arrow keys or move the mouse, type changes in the composition and press 'alt+d'.

## Tips

* To avoid glitchy sound on Windows one can start the server within the command prompt (cmd.exe) with the command "start /HIGH csound -m 0 -d macss.csd" (which could be put inside a clickable .bat file).
* The server uses the impulse response audio file "ir.wav" to provide a small amount of convolution reverb to all sounds - the file may be replaced with other impulse reponse files.

## Author

[Søren Jakobsen](mailto:skj@jakobsen-it.dk)

## Acknowledgments

Thanks to the Csound community for help with using Csound.
