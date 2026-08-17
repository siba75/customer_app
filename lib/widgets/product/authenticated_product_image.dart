import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/core/const/config.dart';
import 'package:customer_app/dio/api_auth.dart';
import 'package:flutter/material.dart';

class AuthenticatedProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final Widget Function(BuildContext context)? placeholderBuilder;
  final Widget Function(BuildContext context)? errorBuilder;

  const AuthenticatedProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorBuilder?.call(context) ?? const SizedBox.expand();
    }

    return FutureBuilder<String?>(
      future: ApiAuth.accessToken(),
      builder: (context, snapshot) {
        final token = snapshot.data;
        final needsAuthHeaders = _needsAuthHeaders;

        if (needsAuthHeaders &&
            snapshot.connectionState != ConnectionState.done) {
          return placeholderBuilder?.call(context) ?? const SizedBox.expand();
        }

        if (needsAuthHeaders && (token == null || token.isEmpty)) {
          return errorBuilder?.call(context) ?? const SizedBox.expand();
        }

        return CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: fit,
          httpHeaders: needsAuthHeaders
              ? {'Authorization': 'Bearer $token'}
              : null,
          placeholder: (context, url) =>
              placeholderBuilder?.call(context) ?? const SizedBox.expand(),
          errorWidget: (context, url, error) =>
              errorBuilder?.call(context) ?? const SizedBox.expand(),
        );
      },
    );
  }

  bool get _needsAuthHeaders =>
      imageUrl?.startsWith(ApiConfig.baseUrl) ?? false;
}
