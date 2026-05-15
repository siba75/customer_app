// // lib/core/widgets/search_bar.dart
// import 'dart:async';

// import 'package:customer_app/core/theem/app_typography.dart';
// import 'package:customer_app/core/theem/coler.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';


// class CustomSearchBar extends StatefulWidget {
//   final Function(String) onSearch;
//   final VoidCallback onScanBarcode;

//   const CustomSearchBar({
//     super.key,
//     required this.onSearch,
//     required this.onScanBarcode,
//   });

//   @override
//   State<CustomSearchBar> createState() => _CustomSearchBarState();
// }

// class _CustomSearchBarState extends State<CustomSearchBar> {
//   final TextEditingController _controller = TextEditingController();
//   Timer? _debounce;

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       widget.onSearch(value);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _controller,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(
//                 hintText: 'ابحث عن منتج...',
//                 hintStyle: AppTypography.bodyMedium.copyWith(
//                   color: AppColors.textLight,
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                 prefixIcon: const Icon(Icons.search, color: AppColors.background),
//               ),
//               onChanged: _onSearchChanged,
//             ),
//           ),
//           Container(
//             width: 1,
//             height: 30,
//             color: AppColors.,
//           ),
//           IconButton(
//             onPressed: widget.onScanBarcode,
//             icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
//           ),
//           const SizedBox(width: 8),
//         ],
//       ),
//     );
//   }
// }