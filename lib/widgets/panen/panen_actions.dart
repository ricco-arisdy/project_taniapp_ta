import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';

class PanenActions extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback? onRefresh;
  final VoidCallback? onFilter;
  final bool isLoading;

  const PanenActions({
    Key? key,
    required this.onAdd,
    this.onRefresh,
    this.onFilter,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Add Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Panen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Refresh Button
          if (onRefresh != null)
            IconButton(
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(AppColors.primaryGreen),
                        ),
                      ),
                    )
                  : const Icon(Icons.refresh),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(AppColors.primaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(AppColors.primaryGreen),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),

          // Filter Button
          if (onFilter != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: isLoading ? null : onFilter,
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(AppColors.secondaryGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                    color: Color(AppColors.secondaryGreen),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
