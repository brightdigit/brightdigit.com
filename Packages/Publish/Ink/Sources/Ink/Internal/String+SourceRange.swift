/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*
*  #40: convert a swift-markdown `SourceLocation` (1-based line, 1-based UTF-8 byte
*  column) into a `String.Index` so a node's verbatim source slice can be reconstructed
*  for the modifier `rawString` contract.
*/

internal extension String {
    /// Resolve a 1-based line / 1-based UTF-8-byte column pair (swift-markdown's
    /// `SourceLocation` convention) to a `String.Index`, or `nil` if out of bounds.
    func lineColumnIndex(line: Int, column: Int) -> String.Index? {
        guard line >= 1, column >= 1 else { return nil }

        // Advance to the start of the requested line by counting newlines.
        var currentLine = 1
        var lineStart = startIndex
        if line > 1 {
            var index = startIndex
            while index < endIndex {
                if self[index] == "\n" {
                    currentLine += 1
                    if currentLine == line {
                        lineStart = self.index(after: index)
                        break
                    }
                }
                index = self.index(after: index)
            }
            guard currentLine == line else { return nil }
        }

        // Column is a UTF-8 byte offset from the start of the line.
        let byteOffset = column - 1
        let utf8 = self.utf8
        guard let utf8LineStart = lineStart.samePosition(in: utf8) else { return nil }
        guard let utf8Index = utf8.index(utf8LineStart,
                                         offsetBy: byteOffset,
                                         limitedBy: utf8.endIndex) else {
            return nil
        }
        return utf8Index.samePosition(in: self)
    }
}
