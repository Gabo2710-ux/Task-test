import 'pagination_meta.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.data,
    required this.meta,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    if (!json.containsKey('data') || !json.containsKey('meta')) {
      throw const FormatException('Response is missing data or meta object');
    }

    final dataList = json['data'] as List<dynamic>;
    final metaObj = json['meta'] as Map<String, dynamic>;

    return PaginatedResponse<T>(
      data: dataList.map((e) => fromJsonT(e as Map<String, dynamic>)).toList(),
      meta: PaginationMeta.fromJson(metaObj),
    );
  }
}
