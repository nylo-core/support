/// Nylo Route Argument
/// Contains the [data] passed from another route.
class NyArgument {
  dynamic data;
  NyArgument(this.data);

  /// Write [data] to controller
  void setData(dynamic data) {
    this.data = data;
  }
}
