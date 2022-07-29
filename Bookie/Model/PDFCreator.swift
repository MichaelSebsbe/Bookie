//
//  PDFCreator.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/27/22.
//

import UIKit
import PDFKit

class PDFCreator {
    
    lazy var pageWidth : CGFloat  = {
        return 8.5 * 72.0
    }()
    
    lazy var pageHeight : CGFloat = {
        return 11 * 72.0
    }()
    
    lazy var pageRect : CGRect = {
        CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
    }()
    
    // where the text starts drwaing within the page
    lazy var marginPoint : CGPoint = {
        return CGPoint(x: 50, y: 50)
    }()
    
    lazy var marginSize : CGSize = {
        return CGSize(width: self.marginPoint.x * 2 , height: self.marginPoint.y * 2)
    }()

    private var book: Book?
    private var chapters: [Chapter]?
    
    private var note: NSAttributedString?
    
    private var startPage = 0
    private let chapterFont = UIFont.systemFont(ofSize: 40.0, weight: .heavy)
    
    
    init(book: Book) {
        self.book = book
        let request = Chapter.fetchRequest()
        request.predicate = NSPredicate(format: "parentBook.title MATCHES %@", book.title!)
        
        chapters = CoreDataManager.shared.loadItems(with: request)
    }

    init(note: NSMutableAttributedString, chapterTitle: String) {
        // adding Chapter title to top of note
        note.insert(
            NSAttributedString(
                string: chapterTitle + "\n",
                attributes: [.font : chapterFont]) ,
            at: 0
        )
        self.note = note
    }
    
    
    func prepareData() -> Data {
        //1
        let pdfMetaData = [
            kCGPDFContextCreator: "PDF Creator",
            kCGPDFContextAuthor: "Bookie App",
            kCGPDFContextTitle: "My PDF"
        ]
        
        //2
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        //3
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        //5
        let data = renderer.pdfData { (context) in
            if book != nil {
                drawBook(context)
            } else if let note = note {
                // draw note in chapter
                addText(note, context: context)
            }
        }
        
        return data
    }
    
    private func drawBook(_ context: UIGraphicsPDFRendererContext){
        for chapter in chapters! {
            
            let request = Note.fetchRequest()
            request.predicate = NSPredicate(format: "parentChapter.title MATCHES %@ && parentChapter.parentBook.title MATCHES %@",argumentArray: [chapter.title!, chapter.parentBook!.title!] )
            
            if let note = CoreDataManager.shared.loadItems(with: request)?.first{
                
                let text = NSMutableAttributedString(attributedString: (note.attributedText)!)
                
                text.insert(
                    NSAttributedString(
                        string: chapter.title! + "\n",
                        attributes: [.font : chapterFont]) ,
                    at: 0
                )
                self.addText(text, context: context)
            }
        }
    }
    
    @discardableResult
    private func addText(_ text : NSAttributedString, context : UIGraphicsPDFRendererContext) -> CGFloat {

        let framesetter = CTFramesetterCreateWithAttributedString(text)
        
        var currentRange = CFRangeMake(0, 0)
        var done = false
        repeat {
            
            //1
            /* Mark the beginning of a new page.*/
            context.beginPage()
            
            //2
            /*Draw a page number at the bottom of each page.*/
            startPage += 1
            drawPageNumber(startPage)
            
            
            //3
            /*Render the current page and update the current range to
             point to the beginning of the next page. */
            currentRange = renderPage(startPage,
                                      withTextRange: currentRange,
                                      andFramesetter: framesetter)
            
            //4
            /* If we're at the end of the text, exit the loop. */
            if currentRange.location == CFAttributedStringGetLength(text) {
                done = true
            }
            
        } while !done
        
        return CGFloat(currentRange.location + currentRange.length)
    }
    
    private func renderPage(_ pageNum: Int, withTextRange currentRange: CFRange, andFramesetter framesetter: CTFramesetter?) -> CFRange {
        var currentRange = currentRange
        // Get the graphics context.
        let currentContext = UIGraphicsGetCurrentContext()
        
        // Put the text matrix into a known state. This ensures
        // that no old scaling factors are left in place.
        currentContext?.textMatrix = .identity
        
        // Create a path object to enclose the text. Use 72 point
        // margins all around the text.
        let frameRect = CGRect(x: self.marginPoint.x, y: self.marginPoint.y, width: self.pageWidth - self.marginSize.width, height: self.pageHeight - self.marginSize.height)
        let framePath = CGMutablePath()
        framePath.addRect(frameRect, transform: .identity)
        
        // Get the frame that will do the rendering.
        // The currentRange variable specifies only the starting point. The framesetter
        // lays out as much text as will fit into the frame.
        let frameRef = CTFramesetterCreateFrame(framesetter!, currentRange, framePath, nil)
        
        // Core Text draws from the bottom-left corner up, so flip
        // the current transform prior to drawing.
        currentContext?.translateBy(x: 0, y: self.pageHeight)
        currentContext?.scaleBy(x: 1.0, y: -1.0)
        
        // Draw the frame.
        CTFrameDraw(frameRef, currentContext!)
        
        // Update the current range based on what was drawn.
        currentRange = CTFrameGetVisibleStringRange(frameRef)
        currentRange.location += currentRange.length
        currentRange.length = CFIndex(0)
        
        return currentRange
    }
    
    private func drawPageNumber(_ pageNum: Int) {
        
        let theFont = UIFont.systemFont(ofSize: 20)
        
        let pageString = NSMutableAttributedString(string: "\(pageNum)")
        pageString.addAttribute(NSAttributedString.Key.font, value: theFont, range: NSRange(location: 0, length: pageString.length))
        
        let pageStringSize =  pageString.size()
        
        let stringRect = CGRect(x: (pageRect.width - pageStringSize.width) / 2.0,
                                y: pageRect.height - (pageStringSize.height) / 2.0 - 15,
                                width: pageStringSize.width,
                                height: pageStringSize.height)
        
        pageString.draw(in: stringRect)
        
    }
}
