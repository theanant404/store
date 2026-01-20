import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/features/categories/data/categories_api.dart';

import 'package:store/features/categories/data/models/category.dart';
import 'package:uuid/uuid.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _uuid = const Uuid();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  bool _isRemote(String? url) => url != null && url.startsWith('http');

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await CategoryRepository.fetchAllCategories();
      if (mounted) {
        setState(() => _categories = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load categories: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _slugify(String input) {
    final lower = input.trim().toLowerCase();
    final slug = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp('-+'), '-');
    return slug.replaceAll(RegExp(r'^-+|-+?'), '');
  }

  Future<void> _openForm({CategoryModel? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final slugCtrl = TextEditingController(text: existing?.slug ?? '');
    final imageCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    void syncSlug() {
      if (existing == null) {
        slugCtrl.text = _slugify(titleCtrl.text);
      }
    }

    titleCtrl.addListener(syncSlug);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      existing == null ? 'Add Category' : 'Edit Category',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: slugCtrl,
                      readOnly: existing == null,
                      decoration: const InputDecoration(
                        labelText: 'Slug (auto)',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Image URL or local path',
                        prefixIcon: Icon(Icons.link_outlined),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final file = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (file != null) {
                                setSheetState(() {
                                  imageCtrl.text = file.path;
                                });
                              }
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Upload from gallery'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Clear image',
                          onPressed: () {
                            setSheetState(() {
                              imageCtrl.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    if (imageCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _isRemote(imageCtrl.text)
                            ? Image.network(
                                imageCtrl.text,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(imageCtrl.text),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  color: Theme.of(
                                    ctx,
                                  ).colorScheme.surfaceVariant,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                    size: 42,
                                  ),
                                ),
                              ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final title = titleCtrl.text.trim();
                            final slug = slugCtrl.text.trim();
                            if (title.isEmpty || slug.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Title and slug are required'),
                                ),
                              );
                              return;
                            }
                            try {
                              final model = CategoryModel(
                                id: existing?.id ?? _uuid.v4(),
                                title: title,
                                slug: slug,
                                imageUrl: imageCtrl.text.trim().isEmpty
                                    ? null
                                    : imageCtrl.text.trim(),
                                description: descCtrl.text.trim().isEmpty
                                    ? null
                                    : descCtrl.text.trim(),
                              );
                              if (existing == null) {
                                await CategoryRepository.addCategory(model);
                              } else {
                                await CategoryRepository.updateCategory(model);
                              }
                              await _loadCategories();
                              if (mounted) Navigator.of(ctx).pop(true);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          child: Text(existing == null ? 'Add' : 'Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleCtrl.removeListener(syncSlug);
    if (result == true) {
      await _loadCategories();
    }
  }

  Future<void> _delete(String id) async {
    try {
      await CategoryRepository.deleteCategory(id);
      await _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Widget _buildCategoryImage(CategoryModel c, ColorScheme color) {
    if (c.imageUrl != null && c.imageUrl!.isNotEmpty) {
      final url = c.imageUrl!;
      if (_isRemote(url)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52,
              height: 52,
              color: color.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(url),
            width: 52,
            height: 52,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 52,
              height: 52,
              color: color.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      }
    }

    return CircleAvatar(
      backgroundColor: color.primaryContainer,
      child: Text(c.title.isNotEmpty ? c.title[0].toUpperCase() : '?'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? const Center(child: Text('No categories yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final c = _categories[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: _buildCategoryImage(c, color),
                    title: Text(c.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Slug: ${c.slug}'),
                        if (c.description != null)
                          Text(
                            c.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    isThreeLine: c.description != null,
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openForm(existing: c),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(c.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
