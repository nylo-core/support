/// Nylo Query Parameters
/// Contains the [data] passed from the URL.
/// E.g. "/home-page?userId=2
/// [data] = {"userId": "2"}
class NyQueryParameters {
  Map<String, String> data;
  NyQueryParameters(this.data);
}
