import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store/features/categories/data/categories_api.dart';
import 'package:store/features/categories/data/models/category.dart';
import 'package:store/features/product/data/model/product.dart';
import 'package:store/features/product/data/product_repository.dart';
import 'package:uuid/uuid.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        CategoryRepository.fetchAllCategories(),
        ProductRepository.fetchAllProducts(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<CategoryModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    try {
      await ProductRepository.fetchAllProducts();
      if (mounted) {
        // Products are cached in repository; trigger filter recompute via setState
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to refresh products: $e')),
        );
      }
    }
  }

  List<ProductModel> _getFilteredProducts() {
    return ProductRepository.filterProducts(
      categoryId: _selectedCategoryId,
      searchQuery: _searchQuery,
    );
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await ProductRepository.deleteProduct(id);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  bool _isRemote(String? url) => url != null && url.startsWith('http');

  Widget _buildProductImage(ProductModel p, ColorScheme color) {
    if (p.imageUrls.isNotEmpty) {
      final url = p.imageUrls.first;
      if (_isRemote(url)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            headers: const {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Mobile/15E148 Safari/604.1',
              'Accept': '*/*',
              'Accept-Language': 'en-US,en;q=0.9',
              'Referer': 'https://pixabay.com/',
            },
            cacheWidth: 120,
            cacheHeight: 120,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: color.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                width: 60,
                height: 60,
                color: color.surfaceVariant,
                child: const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(url),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 60,
              height: 60,
              color: color.surfaceVariant,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        );
      }
    }
    return CircleAvatar(
      backgroundColor: color.primaryContainer,
      child: Text(p.title.isNotEmpty ? p.title[0].toUpperCase() : '?'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final filtered = _getFilteredProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('Products'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openProductForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: const Text('All'),
                                selected: _selectedCategoryId == null,
                                onSelected: (selected) {
                                  setState(() => _selectedCategoryId = null);
                                },
                              ),
                            ),
                            ..._categories.map(
                              (cat) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(cat.title),
                                  selected: _selectedCategoryId == cat.id,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategoryId = selected
                                          ? cat.id
                                          : null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No products found'))
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              final p = filtered[index];
                              final lowestPrice = p.varieties.isNotEmpty
                                  ? p.varieties
                                        .map((v) => v.price)
                                        .reduce((a, b) => a < b ? a : b)
                                  : 0.0;

                              return Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: _buildProductImage(p, color),
                                  title: Text(p.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'From  ₹${lowestPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _openProductForm(
                                          context,
                                          existing: p,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () => _deleteProduct(p.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Future<void> _openProductForm(
    BuildContext context, {
    ProductModel? existing,
  }) async {
    if (_categories.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add a category first.')));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => ProductFormSheet(
        existingProduct: existing,
        categories: _categories,
        onSave: (product) async {
          if (existing == null) {
            await ProductRepository.addProduct(product);
          } else {
            await ProductRepository.updateProduct(product);
          }
          await _refresh();
          if (mounted) {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  existing == null ? 'Product added' : 'Product updated',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ProductFormSheet extends StatefulWidget {
  final ProductModel? existingProduct;
  final List<CategoryModel> categories;
  final Future<void> Function(ProductModel) onSave;

  const ProductFormSheet({
    this.existingProduct,
    required this.categories,
    required this.onSave,
  });

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late String _selectedCategoryId;
  late List<String> _imageUrls;
  late List<ProductVariety> _varieties;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(
      text: widget.existingProduct?.title ?? '',
    );
    _descCtrl = TextEditingController(
      text: widget.existingProduct?.description ?? '',
    );
    _selectedCategoryId =
        widget.existingProduct?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first.id : '');
    _imageUrls = List.from(widget.existingProduct?.imageUrls ?? []);
    _varieties = List.from(widget.existingProduct?.varieties ?? []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _addImageUrl() async {
    if (_imageUrls.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 4 images allowed')));
      return;
    }
    final url = await showDialog<String?>(
      context: context,
      builder: (ctx) => const AddImageUrlDialog(),
    );
    if (url != null && url.isNotEmpty) {
      setState(() {
        _imageUrls.add(url);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_imageUrls.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Maximum 4 images allowed')));
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      setState(() {
        _imageUrls.add(file.path);
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('Add Image URL'),
              onTap: () {
                Navigator.pop(ctx);
                _addImageUrl();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  void _addVariety() {
    setState(() {
      _varieties.add(ProductVariety(id: _uuid.v4(), price: 0, stock: 0));
    });
  }

  void _removeVariety(int index) {
    setState(() {
      _varieties.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existingProduct == null ? 'Add Product' : 'Edit Product',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Title',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: widget.categories
                  .map(
                    (cat) =>
                        DropdownMenuItem(value: cat.id, child: Text(cat.title)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Product Images (Max 4)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final isRemote = _imageUrls[i].startsWith('http');
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isRemote
                              ? Image.network(
                                  _imageUrls[i],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  headers: const {
                                    'User-Agent':
                                        'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.4 Mobile/15E148 Safari/604.1',
                                    'Accept': '*/*',
                                    'Accept-Language': 'en-US,en;q=0.9',
                                  },
                                  cacheWidth: 200,
                                  cacheHeight: 200,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceVariant,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, error, __) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(_imageUrls[i]),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    height: 100,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceVariant,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                    ),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withAlpha(200),
                            ),
                            onPressed: () => _removeImage(i),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: _imageUrls.length < 4 ? _showImageOptions : null,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text('Add Image (${_imageUrls.length}/4)'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add images via URL or pick from gallery.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text('Varieties', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._varieties.asMap().entries.map((e) {
              final i = e.key;
              final variety = e.value;
              return VarietyCard(
                variety: variety,
                index: i,
                onUpdate: (updated) {
                  setState(() {
                    _varieties[i] = updated;
                  });
                },
                onRemove: () => _removeVariety(i),
              );
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _addVariety,
              icon: const Icon(Icons.add),
              label: const Text('Add Variety'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final title = _titleCtrl.text.trim();
                    final desc = _descCtrl.text.trim();
                    if (title.isEmpty ||
                        desc.isEmpty ||
                        _varieties.isEmpty ||
                        _imageUrls.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Title, description, images, and at least one variety are required',
                          ),
                        ),
                      );
                      return;
                    }
                    final product = ProductModel(
                      id: widget.existingProduct?.id ?? _uuid.v4(),
                      title: title,
                      description: desc,
                      categoryId: _selectedCategoryId,
                      imageUrls: _imageUrls,
                      varieties: _varieties,
                    );
                    try {
                      await widget.onSave(product);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save: $e')),
                        );
                      }
                    }
                  },
                  child: Text(widget.existingProduct == null ? 'Add' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dialog widget for adding image URL ---
class AddImageUrlDialog extends StatefulWidget {
  const AddImageUrlDialog({super.key});

  @override
  State<AddImageUrlDialog> createState() => _AddImageUrlDialogState();
}

class _AddImageUrlDialogState extends State<AddImageUrlDialog> {
  late final TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _urlCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final url = _urlCtrl.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL cannot be empty')));
      return;
    }
    if (!url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL must start with http/https')),
      );
      return;
    }
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Image URL'),
      content: TextField(
        controller: _urlCtrl,
        decoration: const InputDecoration(
          hintText: 'Enter image URL (e.g., https://...)',
          labelText: 'Image URL',
        ),
        keyboardType: TextInputType.url,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}

class VarietyCard extends StatefulWidget {
  final ProductVariety variety;
  final int index;
  final Function(ProductVariety) onUpdate;
  final VoidCallback onRemove;

  const VarietyCard({
    required this.variety,
    required this.index,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  State<VarietyCard> createState() => _VarietyCardState();
}

class _VarietyCardState extends State<VarietyCard> {
  late TextEditingController _priceCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _stockCtrl;
  late String _quantityUnit;

  final List<String> _quantityUnits = [
    'pcs',
    'kg',
    'g',
    'ml',
    'l',
    'box',
    'pack',
    'dozen',
  ];

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
      text: widget.variety.price.toStringAsFixed(2),
    );
    _weightCtrl = TextEditingController(
      text: widget.variety.weight?.toString() ?? '',
    );
    _quantityCtrl = TextEditingController(
      text: widget.variety.quantity?.toString() ?? '',
    );
    _discountCtrl = TextEditingController(
      text: widget.variety.discount?.toStringAsFixed(2) ?? '',
    );
    _stockCtrl = TextEditingController(text: widget.variety.stock.toString());
    _quantityUnit = widget.variety.quantityUnit ?? 'pcs';
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _weightCtrl.dispose();
    _quantityCtrl.dispose();
    _discountCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _updateVariety() {
    final updated = widget.variety.copyWith(
      price: double.tryParse(_priceCtrl.text) ?? 0,
      weight: double.tryParse(_weightCtrl.text),
      quantity: int.tryParse(_quantityCtrl.text),
      quantityUnit: _quantityUnit,
      discount: double.tryParse(_discountCtrl.text),
      stock: int.tryParse(_stockCtrl.text) ?? 0,
    );
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Variety ${widget.index + 1}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                    onChanged: (_) => _updateVariety(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _discountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Discount %',
                      prefixIcon: Icon(Icons.local_offer_outlined),
                    ),
                    onChanged: (_) => _updateVariety(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stockCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Stock',
                      prefixIcon: Icon(Icons.inventory_2_outlined),
                    ),
                    onChanged: (_) => _updateVariety(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                    onChanged: (_) => _updateVariety(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    onChanged: (_) => _updateVariety(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _quantityUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      prefixIcon: Icon(Icons.straighten_outlined),
                    ),
                    items: _quantityUnits
                        .map(
                          (unit) =>
                              DropdownMenuItem(value: unit, child: Text(unit)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _quantityUnit = value;
                        });
                        _updateVariety();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
