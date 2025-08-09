// lib/pages/admin_page.dart
import 'package:flutter/material.dart';
import '../backend/admin.dart';
import '../backend/song.dart';

class AdminPortal extends StatefulWidget {
  final Admin admin;
  const AdminPortal({Key? key, required this.admin}) : super(key: key);

  @override
  State<AdminPortal> createState() => _AdminPortalState();
}

class _AdminPortalState extends State<AdminPortal> {
  String _selected = "";

  void _navigate(String page) {
    setState(() => _selected = page);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (page == "Add Song") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddSongPage(admin: widget.admin)),
        );
      } else if (page == "Remove Song") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RemoveSongPage(admin: widget.admin)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ["Add Song", "Remove Song"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Portal"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: menuItems.map((item) {
            final bool isSelected = _selected == item;
            return GestureDetector(
              onTap: () => _navigate(item),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: isSelected ? 40 : 28,
                  color: Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(item),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// ----------------- ADD SONG PAGE -----------------
class AddSongPage extends StatefulWidget {
  final Admin admin;
  const AddSongPage({Key? key, required this.admin}) : super(key: key);

  @override
  State<AddSongPage> createState() => _AddSongPageState();
}

class _AddSongPageState extends State<AddSongPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _songNameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _artistNameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _songNameController.dispose();
    _urlController.dispose();
    _durationController.dispose();
    _genreController.dispose();
    _artistNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      // Use the admin object's addSong method (admin function)
      final int songId = await widget.admin.addSong(
        songName: _songNameController.text.trim(),
        url: _urlController.text.trim(),
        duration: _durationController.text.trim().isEmpty
            ? null
            : _durationController.text.trim(),
        genre: _genreController.text.trim().isEmpty
            ? null
            : _genreController.text.trim(),
        artistName: _artistNameController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Song added successfully (ID: $songId)")),
      );

      // Optionally clear fields or pop back
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add song: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Song"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildTextField(
                    controller: _songNameController,
                    label: "Song Name *",
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _urlController,
                    label: "URL *",
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _durationController,
                    label: "Duration (optional)",
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _genreController,
                    label: "Genre (optional)",
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _artistNameController,
                    label: "Artist Name *",
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text("Add Song"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ----------------- REMOVE SONG PAGE -----------------
class RemoveSongPage extends StatefulWidget {
  final Admin admin;
  const RemoveSongPage({Key? key, required this.admin}) : super(key: key);

  @override
  State<RemoveSongPage> createState() => _RemoveSongPageState();
}

class _RemoveSongPageState extends State<RemoveSongPage> {
  List<Song> _songs = [];
  final Set<int> _selectedSongIds = {};
  bool _isLoading = true;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    setState(() => _isLoading = true);
    try {
      // Use the Song class's getSongs static function (song function)
      final List<Map<String, dynamic>> songMaps = await Song.getSongs();
      final fetched = songMaps.map((m) => Song.fromMap(m)).toList();
      setState(() {
        _songs = fetched;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching songs: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSelectedSongs() async {
    if (_selectedSongIds.isEmpty) return;
    setState(() => _isRemoving = true);
    try {
      // Remove each selected song using the admin object's removeSong method
      final toRemove = _songs.where((s) => _selectedSongIds.contains(s.songId)).toList();
      for (final song in toRemove) {
        await widget.admin.removeSong(song);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected songs removed.")),
      );

      // Refresh list & clear selection
      await _fetchSongs();
      setState(() => _selectedSongIds.clear());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error removing songs: ${e.toString()}")),
      );
    } finally {
      setState(() => _isRemoving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Remove Song"),
        actions: [
          if (_selectedSongIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: _isRemoving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.delete),
                onPressed: _isRemoving ? null : _removeSelectedSongs,
                tooltip: "Remove selected songs",
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _songs.isEmpty
              ? const Center(child: Text("No songs found."))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _songs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final bool isSelected = _selectedSongIds.contains(song.songId);
                    return ListTile(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedSongIds.remove(song.songId);
                          } else {
                            _selectedSongIds.add(song.songId);
                          }
                        });
                      },
                      leading: Checkbox(
                        value: isSelected,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedSongIds.add(song.songId);
                            } else {
                              _selectedSongIds.remove(song.songId);
                            }
                          });
                        },
                      ),
                      title: Text(song.songName),
                      subtitle: Text(song.artistName ?? "Unknown Artist"),
                      trailing: Text(song.genre ?? ""),
                    );
                  },
                ),
      floatingActionButton: _songs.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _selectedSongIds.isEmpty || _isRemoving ? null : _removeSelectedSongs,
              label: _isRemoving ? const Text("Removing...") : const Text("Remove Selected"),
              icon: _isRemoving ? const SizedBox.shrink() : const Icon(Icons.delete),
            )
          : null,
    );
  }
}
