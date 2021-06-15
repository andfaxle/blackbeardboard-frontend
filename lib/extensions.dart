library extenstions;

// adds some improvements to the classic Map<T,K> to improve null handling and
// reduce "key not found" errors
extension MapExtensions<T, K> on Map<T, K> {
  K getOrNull(T key) {
    if (this == null || !this.containsKey(key)) {
      return null;
    } else {
      return this[key];
    }
  }

  K getOrElse(T key, K fallback) {
    return this.getOrNull(key) ?? fallback;
  }
}