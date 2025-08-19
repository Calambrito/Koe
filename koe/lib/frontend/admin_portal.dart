// lib/frontend/admin_portal.dart
import 'package:flutter/material.dart';
import '../backend/admin.dart';
import '../backend/song.dart';
import '../backend/koe_palette.dart';
import '../widgets/nowplaying.dart';
import '../widgets/custom_nav_tabs.dart';

class AdminPortal extends StatefulWidget {
  final Admin admin;

  const AdminPortal({super.key, required this.admin});

  @override
  State<AdminPortal> createState() => _AdminPortalState();
}

class _AdminPortalState extends State<AdminPortal> {
  int _selectedTabIndex = 0;
  List<Song> _songs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    setState(() => _isLoading = true);
    try {
      final songs = await widget.admin.getAllSongs();
      setState(() {
        _songs = songs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading songs: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Admin Portal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom navigation tabs
          CustomNavTabs(
            selectedIndex: _selectedTabIndex,
            onTabSelected: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            currentTheme: widget.admin.theme,
          ),

          // Main content area
          Expanded(child: _buildTabContent()),

          // Now playing bar
          const NowPlayingBar(),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: _showUploadDialog,
              backgroundColor: KoePalette.shade(
                widget.admin.theme.paletteName,
                'main',
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildMusicManagementTab();
      case 1:
        return Center(
          child: Text(
            'Discover Page - Admin View',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      case 2:
        return Center(
          child: Text(
            'Playlists Page - Admin View',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      case 3:
        return Center(
          child: Text(
            'Notifications Page - Admin View',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        );
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildMusicManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: KoePalette.shade(widget.admin.theme.paletteName, 'main'),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Music Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your music library - ${_songs.length} songs',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showUploadDialog,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload Single Song'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KoePalette.shade(
                      widget.admin.theme.paletteName,
                      'main',
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showBatchUploadDialog,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Batch Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KoePalette.shade(
                      widget.admin.theme.paletteName,
                      'dark',
                    ),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Songs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No songs uploaded yet',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start by uploading your first song!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _songs.length,
                    itemBuilder: (context, index) {
                      final song = _songs[index];
                      return _buildSongCard(song);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: KoePalette.shade(widget.admin.theme.paletteName, 'main'),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 24),
        ),
        title: Text(
          song.songName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              song.artistName ?? 'Unknown Artist',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            if (song.duration != null) ...[
              const SizedBox(height: 2),
              Text(
                'Duration: ${song.duration}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              onPressed: () => _playSong(song),
              tooltip: 'Play',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteSong(song),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playSong(Song song) async {
    try {
      await song.play();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Now playing: ${song.songName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing song: $e')));
      }
    }
  }

  Future<void> _deleteSong(Song song) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${song.songName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.admin.removeSong(song);
        await _loadSongs();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Deleted: ${song.songName}')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error deleting song: $e')));
        }
      }
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => SingleSongUploadDialog(admin: widget.admin),
    ).then((_) => _loadSongs());
  }

  void _showBatchUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => BatchUploadDialog(admin: widget.admin),
    ).then((_) => _loadSongs());
  }
}

class SingleSongUploadDialog extends StatefulWidget {
  final Admin admin;

  const SingleSongUploadDialog({super.key, required this.admin});

  @override
  State<SingleSongUploadDialog> createState() => _SingleSongUploadDialogState();
}

class _SingleSongUploadDialogState extends State<SingleSongUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _artistController = TextEditingController();
  final _songNameController = TextEditingController();
  final _durationController = TextEditingController();
  final _urlController = TextEditingController();
  final _genreController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _artistController.dispose();
    _songNameController.dispose();
    _durationController.dispose();
    _urlController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Single Song'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _artistController,
                decoration: const InputDecoration(
                  labelText: 'Artist Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _songNameController,
                decoration: const InputDecoration(
                  labelText: 'Song Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter song name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g., 3:45)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Music URL *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter music URL';
                  }
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasAbsolutePath) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Genre',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadSong,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }

  Future<void> _uploadSong() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);

    try {
      // Use the current admin instance from the widget
      await widget.admin.addSong(
        artistName: _artistController.text.trim(),
        songName: _songNameController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        url: _urlController.text.trim(),
        genre: _genreController.text.trim().isEmpty
            ? null
            : _genreController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Song uploaded successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading song: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}

class BatchUploadDialog extends StatefulWidget {
  final Admin admin;

  const BatchUploadDialog({super.key, required this.admin});

  @override
  State<BatchUploadDialog> createState() => _BatchUploadDialogState();
}

class _BatchUploadDialogState extends State<BatchUploadDialog> {
  final _textController = TextEditingController();
  bool _isUploading = false;
  List<Map<String, dynamic>>? _uploadResults;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batch Upload Songs'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter song details in the following format:\n'
              'Artist Name | Song Name | Duration | URL | Genre\n'
              'One song per line. Duration and Genre are optional.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Artist Name | Song Title | 3:45 | https://example.com/song.mp3 | Pop\n'
                    'Another Artist | Another Song | 4:20 | https://example.com/song2.mp3 | Rock',
              ),
            ),
            if (_uploadResults != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Upload Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _uploadResults!.length,
                  itemBuilder: (context, index) {
                    final result = _uploadResults![index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        result['success'] ? Icons.check_circle : Icons.error,
                        color: result['success'] ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        '${result['songName']} - ${result['artistName']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: result['success']
                          ? null
                          : Text(
                              result['error'] ?? 'Unknown error',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUploading ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _isUploading ? null : _uploadBatch,
          child: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Upload Batch'),
        ),
      ],
    );
  }

  Future<void> _uploadBatch() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter song details')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final lines = text.split('\n');
      final songs = <Map<String, String>>[];

      for (final line in lines) {
        final parts = line.split('|').map((e) => e.trim()).toList();
        if (parts.length >= 4) {
          songs.add({
            'artistName': parts[0],
            'songName': parts[1],
            'duration': parts.length > 2 ? parts[2] : '',
            'url': parts[3],
            'genre': parts.length > 4 ? parts[4] : '',
          });
        }
      }

      if (songs.isEmpty) {
        throw Exception('No valid songs found');
      }

      // Use the admin instance passed to the dialog
      final results = await widget.admin.batchAddSongs(songs);

      setState(() {
        _uploadResults = results;
        _isUploading = false;
      });

      final successCount = results.where((r) => r['success']).length;
      final totalCount = results.length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploaded $successCount out of $totalCount songs'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading batch: $e')));
      }
    }
  }
}
