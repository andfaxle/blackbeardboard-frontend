library extenstions;

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