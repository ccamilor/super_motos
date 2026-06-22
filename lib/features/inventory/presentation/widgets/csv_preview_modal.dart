import 'package:flutter/material.dart';
import 'package:super_motos/features/inventory/data/services/inventory_csv_parser.dart';
import 'package:super_motos/features/inventory/domain/entities/inventory_entry.dart';

class CsvPreviewResult {
  final List<InventoryEntry> entries;
  final int newProducts;
  final int existingProducts;
  final List<String> errors;

  const CsvPreviewResult({
    required this.entries,
    required this.newProducts,
    required this.existingProducts,
    required this.errors,
  });

  int get totalRows => entries.length;
  bool get hasErrors => errors.isNotEmpty;
}

class CsvPreviewModal extends StatefulWidget {
  final String csvContent;
  final Set<String> existingProductCodes;

  const CsvPreviewModal({
    super.key,
    required this.csvContent,
    required this.existingProductCodes,
  });

  @override
  State<CsvPreviewModal> createState() => _CsvPreviewModalState();
}

class _CsvPreviewModalState extends State<CsvPreviewModal> {
  late CsvPreviewResult _result;
  bool _isValid = false;

  static const List<String> _requiredColumns = [
    'codigo',
    'nombre',
    'precio',
  ];

  static const List<String> _optionalColumns = [
    'is_original',
    'motos_compatibles',
    'stock_minimo',
    'cantidad_camion',
    'canasta_id',
    'cantidad_bodega',
  ];

  @override
  void initState() {
    super.initState();
    _analyzeCsv();
  }

  void _analyzeCsv() {
    final lines = widget.csvContent.split('\n');
    if (lines.isEmpty) {
      _result = CsvPreviewResult(
        entries: [],
        newProducts: 0,
        existingProducts: 0,
        errors: ['El archivo CSV está vacío'],
      );
      return;
    }

    final header = lines.first.toLowerCase().split(',').map((c) => c.trim()).toList();
    final missingColumns = <String>[];

    for (final col in _requiredColumns) {
      if (!header.contains(col)) {
        missingColumns.add(col);
      }
    }

    if (missingColumns.isNotEmpty) {
      _result = CsvPreviewResult(
        entries: [],
        newProducts: 0,
        existingProducts: 0,
        errors: [
          'Faltan columnas requeridas: ${missingColumns.join(', ')}',
          'Columnas esperadas: ${_requiredColumns.join(', ')}',
          'Columnas encontradas: ${header.join(', ')}',
        ],
      );
      return;
    }

    final parser = const InventoryCsvParser();
    final entries = parser.parse(widget.csvContent);

    if (entries.isEmpty) {
      _result = CsvPreviewResult(
        entries: [],
        newProducts: 0,
        existingProducts: 0,
        errors: ['No se encontraron filas de datos válidas en el CSV'],
      );
      return;
    }

    int newCount = 0;
    int existingCount = 0;

    for (final entry in entries) {
      if (widget.existingProductCodes.contains(entry.codigo)) {
        existingCount++;
      } else {
        newCount++;
      }
    }

    _result = CsvPreviewResult(
      entries: entries,
      newProducts: newCount,
      existingProducts: existingCount,
      errors: [],
    );
    _isValid = true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewEntries = _result.entries.take(5).toList();

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_result.hasErrors) ...[
                      _buildErrorSection(colorScheme),
                    ] else ...[
                      _buildStatsSection(colorScheme),
                      const SizedBox(height: 16),
                      _buildPreviewTable(colorScheme, previewEntries),
                      if (_result.totalRows > 5) ...[
                        const SizedBox(height: 8),
                        Text(
                          '... y ${_result.totalRows - 5} productos más',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            _buildActions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _result.hasErrors ? Icons.error_outline : Icons.preview,
            color: _result.hasErrors ? colorScheme.error : colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _result.hasErrors ? 'Error en el CSV' : 'Vista previa del CSV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'No se puede importar este archivo',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._result.errors.map((error) => Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              error,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            colorScheme: colorScheme,
            icon: Icons.add_circle_outline,
            label: 'Nuevos',
            value: '${_result.newProducts}',
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            colorScheme: colorScheme,
            icon: Icons.update,
            label: 'Actualizar',
            value: '${_result.existingProducts}',
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            colorScheme: colorScheme,
            icon: Icons.list_alt,
            label: 'Total',
            value: '${_result.totalRows}',
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewTable(ColorScheme colorScheme, List<InventoryEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(0.8),
            4: FlexColumnWidth(0.8),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              children: [
                _buildHeaderCell('Código', colorScheme),
                _buildHeaderCell('Nombre', colorScheme),
                _buildHeaderCell('Precio', colorScheme),
                _buildHeaderCell('Camión', colorScheme),
                _buildHeaderCell('Bodega', colorScheme),
              ],
            ),
            ...entries.map((entry) => TableRow(
              decoration: BoxDecoration(
                color: widget.existingProductCodes.contains(entry.codigo)
                    ? colorScheme.secondary.withValues(alpha: 0.05)
                    : null,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
                ),
              ),
              children: [
                _buildCell(entry.codigo, colorScheme),
                _buildCell(entry.nombre, colorScheme, maxLines: 2),
                _buildCell(_formatCOP(entry.precio), colorScheme),
                _buildCell('${entry.cantidadCamion}', colorScheme),
                _buildCell('${entry.cantidadBodega}', colorScheme),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCell(String text, ColorScheme colorScheme, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatCOP(double precio) {
    final valorEntero = precio.toInt();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formateado = valorEntero.toString().replaceAllMapped(reg, (match) => '${match[1]}.');
    return '\$ $formateado';
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: ElevatedButton.icon(
              onPressed: _isValid ? () => Navigator.of(context).pop(_result) : null,
              icon: const Icon(Icons.download, size: 18),
              label: Text(
                _result.hasErrors
                    ? 'No se puede importar'
                    : 'Importar ${_result.totalRows} productos',
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                disabledForegroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
