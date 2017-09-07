# Burroughs Project Stylesheets

*This is a test change for the GitHub workshop*

These stylesheets are used to transform the Burroughs TEI documents into the various components necessary for generating Islandora ingest packages for the [Comparative Edition Solution Pack](https://github.com/fsulib/islandora_solution_pack_comparative_edition). 

* [display.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/display.xsl) is used to generate the page HTML files that display the transcriptions
* [full-tml.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/full-html.xsl) is used to create proofing documents. It has the same HTML as display.xsl, but it outputs all of the pages into one document, so that they can be easily proofread as a unit.
* [header2mods.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/header2mods.xsl) (sort of) creates MODS records based on the TEI header. ***This needs to be heavily edited before being used on any other documents***
* [index-plain.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/index-plain.xsl) creates a plaintext list of all of the sentences in a given page with the sentence number and "||" to separate them.
* [index-tags.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/index-tags.xsl) creates a sentence list for each page like the one created by index-plain.xsl, but it outputs the sentences surrounded with an <span> tag with HTML for display.
* [pseudo-TEI.xsl](https://github.com/scstanley7/burroughs-stylesheets/blob/master/pseudo-TEI.xsl) creates page-level TEI-like files that replicate all of the contents of <surface> for each page.

* test change for workshop