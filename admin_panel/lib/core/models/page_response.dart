/// Maps Spring Boot paginated response: { content, totalElements, totalPages, ... }
class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.last,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final content = (json['content'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PageResponse(
      content: content,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
    );
  }

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final bool last;

  bool get isEmpty => content.isEmpty;
}
