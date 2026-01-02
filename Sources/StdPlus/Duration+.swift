extension Duration {
  public var timeInterval: Double {
    get { Double(attoseconds) * 0.000_000_000__000_000_001 }
    set { self = .seconds(newValue) }
  }
}
