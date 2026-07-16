/**
*  Plot
*  Copyright (c) John Sundell 2021
*  MIT license, see LICENSE file for details
*/

import Plot
import XCTest

// XCTest requires all of this case's tests in a single class and file (enforced
// by `single_test_class`), so the file and class lengths here are unavoidable.
// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
internal final class HTMLComponentTests: XCTestCase {
  // swiftlint:disable:next cyclomatic_complexity
  internal func testControlFlow() {
    let string: String? = "String"
    let nilString: String? = nil
    let bool = true
    let int = 3

    let html = Div {
      if let string = string {
        Paragraph(string)
      }

      if let string = nilString {
        Paragraph("Should not be rendered: \(string)")
      }

      if let string = nilString {
        Paragraph("Should not be rendered: \(string)")
      } else {
        Paragraph("Nil")
      }

      string.map { Paragraph($0) }
      nilString.map { Paragraph($0) }

      for string in ["One", "Two"] {
        Paragraph(string)
      }

      if bool {
        Paragraph("True")
      }

      switch int {
      case 3:
        Paragraph("Switch")
      default:
        Paragraph("Should not be rendered")
      }
    }
    .render()

    XCTAssertEqual(
      html,
      """
      <div><p>String</p><p>Nil</p><p>String</p><p>One</p><p>Two</p><p>True</p><p>Switch</p></div>
      """
    )
  }

  internal func testNodeInteroperability() {
    let html = Div {
      Node.p("One")
      Node<Any>.component(Paragraph("Two"))
      Paragraph("Three")
    }
    .render()

    XCTAssertEqual(html, "<div><p>One</p><p>Two</p><p>Three</p></div>")
  }

  internal func testIDAndClassModifiers() {
    let html = Link(
      "Swift by Sundell",
      url: "https://swiftbysundell.com"
    )
    .id("sxs-link")
    .class("link")
    .render()

    XCTAssertEqual(
      html,
      """
      <a href="https://swiftbysundell.com" id="sxs-link" class="link">Swift by Sundell</a>
      """
    )
  }

  internal func testAssigningDirectionalityToElement() {
    let html = Paragraph("Hello")
      .directionality(.leftToRight)
      .render()

    XCTAssertEqual(html, #"<p dir="ltr">Hello</p>"#)
  }

  internal func testAppendingClasses() {
    let html = Paragraph("Hello")
      .class("one")
      .class("two")
      .class("three")
      .render()

    XCTAssertEqual(html, #"<p class="one two three">Hello</p>"#)
  }

  internal func testNotAppendingEmptyClasses() {
    let html = Paragraph("Hello")
      .class("")
      .class("one")
      .class("")
      .class("two")
      .render()

    XCTAssertEqual(html, #"<p class="one two">Hello</p>"#)
  }

  internal func testAppendingClassesToWrappingComponents() {
    struct InnerWrapper: Component {
      var body: Component {
        Paragraph("Hello").class("one")
      }
    }

    struct OuterWrapper: Component {
      var body: Component {
        InnerWrapper().class("two")
      }
    }

    let html = OuterWrapper().class("three").render()
    XCTAssertEqual(html, #"<p class="one two three">Hello</p>"#)
  }

  internal func testAppendingClassToWrappingComponentContainingGroup() {
    struct Wrapper: Component {
      var body: Component {
        ComponentGroup {
          Paragraph("One")
          Paragraph("Two")
        }
        .class("one")
      }
    }

    let html = Wrapper().class("two").render()
    XCTAssertEqual(html, #"<p class="one two">One</p><p class="one two">Two</p>"#)
  }

  internal func testReplacingClass() {
    let html = Paragraph("Hello")
      .class("one")
      .class("two")
      .class("three", replaceExisting: true)
      .render()

    XCTAssertEqual(html, #"<p class="three">Hello</p>"#)
  }

  internal func testAddingClassToMultipleComponents() {
    let html = ComponentGroup {
      Div()
      Div()
    }
    .class("hello")
    .render()

    XCTAssertEqual(html, #"<div class="hello"></div><div class="hello"></div>"#)
  }

  internal func testAddingClassToNode() {
    let html = Node.div(.p()).class("hello").render()
    XCTAssertEqual(html, #"<div class="hello"><p></p></div>"#)
  }

  internal func testEnvironmentValuesDoNotApplyToSiblings() {
    let html = Div {
      Link("One", url: "/one")
        .linkTarget(.blank)
      Link("Two", url: "/two")
        .linkRelationship(.nofollow)
      Link("Three", url: "/three")
    }
    .render()

    XCTAssertEqual(
      html,
      """
      <div>\
      <a href="/one" target="_blank">One</a>\
      <a href="/two" rel="nofollow">Two</a>\
      <a href="/three">Three</a>\
      </div>
      """
    )
  }

  internal func testApplyingEnvironmentValuesToTopLevelHTML() {
    let html = HTML(
      .body {
        Link("One", url: "/one")
        Link("Two", url: "/two")
      }
    )
    .environmentValue(.nofollow, key: .linkRelationship)

    assertEqualHTMLContent(
      html,
      """
      <body>\
      <a href="/one" rel="nofollow">One</a>\
      <a href="/two" rel="nofollow">Two</a>\
      </body>
      """
    )
  }

  internal func testUsingCustomEnvironmentKey() {
    struct TestComponent: Component {
      @EnvironmentValue(.init(identifier: "key")) var value: String?

      var body: Component {
        Paragraph(value ?? "No value")
      }
    }

    let html = TestComponent()
      .environmentValue("Value", key: .init(identifier: "key"))
      .render()

    XCTAssertEqual(html, "<p>Value</p>")
  }

  internal func testApplyingTextStyles() {
    let html = Div {
      Text("Bold")
        .bold()
        .addLineBreak()
      Text("Italic")
        .italic()
        .addLineBreak()
      Text("Underlined")
        .underlined()
        .addLineBreak()
      Text("Strikethrough")
        .strikethrough()
        .addLineBreak()
    }
    .render()

    XCTAssertEqual(
      html,
      """
      <div>\
      <b>Bold</b><br/>\
      <em>Italic</em><br/>\
      <u>Underlined</u><br/>\
      <s>Strikethrough</s><br/>\
      </div>
      """
    )
  }

  internal func testTextConcatenation() {
    let text = Text("One") + Text(" ") + Text("Two").bold()
    XCTAssertEqual(text.render(), "One <b>Two</b>")
  }

  internal func testApplyingAccessibilityLabel() {
    let html = Paragraph("Text")
      .accessibilityLabel("Label")
      .render()

    XCTAssertEqual(html, #"<p aria-label="Label">Text</p>"#)
  }

  internal func testApplyingDataAttribute() {
    let html = Paragraph("Text")
      .data(named: "test", value: "value")
      .render()

    XCTAssertEqual(html, #"<p data-test="value">Text</p>"#)
  }

  internal func testApplyingStyleAttribute() {
    let html = Paragraph("Text")
      .style("color: #000;")
      .render()

    XCTAssertEqual(html, #"<p style="color: #000;">Text</p>"#)
  }

  // swiftlint:disable:next function_body_length
  internal func testElementBasedComponents() {
    let html = HTML {
      Article("Article")
      Button("Button")
      Details("Details")
      Div("Div")
      FieldSet("FieldSet")
      Footer("Footer")
      H1("H1")
      H2("H2")
      H3("H3")
      H4("H4")
      H5("H5")
      H6("H6")
      Header("Header")
      ListItem("ListItem")
      Main("Main")
      Navigation("Navigation")
      Paragraph("Paragraph")
      Span("Span")
      Summary("Summary")
      TableCaption("TableCaption")
      TableCell("TableCell")
      TableHeaderCell("TableHeaderCell")
    }

    assertEqualHTMLContent(
      html,
      """
      <body>\
      <article>Article</article>\
      <button>Button</button>\
      <details>Details</details>\
      <div>Div</div>\
      <fieldset>FieldSet</fieldset>\
      <footer>Footer</footer>\
      <h1>H1</h1>\
      <h2>H2</h2>\
      <h3>H3</h3>\
      <h4>H4</h4>\
      <h5>H5</h5>\
      <h6>H6</h6>\
      <header>Header</header>\
      <li>ListItem</li>\
      <main>Main</main>\
      <nav>Navigation</nav>\
      <p>Paragraph</p>\
      <span>Span</span>\
      <summary>Summary</summary>\
      <caption>TableCaption</caption>\
      <td>TableCell</td>\
      <th>TableHeaderCell</th>\
      </body>
      """
    )
  }

  internal func testAudioPlayer() {
    let html = HTML {
      AudioPlayer(source: .mp3(at: "a.mp3"), showControls: false)
      AudioPlayer(source: .wav(at: "b.wav"), showControls: true)
      AudioPlayer(source: .ogg(at: "c.ogg"), showControls: false)
    }

    assertEqualHTMLContent(
      html,
      """
      <body>\
      <audio><source type="audio/mpeg" src="a.mp3"/></audio>\
      <audio controls><source type="audio/wav" src="b.wav"/></audio>\
      <audio><source type="audio/ogg" src="c.ogg"/></audio>\
      </body>
      """
    )
  }

  internal func testForm() {
    let html = Form(
      url: "url.com",
      method: .post,
      content: {
        FieldSet {
          Label("Username") {
            TextField(name: "username", isRequired: true)
              .autoFocused()
              .autoComplete(false)
          }
          Label("Password") {
            Input(
              type: .password,
              name: "password"
            )
            .class("password-input")
          }
          .class("password-label")
        }
        TextArea(
          text: "Enter a description",
          name: "description",
          numberOfRows: 3,
          numberOfColumns: 2
        )
        SubmitButton("Submit")
      }
    )
    .render()

    XCTAssertEqual(
      html,
      """
      <form action="url.com" method="post">\
      <fieldset>\
      <label>Username\
      <input type="text" name="username" required autofocus autocomplete="off"/>\
      </label>\
      <label class="password-label">Password\
      <input type="password" name="password" class="password-input"/>\
      </label>\
      </fieldset>\
      <textarea name="description" rows="3" cols="2">Enter a description</textarea>\
      <input type="submit" value="Submit"/>\
      </form>
      """
    )
  }

  internal func testIFrame() {
    let html = IFrame(
      url: "url.com",
      addBorder: false,
      allowFullScreen: true,
      enabledFeatureNames: ["gyroscope"]
    )
    .render()

    XCTAssertEqual(
      html,
      """
      <iframe src="url.com" frameborder="0" allowfullscreen allow="gyroscope"></iframe>
      """
    )
  }

  internal func testImageWithDescription() {
    let html = Image(url: "image.png", description: "My image").render()
    XCTAssertEqual(html, #"<img src="image.png" alt="My image"/>"#)
  }

  internal func testImageWithoutDescription() {
    let html = Image("image.png").render()
    XCTAssertEqual(html, #"<img src="image.png"/>"#)
  }

  internal func testLinkRelationshipAndTarget() {
    let html = Div {
      Link("First", url: "/first")
      Link("Second", url: "/second")
        .linkRelationship(.noreferrer)
        .linkTarget(nil)
    }
    .linkRelationship(.nofollow)
    .linkTarget(.blank)
    .render()

    XCTAssertEqual(
      html,
      """
      <div>\
      <a href="/first" rel="nofollow" target="_blank">First</a>\
      <a href="/second" rel="noreferrer">Second</a>\
      </div>
      """
    )
  }

  internal func testOrderedList() {
    let html = List(["One", "Two"])
      .listStyle(.ordered)
      .render()

    XCTAssertEqual(html, "<ol><li>One</li><li>Two</li></ol>")
  }

  internal func testTime() {
    let html = Time(datetime: "2011-11-18T14:54:39Z") {
      Paragraph("Hello World")
    }
    .render()

    XCTAssertEqual(html, #"<time datetime="2011-11-18T14:54:39Z"><p>Hello World</p></time>"#)
  }

  internal func testOrderedListWithExplicitItems() {
    struct SeventhComponent: Component {
      var body: Component { ListItem("Seven") }
    }

    let bool = true

    let html = List {
      ListItem("One").number(1)
      Text("Two")

      if bool {
        Paragraph("Three").class("three")
      }

      ListItem("Four").class("four")

      for string in ["Five", "Six"] {
        ListItem(string)
      }

      SeventhComponent()

      Node.li("Eight")

      Node.group(
        .li("Nine"),
        .li("Ten", .class("ten"))
      )
    }
    .listStyle(.ordered)
    .render()

    XCTAssertEqual(
      html,
      """
      <ol>\
      <li value="1">One</li>\
      <li>Two</li>\
      <li><p class="three">Three</p></li>\
      <li class="four">Four</li>\
      <li>Five</li>\
      <li>Six</li>\
      <li>Seven</li>\
      <li>Eight</li>\
      <li>Nine</li>\
      <li class="ten">Ten</li>\
      </ol>
      """
    )
  }

  internal func testOrderedListWithEmptyComponent() {
    let html = List {
      Text("Hello")
      EmptyComponent()
    }
    .listStyle(.ordered)
    .render()

    XCTAssertEqual(html, "<ol><li>Hello</li></ol>")
  }

  internal func testUnorderedList() {
    let html = List(["One", "Two"]).render()
    XCTAssertEqual(html, "<ul><li>One</li><li>Two</li></ul>")
  }

  internal func testUnorderedListWithCustomItemClass() {
    let html = List([1, 2]) { number in
      Paragraph(String(number))
    }
    .listStyle(.unordered.withItemClass("item"))
    .render()

    XCTAssertEqual(
      html,
      """
      <ul>\
      <li class="item"><p>1</p></li>\
      <li class="item"><p>2</p></li>\
      </ul>
      """
    )
  }

  internal func testUngroupedTable() {
    let html = Table {
      Text("Row one")
      TableRow {
        TableCell("Row two, cell one")
        TableCell("Row two, cell two")
      }

      ComponentGroup {
        TableRow {
          Text("Row three, cell one")
          Text("Row three, cell two")
        }
        TableCell("Row four")
      }
    }
    .render()

    XCTAssertEqual(
      html,
      """
      <table>\
      <tr><td>Row one</td></tr>\
      <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
      <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
      <tr><td>Row four</td></tr>\
      </table>
      """
    )
  }

  internal func testGroupedTable() {
    let html = Table(
      caption: TableCaption("Caption"),
      header: TableRow { Text("Header") },
      footer: TableRow { Text("Footer") },
      rows: {
        Text("Row one")
        TableRow {
          TableCell("Row two, cell one")
          TableCell("Row two, cell two")
        }

        ComponentGroup {
          TableRow {
            Text("Row three, cell one")
            Text("Row three, cell two")
          }
          TableCell("Row four")
        }
      }
    )
    .render()

    XCTAssertEqual(
      html,
      """
      <table>\
      <caption>Caption</caption>\
      <thead><tr><th>Header</th></tr></thead>\
      <tbody>\
      <tr><td>Row one</td></tr>\
      <tr><td>Row two, cell one</td><td>Row two, cell two</td></tr>\
      <tr><td>Row three, cell one</td><td>Row three, cell two</td></tr>\
      <tr><td>Row four</td></tr>\
      </tbody>\
      <tfoot><tr><td>Footer</td></tr></tfoot>\
      </table>
      """
    )
  }
}
