import Plot

internal struct Icon: Component {
  internal let className: String
  internal var body: Component {
    Element(name: "i") {}.class(className)
  }
}
