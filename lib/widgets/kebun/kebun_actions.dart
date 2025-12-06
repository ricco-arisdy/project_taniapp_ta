import 'package:flutter/material.dart';
import 'package:project_taniapp_ta/models/app_constants.dart';

class KebunActions extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onView;
  final bool showViewOption;

  const KebunActions({
    Key? key,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.showViewOption = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey[600],
      ),
      onSelected: (value) {
        switch (value) {
          case 'view':
            onView?.call();
            break;
          case 'edit':
            onEdit?.call();
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
        }
      },
      itemBuilder: (context) => [
        if (showViewOption)
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility,
                    size: 20, color: Color(AppColors.primaryGreen)),
                SizedBox(width: 8),
                Text('Lihat Detail'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: Color(AppColors.infoBlue)),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20, color: Color(AppColors.errorRed)),
              SizedBox(width: 8),
              Text('Hapus', style: TextStyle(color: Color(AppColors.errorRed))),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade600,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi Hapus',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus kebun ini?\n\nData yang sudah dihapus tidak dapat dikembalikan.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Action Button untuk form pages
class KebunFormActions extends StatelessWidget {
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String saveButtonText;

  const KebunFormActions({
    Key? key,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.saveButtonText = 'Simpan',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Cancel Button
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Save Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.primaryGreen),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      saveButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Floating Action Button untuk add kebun
class KebunFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const KebunFloatingActionButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: const Color(AppColors.primaryGreen),
      foregroundColor: Colors.white,
      elevation: 8,
      child: const Icon(Icons.add, size: 28),
    );
  }
}
