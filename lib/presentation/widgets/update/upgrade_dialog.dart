import 'package:flutter/material.dart';
import '../../../core/constants/app_info.dart';
import '../../../core/services/app_update_service.dart';
import '../../../core/extensions/context_extensions.dart';

class UpgradeDialog extends StatefulWidget {
  final AppUpdateInfo info;
  final VoidCallback onIgnore;
  final VoidCallback? onUpdate;

  const UpgradeDialog({
    super.key,
    required this.info,
    required this.onIgnore,
    this.onUpdate,
  });

  @override
  State<UpgradeDialog> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String? _errorMessage;
  String? _downloadedFilePath;

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
    });

    try {
      final path = await AppUpdateService.instance.downloadUpdate(
        widget.info.downloadUrl,
        onProgress: (p) {
          if (mounted) {
            setState(() {
              _progress = p;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadedFilePath = path;
          _progress = 1.0;
        });

        _installUpdate();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _installUpdate() {
    if (_downloadedFilePath != null) {
      AppUpdateService.instance.launchInstaller(_downloadedFilePath!);
    }
  }

  void _openWebsite() {
    AppUpdateService.instance
        .openUrl('https://github.com/a757675586/ckcp_lamp_flutter');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 450),
        child: Column(
          children: [
            // Title Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    context.tr('upgrade_title'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _isDownloading
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            Expanded(
              child: Row(
                children: [
                  // Left Column: Basic Info
                  Container(
                    width: 280,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cloud_upload,
                                size: 32, color: Color(0xFF1E88E5)),
                            const SizedBox(width: 12),
                            Text(
                              context.tr('upgrade_title'),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildInfoRow(
                            context, 'update_source', widget.info.source),
                        _buildInfoRow(
                            context, 'current_version', AppInfo.version),
                        _buildInfoRow(context, 'latest_version_label',
                            widget.info.version,
                            isHighLight: true),
                        _buildInfoRow(
                            context, 'release_date', widget.info.releaseDate),
                        const Spacer(),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Error: $_errorMessage',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12),
                              maxLines: 2,
                            ),
                          ),
                        if (_isDownloading) ...[
                          LinearProgressIndicator(value: _progress),
                          const SizedBox(height: 8),
                          Text(
                            'Downloading... ${(_progress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // check update logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E88E5),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: Text(context.tr('check_update')),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _openWebsite,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  child: Text(context.tr('official_download')),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _downloadedFilePath != null
                                  ? _installUpdate
                                  : _startDownload,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _downloadedFilePath != null
                                    ? Colors.green
                                    : const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                              ),
                              child: Text(_downloadedFilePath != null
                                  ? 'Install Update'
                                  : context.tr('start_update')),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Right Column: Details
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('new_version_details'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                widget.info.content,
                                style:
                                    const TextStyle(fontSize: 14, height: 1.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String labelKey, String value,
      {bool isHighLight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.tr(labelKey),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighLight ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
