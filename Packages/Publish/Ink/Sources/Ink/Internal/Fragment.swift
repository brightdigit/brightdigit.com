/**
*  Ink
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*
*  #40: with Ink's `Reader`-based parser removed, the node structs are no longer
*  `Readable`. `Fragment` is now just the rendering-IR contract: a node that can be
*  emitted to HTML, carries a modifier target, and can produce plain text.
*/

internal typealias Fragment = Modifiable & HTMLConvertible & PlainTextConvertible
