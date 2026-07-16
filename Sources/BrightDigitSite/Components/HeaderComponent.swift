//
//  HeaderComponent.swift
//  BrightDigit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Plot

/// The site-wide masthead: logo plus the primary navigation menus.
///
/// Renders the same markup as the former `Node.header()` factory, expressed with
/// Plot's component API so the theme is composed of components (see #67/#53).
internal struct HeaderComponent: Component {
  /// A single navigation entry linking to `path` (defaulting to the lowercased
  /// `name`) and displaying `name` capitalized — mirrors `Node.li(for:at:)`.
  private struct MenuLink: Component {
    internal let name: String
    internal let path: String?

    internal init(_ name: String, at path: String? = nil) {
      self.name = name
      self.path = path
    }

    internal var body: Component {
      ListItem {
        Link(name.capitalized, url: "/" + (path ?? name.lowercased()))
      }
    }
  }

  internal var body: Component {
    Header {
      Navigation {
        Element(name: "ol") {
          ListItem {
            Link(url: "/") {
              Image(url: "/media/brightdigit-name.svg", description: "BrightDigit")
            }
          }
        }.class("logo")
        Element(name: "ol") {
          MenuLink("Services")
          MenuLink("Products")
          MenuLink("Articles")
          MenuLink("Tutorials")
        }.class("menu")
        Element(name: "ol") {
          MenuLink("Podcast", at: "episodes")
          MenuLink("Newsletters")
          ListItem {
            Link("Sponsorship", url: "https://www.patreon.com/brightdigit")
          }
          ListItem {
            Link("About", url: "/about-us")
          }
        }.class("menu")
        Element(name: "ol") {
          ListItem {
            Link("Contact Us", url: "/contact-us")
          }
        }.class("menu")
        Element(name: "ol") {
          ListItem {
            Button {
              Image(url: "/media/list.svg", description: "Mobile Menu")
            }.id("menu")
          }
        }.class("more")
      }
    }
  }
}
