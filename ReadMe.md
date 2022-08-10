#  BOOKIE
A book summary App, to write your summaries in an organized way so you don't ever forget the contents of a book you read. You can also export your summary as a pdf file.


![](https://github.com/MichaelSebsbe/Bookie/blob/main/Screen%20Recording.gif) ![](https://github.com/MichaelSebsbe/Bookie/blob/main/Screen%20Recording.gif)



# Implemntation
    - Core Data for saving notes
    - AVFoundation for sound effects
    - PDFKit for creating PDF file
    - https://openlibrary.org for fetching Titles 
    - 3rd party Framework for Text formatting (NotesTextView), https://github.com/Rimesh/NotesTextView 
    
##Current issues 
- The current version need to be opened by XCode using Rosetta, otherwise the NoteTextView Framework causes errors.
- NoteTextVIew framework can only be compiled for iOS or Simulator, not both. Thus I have created 2 commits for each in 'NoteTextEditorFramework' Branch
    - 2e35480b26594d5c575f94dc38c12e58e6c82ae9(Branch) iOS 
    - f9c64e56e1538dbb2debaa9ab215dc4f56c7ae4d(Branch) Simulator
    - Going forward I will keep building on the simulator branch, therfore to test on actual device, I just need to replace the frameworkFile from Ios branch
    
##Features to build on (will add more)
    - Maybe add reading mode and editing mode, this is not really necessary, but since I already have code for book like formating(on custom menu branch)
    - if decided to implement, use pageViewController to flip through pages while on reading mode
    
## Attributions 
- Illustrations
<a href="https://www.freepik.com/vectors/design-pack">Design pack vector created by freepik - www.freepik.com</a> 
