/**
 *  Ink
 *  Copyright (c) John Sundell 2020
 *  MIT license, see LICENSE file for details
 */

internal struct Table: Modifiable, HTMLConvertible, PlainTextConvertible {
    var modifierTarget: Modifier.Target { .tables }

    /// Pre-rendered HTML for each header cell (#40); `nil`/empty means no header row.
    private var header: [String]
    /// Pre-rendered HTML for each body row's cells.
    private var rows: [[String]]
    private var columnAlignments: [ColumnAlignment]
    private var columnCount: Int

    init(renderedHeader: [String],
         renderedRows: [[String]],
         columnAlignments: [ColumnAlignment]) {
        self.header = renderedHeader
        self.rows = renderedRows
        self.columnAlignments = columnAlignments
        self.columnCount = max(renderedHeader.count,
                               renderedRows.map(\.count).max() ?? 0,
                               columnAlignments.count)
    }

    func html(usingURLs urls: NamedURLCollection,
              modifiers: ModifierCollection) -> String {
        var html = ""
        let render: () -> String = { "<table>\(html)</table>" }

        if !header.isEmpty {
            let rowHTML = self.html(forRow: header, cellElementName: "th")
            html.append("<thead>\(rowHTML)</thead>")
        }

        guard !rows.isEmpty else {
            return render()
        }

        html.append("<tbody>")

        for row in rows {
            html.append(self.html(forRow: row, cellElementName: "td"))
        }

        html.append("</tbody>")
        return render()
    }

    func plainText() -> String {
        var text = header.isEmpty ? "" : plainText(forRow: header)

        for row in rows {
            if !text.isEmpty { text.append("\n") }
            text.append(plainText(forRow: row))
        }

        return text
    }
}

internal extension Table {
    enum ColumnAlignment {
        case none
        case left
        case center
        case right

        var attribute: String {
            switch self {
            case .none:
                return ""
            case .left:
                return #" align="left""#
            case .center:
                return #" align="center""#
            case .right:
                return #" align="right""#
            }
        }
    }
}

private extension Table {
    func html(forRow row: [String], cellElementName: String) -> String {
        var html = "<tr>"

        for index in 0..<columnCount {
            let contents = index < row.count ? row[index] : ""
            html.append(htmlForCell(at: index,
                                    contents: contents,
                                    elementName: cellElementName))
        }

        return html + "</tr>"
    }

    func htmlForCell(at index: Int, contents: String, elementName: String) -> String {
        let alignment = index < columnAlignments.count
            ? columnAlignments[index]
            : .none

        let tags = (
            opening: "<\(elementName)\(alignment.attribute)>",
            closing: "</\(elementName)>"
        )

        return tags.opening + contents + tags.closing
    }

    func plainText(forRow row: [String]) -> String {
        var text = ""

        for index in 0..<columnCount {
            if index > 0 { text.append(" | ") }
            text.append(index < row.count ? row[index] : "")
        }

        return text + " |"
    }
}
