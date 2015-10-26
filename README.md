# Dr. James W. Heisig's "Remember the Kanji 1" 6.edition

This project consists of materials used in RTK1 Anki collections. 
Rather than serve the collection in one piece, it comes in bulks of 250 frames to save room at the end level and make it easier to keep progress in Anki.

### File list

- CSV files containing: frame ID, keyword, kanji, original heisig story and comment etc. You can use this file for import in Anki.
- British English audio for Heisig keywords.
- stroke diagram images in PNG based on KanjiVG SVG files.
- (beta) Japanese audio for custom Japanese keyword
- Anki decks


### TODO

- finish extracting English audio for keywords from [LDOCE5](https://github.com/ciscorn/ldoce5viewer)
- add missing English audio using Google TTS
- replace the main kanji in frames with clean KanjiVG export. Its better, because without fonts the kanji doesn't look natural.
- select suitable Japanese keyword for frames 120 and up. Add audio to these keywords.
- inject frames for primitives?


### FIELD NAMES

id
strokeImageHtml
keywordEn
myKeyword
myStory
jpWord
jpWordReading
jpWordTranslation
constituents
heisigStory
heisigComment
strokeCount
koohiiStory1
koohiiStory2
kanji
exampleWordsHtml
lessonNo
onYomi
kunYomi
frameNo4
jouyou
jlpt
jpWordAudioHtml
keywordEnAudioFileName

### Linux tips
Add prefix and suffix to files

    for f in *; do mv $f RTK1_keyword_en_`basename $f `.mp3; done;
