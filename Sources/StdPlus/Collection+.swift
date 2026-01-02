extension Collection {
  public var nonEmpty: Self? {
    if isEmpty { nil } else { self }
  }
}
