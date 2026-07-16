/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

extension Attribute where Context == HTML.LinkContext {
  /// Assign a relationship to the link. See `HTMLLinkRelationship` for more info.
  /// - parameter relationship: The relationship to assign.
  /// - Returns: The created attribute.
  public static func rel(_ relationship: HTMLLinkRelationship) -> Attribute {
    Attribute(name: "rel", value: relationship.rawValue)
  }

  /// Assign an `hreflang` attribute to this element.
  /// - parameter language: The language to assign.
  /// - Returns: The created attribute.
  public static func hreflang(_ language: Language) -> Attribute {
    Attribute(name: "hreflang", value: language.rawValue)
  }

  /// Assign an icon sizes string to this element.
  /// - parameter sizes: The icon sizes string to assign.
  /// - Returns: The created attribute.
  public static func sizes(_ sizes: String) -> Attribute {
    Attribute(name: "sizes", value: sizes)
  }

  /// Assign an icon color string to this element.
  /// - parameter color: The icon color string to assign.
  /// - Returns: The created attribute.
  public static func color(_ color: String) -> Attribute {
    Attribute(name: "color", value: color)
  }

  /// Assign whether the link should have the crossorigin attribute.
  /// - parameter isEnabled: Whether crossorigin should be enabled.
  /// - Returns: The created attribute.
  public static func crossorigin(_ isEnabled: Bool) -> Attribute {
    isEnabled ? Attribute(name: "crossorigin", value: nil, ignoreIfValueIsEmpty: false) : .empty
  }
}

extension Attribute where Context: HTMLLinkableContext {
  /// Assign a URL to link the element to, using its `href` attribute.
  /// - parameter url: The URL to assign.
  /// - Returns: The created attribute.
  public static func href(_ url: URLRepresentable) -> Attribute {
    Attribute(name: "href", value: url.string)
  }
}

extension Node where Context: HTMLLinkableContext {
  /// Assign a URL to link the element to, using its `href` attribute.
  /// - parameter url: The URL to assign.
  /// - Returns: The created node.
  public static func href(_ url: URLRepresentable) -> Node {
    .attribute(named: "href", value: url.string)
  }
}

extension Node where Context == HTML.AnchorContext {
  /// Assign a target to the anchor, specifying how its URL should be opened.
  /// - parameter target: The target to assign. See `HTMLAnchorTarget`.
  /// - Returns: The created node.
  public static func target(_ target: HTMLAnchorTarget) -> Node {
    .attribute(named: "target", value: target.rawValue)
  }

  /// Assign a relationship to the anchor, using its `rel` attribute.
  /// - parameter relationship: The relationship to assign. See
  ///   `HTMLAnchorRelationship` for more info.
  /// - Returns: The created node.
  public static func rel(_ relationship: HTMLAnchorRelationship) -> Node {
    .attribute(named: "rel", value: relationship.rawValue)
  }
}

// MARK: - DateTime

extension Node where Context == HTML.TimeContext {
  /// Attach a datetime to the time element, to translate the element into
  /// a machine readable format for browsers.
  /// - parameter datetime: The datetime string to attach. See the datetime
  ///   reference for valid `datetime` values:
  ///   https://developer.mozilla.org/en-US/docs/Web/HTML/Element/time#valid_datetime_values
  /// - Returns: The created node.
  public static func datetime(_ datetime: String) -> Node {
    .attribute(named: "datetime", value: datetime)
  }
}

// MARK: - Interactive elements

extension Node where Context == HTML.DetailsContext {
  /// Assign whether the details element is opened/expanded.
  /// - parameter isOpen: Whether the element should be displayed as open.
  /// - Returns: The created node.
  public static func open(_ isOpen: Bool) -> Node {
    isOpen ? .attribute(named: "open") : .empty
  }
}

// MARK: - Sources and media

extension Attribute where Context: HTMLSourceContext {
  /// Assign a source to the element, using its `src` attribute.
  /// - parameter url: The source URL to assign.
  /// - Returns: The created attribute.
  public static func src(_ url: URLRepresentable) -> Attribute {
    Attribute(name: "src", value: url.string)
  }
}

extension Node where Context: HTMLSourceContext {
  /// Assign a source to the element, using its `src` attribute.
  /// - parameter url: The source URL to assign.
  /// - Returns: The created node.
  public static func src(_ url: URLRepresentable) -> Node {
    .attribute(named: "src", value: url.string)
  }
}

extension Node where Context: HTMLMediaContext {
  /// Assign whether the element's media controls should be enabled.
  /// - parameter enableControls: Whether controls should be shown.
  /// - Returns: The created node.
  public static func controls(_ enableControls: Bool) -> Node {
    enableControls ? .attribute(named: "controls") : .empty
  }
}

extension Attribute where Context == HTML.ObjectContext {
  /// Assign an external resource to the element, using its `data` attribute.
  /// - parameter url: The data URL to assign.
  /// - Returns: The created attribute.
  public static func data(_ url: URLRepresentable) -> Attribute {
    Attribute(name: "data", value: url.string)
  }
}

extension Node where Context == HTML.ObjectContext {
  /// Assign an external resource to the element, using its `data` attribute.
  /// - parameter url: The data URL to assign.
  /// - Returns: The created node.
  public static func data(_ url: URLRepresentable) -> Node {
    .attribute(named: "data", value: url.string)
  }
}

extension Attribute where Context == HTML.AudioSourceContext {
  /// Assign a type to this audio source. See `HTMLAudioFormat` for more info.
  /// - parameter format: The audio format to assign.
  /// - Returns: The created attribute.
  public static func type(_ format: HTMLAudioFormat) -> Attribute {
    Attribute(name: "type", value: "audio/" + format.rawValue)
  }
}

extension Attribute where Context == HTML.VideoSourceContext {
  /// Assign a type to this video source. See `HTMLVideoFormat` for more info.
  /// - parameter format: The video format to assign.
  /// - Returns: The created attribute.
  public static func type(_ format: HTMLVideoFormat) -> Attribute {
    Attribute(name: "type", value: "video/" + format.rawValue)
  }
}

extension Attribute where Context == HTML.PictureSourceContext {
  /// Assign a string describing a set of sources, using the `srcset` attribute.
  /// - parameter set: The set of sources that this element should point to.
  /// - Returns: The created attribute.
  public static func srcset(_ set: String) -> Attribute {
    Attribute(name: "srcset", value: set)
  }

  /// Assign a media query that determines whether this source should be used.
  /// - parameter query: The media query that the browser should evaluate.
  /// - Returns: The created attribute.
  public static func media(_ query: String) -> Attribute {
    Attribute(name: "media", value: query)
  }

  /// Assign a string describing the MIME type, using the `type` attribute.
  /// - parameter type: The type (MIME type) for this element.
  /// - Returns: The created attribute.
  public static func type(_ type: String) -> Attribute {
    Attribute(name: "type", value: type)
  }
}
