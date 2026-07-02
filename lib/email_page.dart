import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:html_unescape/html_unescape_small.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart'
    hide TableRow;

void main() {
  runApp(
    const MaterialApp(
      home: EmailWorkspaceContainer(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class EmailWorkspaceContainer extends StatelessWidget {
  const EmailWorkspaceContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmailTemplateBuilder());
  }
}

class CellData {
  final quill.QuillController controller;
  final FocusNode focusNode;

  CellData({required this.controller, required this.focusNode});

  void dispose(VoidCallback listener) {
    controller.removeListener(listener);
    controller.dispose();
    focusNode.dispose();
  }
}

final Map<String, InlineTableState> globalTableRegistry = {};

class InlineTableState {
  final String id;
  int rows;
  int cols;
  List<List<CellData>> grid;
  VoidCallback onStateMutated;

  InlineTableState({
    required this.id,
    this.rows = 2,
    this.cols = 2,
    required this.onStateMutated,
  }) : grid = [] {
    grid = List.generate(
      rows,
      (_) => List.generate(cols, (_) => _createNewCell()),
    );
  }

  CellData _createNewCell() {
    final controller = quill.QuillController.basic();
    final focusNode = FocusNode();
    controller.addListener(onStateMutated);
    return CellData(controller: controller, focusNode: focusNode);
  }

  void updateDimensions(int newRows, int newCols) {
    if (newRows > rows) {
      for (int i = rows; i < newRows; i++) {
        grid.add(List.generate(cols, (_) => _createNewCell()));
      }
    } else if (newRows < rows) {
      for (int i = newRows; i < rows; i++) {
        for (var cell in grid[i]) {
          cell.dispose(onStateMutated);
        }
      }
      grid = grid.sublist(0, newRows);
    }
    rows = newRows;

    for (int i = 0; i < rows; i++) {
      if (newCols > cols) {
        for (int j = cols; j < newCols; j++) {
          grid[i].add(_createNewCell());
        }
      } else if (newCols < cols) {
        for (int j = newCols; j < cols; j++) {
          grid[i][j].dispose(onStateMutated);
        }
        grid[i] = grid[i].sublist(0, newCols);
      }
    }
    cols = newCols;
    onStateMutated();
  }

  void dispose() {
    for (var row in grid) {
      for (var cell in row) {
        cell.dispose(onStateMutated);
      }
    }
  }
}

class DynamicTableEmbedBuilder extends quill.EmbedBuilder {
  final VoidCallback onTableContentChanged;
  final Function(String) onDeleteRequested;
  final Function(quill.QuillController) onCellTextChanged;

  DynamicTableEmbedBuilder({
    required this.onTableContentChanged,
    required this.onDeleteRequested,
    required this.onCellTextChanged,
  });

  @override
  String get key => 'custom_inline_table';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final String tableId = embedContext.node.value.data.toString();
    final tableState = globalTableRegistry[tableId];

    if (tableState == null) {
      return const SizedBox(
        height: 35,
        child: Center(child: Text('[Table Workspace Mapping Conflicted]')),
      );
    }

    return StatefulBuilder(
      builder: (context, localSetState) {
        tableState.onStateMutated = () {
          localSetState(() {});
          onTableContentChanged();
        };

        return Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200, width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EMBEDDED DATA MATRIX ($tableId)',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.green,
                              size: 16,
                            ),
                            onPressed: () => tableState.updateDimensions(
                              tableState.rows + 1,
                              tableState.cols,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.remove,
                              color: Colors.orange,
                              size: 16,
                            ),
                            onPressed: () {
                              if (tableState.rows > 1) {
                                tableState.updateDimensions(
                                  tableState.rows - 1,
                                  tableState.cols,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(
                              Icons.view_column,
                              color: Colors.green,
                              size: 16,
                            ),
                            onPressed: () => tableState.updateDimensions(
                              tableState.rows,
                              tableState.cols + 1,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.view_column_outlined,
                              color: Colors.orange,
                              size: 16,
                            ),
                            onPressed: () {
                              if (tableState.cols > 1) {
                                tableState.updateDimensions(
                                  tableState.rows,
                                  tableState.cols - 1,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                              size: 16,
                            ),
                            onPressed: () => onDeleteRequested(tableId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade300),
                    children: List.generate(tableState.rows, (r) {
                      return TableRow(
                        children: List.generate(tableState.cols, (c) {
                          final cell = tableState.grid[r][c];
                          return Container(
                            padding: const EdgeInsets.all(6),
                            height: 50,
                            color: r == 0
                                ? Colors.blue.shade50
                                : (r % 2 == 0
                                      ? Colors.grey.shade50
                                      : Colors.white),
                            child: quill.QuillEditor(
                              controller: cell.controller,
                              focusNode: cell.focusNode,
                              scrollController: ScrollController(),
                              config: quill.QuillEditorConfig(
                                autoFocus: false,
                                scrollable: false,
                                expands: false,
                                padding: EdgeInsets.zero,
                                // onKeyDown: (event) {
                                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                //     onCellTextChanged(cell.controller);
                                //   });
                                //   return false;
                                // },
                                onKeyPressed: (event, node) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    onCellTextChanged(cell.controller);
                                  });
                                },
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EmailTemplateBuilder extends StatefulWidget {
  const EmailTemplateBuilder({Key? key}) : super(key: key);

  @override
  State<EmailTemplateBuilder> createState() => _EmailTemplateBuilderState();
}

class _EmailTemplateBuilderState extends State<EmailTemplateBuilder> {
  late quill.QuillController _mainTextController;
  late FocusNode _mainFocusNode;
  OverlayEntry? _autocompleteOverlay;
  int _tableIdCounter = 1;
  String _currentHtmlPreview = '';

  final List<Map<String, String>> _systemTokens = [
    {
      'label': 'Customer Name',
      'token': '{{customer_name}}',
      'value': 'Accesspl',
    },
    {'label': 'Order ID', 'token': '{{order_id}}', 'value': '56,000'},
    {'label': 'Total Amount', 'token': '{{total_amount}}', 'value': '23,000'},
    {
      'label': 'Shipping Address',
      'token': '{{shipping_address}}',
      'value': '1122, 3rd main \n bangalore',
    },
    {
      'label': 'Company Name',
      'token': '{{company_name}}',
      'value': 'ABC COMPANY \n <br> Mysore',
    },
    {
      'label': 'powered by',
      'token': '{{powered_by}}',
      'value':
          '<a href="https://talkingtotals.ai", style="color:blue, ">Talkingtotals.ai</a>',
    },
    {
      'label': 'Table Render',
      'token': '{{table_render}}',
      'value': ''' <!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Daily Financial Summary</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        padding: 20px;
      }

      h2 {
        text-align: center;
      }

      table {
        width: 100%;
        border-collapse: collapse;
        background: #fff;
      }

      th,
      td {
        border: 1px solid #ccc;
        padding: 10px;
        text-align: center;
      }

      th {
        background-color: #2c3e50;
        color: white;
      }

      tr:nth-child(even) {
        background-color: #f9f9f9;
      }

      .income {
        color: green;
        font-weight: bold;
      }

      .expense {
        color: red;
        font-weight: bold;
      }

      tfoot td {
        font-weight: bold;
        background-color: #ecf0f1;
      }
    </style>
  </head>
  <body>
    <h2>Daily Financial Summary</h2>

    <table>
      <thead>
        <tr>
          <th>Date</th>
          <th>Description</th>
          <th>Category</th>
          <th>Income (₹)</th>
          <th>Expense (₹)</th>
          <th>Balance (₹)</th>
        </tr>
      </thead>

      <tbody>
        <tr>
          <td>02-Jul-2026</td>
          <td>Salary</td>
          <td>Income</td>
          <td class="income">5,000.00</td>
          <td>-</td>
          <td>5,000.00</td>
        </tr>

        <tr>
          <td>02-Jul-2026</td>
          <td>Groceries</td>
          <td>Food</td>
          <td>-</td>
          <td class="expense">850.00</td>
          <td>4,150.00</td>
        </tr>

        <tr>
          <td>02-Jul-2026</td>
          <td>Fuel</td>
          <td>Transport</td>
          <td>-</td>
          <td class="expense">500.00</td>
          <td>3,650.00</td>
        </tr>

        <tr>
          <td>02-Jul-2026</td>
          <td>Freelance Payment</td>
          <td>Income</td>
          <td class="income">2,000.00</td>
          <td>-</td>
          <td>5,650.00</td>
        </tr>
      </tbody>

      <tfoot>
        <tr>
          <td colspan="3">Totals</td>
          <td>₹7,000.00</td>
          <td>₹1,350.00</td>
          <td>₹5,650.00</td>
        </tr>
      </tfoot>
    </table>
  </body>
</html>''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _mainTextController = quill.QuillController.basic();
    _mainFocusNode = FocusNode();
    _mainTextController.addListener(_onMainTextModified);
    _updateHtmlPreview();
  }

  @override
  void dispose() {
    _mainTextController.removeListener(_onMainTextModified);
    _mainTextController.dispose();
    _mainFocusNode.dispose();
    for (var table in globalTableRegistry.values) {
      table.dispose();
    }
    globalTableRegistry.clear();
    _closeAutocompleteMenu();
    super.dispose();
  }

  void _onMainTextModified() {
    _updateHtmlPreview();
    _checkForTokenTrigger(_mainTextController);
  }

  void _updateHtmlPreview() {
    final freshHtml = _compileEntireCanvasToHtml();
    if (_currentHtmlPreview != freshHtml) {
      setState(() {
        _currentHtmlPreview = freshHtml;
      });
    }
  }

  void _checkForTokenTrigger(quill.QuillController controller) {
    final text = controller.document.toPlainText();
    final selection = controller.selection;

    if (selection.isCollapsed && selection.baseOffset > 0) {
      final textBeforeCursor = text.substring(0, selection.baseOffset);
      final int lastTriggerIdx = textBeforeCursor.lastIndexOf('{{');

      if (lastTriggerIdx != -1) {
        final String textSinceTrigger = textBeforeCursor.substring(
          lastTriggerIdx,
        );
        if (!textSinceTrigger.contains('}}') &&
            !textSinceTrigger.contains('\n')) {
          final String currentQueryFilter = textSinceTrigger.substring(2);
          _showTokenSuggestionsMenu(
            controller,
            lastTriggerIdx + 2 + currentQueryFilter.length,
            currentQueryFilter,
            lastTriggerIdx,
          );
          return;
        }
      }
    }
    _closeAutocompleteMenu();
  }

  void _showTokenSuggestionsMenu(
    quill.QuillController controller,
    int cursorIndex,
    String query,
    int triggerStartIndex,
  ) {
    _closeAutocompleteMenu();

    final filteredTokens = _systemTokens.where((tokenObj) {
      final label = tokenObj['label']!.toLowerCase();
      final token = tokenObj['token']!.toLowerCase();
      final q = query.toLowerCase();
      return label.contains(q) || token.contains(q);
    }).toList();

    if (filteredTokens.isEmpty) return;

    _autocompleteOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeAutocompleteMenu,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              width: 240,
              height: filteredTokens.length > 2
                  ? 200
                  : (filteredTokens.length * 60 + 12).toDouble(),
              top: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.35,
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: filteredTokens.map((tokenObj) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        tokenObj['label']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        tokenObj['token']!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () {
                        final tokenText = tokenObj['token']!;
                        final int charsToReplace =
                            cursorIndex - triggerStartIndex;

                        // 1. Remove user typed segment and insert token cleanly
                        controller.replaceText(
                          triggerStartIndex,
                          charsToReplace,
                          tokenText,
                          TextSelection.collapsed(
                            offset: triggerStartIndex + tokenText.length,
                          ),
                        );

                        // 2. Format token to be bold in-place cleanly without block wrap side effects
                        controller.formatText(
                          triggerStartIndex,
                          tokenText.length,
                          quill.Attribute.bold,
                        );

                        // 3. Append trailing white-space separated from formatting
                        controller.replaceText(
                          triggerStartIndex + tokenText.length,
                          0,
                          ' ',
                          TextSelection.collapsed(
                            offset: triggerStartIndex + tokenText.length + 1,
                          ),
                        );

                        // 4. Force un-set formatting on trailing space to allow continuous flow line mapping
                        controller.formatText(
                          triggerStartIndex + tokenText.length,
                          1,
                          quill.Attribute.clone(quill.Attribute.bold, null),
                        );

                        _closeAutocompleteMenu();
                        _updateHtmlPreview();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_autocompleteOverlay!);
  }

  void _closeAutocompleteMenu() {
    _autocompleteOverlay?.remove();
    _autocompleteOverlay = null;
  }

  void _insertTableAsCustomEmbedBlock() {
    final String generatedId = 'Table_ID_$_tableIdCounter';
    _tableIdCounter++;

    final newTable = InlineTableState(
      id: generatedId,
      onStateMutated: _updateHtmlPreview,
    );

    globalTableRegistry[generatedId] = newTable;

    final int currentOffset = _mainTextController.selection.baseOffset;
    _mainTextController.document.insert(currentOffset, '\n');
    _mainTextController.document.insert(
      currentOffset + 1,
      quill.CustomBlockEmbed('custom_inline_table', generatedId),
    );
    _mainTextController.document.insert(currentOffset + 2, '\n');

    _mainTextController.updateSelection(
      TextSelection.collapsed(offset: currentOffset + 3),
      quill.ChangeSource.local,
    );

    _updateHtmlPreview();
  }

  void _removeTableBlockFromFlow(String id) {
    final deltaJson = _mainTextController.document.toDelta().toJson();
    int currentOffset = 0;

    for (var op in deltaJson) {
      if (op.containsKey('insert')) {
        final insertVal = op['insert'];

        if (insertVal is Map && insertVal.containsKey('custom_inline_table')) {
          if (insertVal['custom_inline_table'].toString() == id) {
            _mainTextController.document.delete(currentOffset, 1);
            break;
          }
        }
        currentOffset += (insertVal is String) ? insertVal.length : 1;
      }
    }

    globalTableRegistry[id]?.dispose();
    globalTableRegistry.remove(id);
    _updateHtmlPreview();
  }

  // String _compileEntireCanvasToHtml() {
  //   final rawDelta = _mainTextController.document.toDelta().toJson();

  //   final List<Map<String, dynamic>> compiledDeltas = [];
  //   final Map<String, String> tableMap = {};

  //   for (final op in rawDelta) {
  //     if (op['insert'] is Map) {
  //       final insertMap = op['insert'] as Map;

  //       if (insertMap.containsKey('custom_inline_table')) {
  //         final tableId = insertMap['custom_inline_table'].toString();
  //         final table = globalTableRegistry[tableId];

  //         if (table != null) {
  //           tableMap[tableId] = _buildTableHtml(table);

  //           compiledDeltas.add({'insert': '__TABLE__$tableId'});

  //           continue;
  //         }
  //       }
  //     }

  //     compiledDeltas.add(Map<String, dynamic>.from(op));
  //   }

  //   final converter = QuillDeltaToHtmlConverter(compiledDeltas);

  //   String html = converter.convert();

  //   // Decode escaped HTML
  //   html = HtmlUnescape().convert(html);

  //   // Replace placeholders with real tables
  //   tableMap.forEach((id, tableHtml) {
  //     html = html.replaceAll('<p>__TABLE__$id</p>', tableHtml);

  //     html = html.replaceAll('__TABLE__$id', tableHtml);
  //   });

  //   // Remove invalid paragraph wrappers
  //   html = html.replaceAll('<p><table', '<table');
  //   html = html.replaceAll('</table></p>', '</table>');

  //   return html;
  // }

  String _compileEntireCanvasToHtml() {
    final rawDelta = _mainTextController.document.toDelta().toJson();

    final List<Map<String, dynamic>> compiledDeltas = [];
    final Map<String, String> tableMap = {};

    // Replace custom table embeds with placeholders
    for (final op in rawDelta) {
      if (op['insert'] is Map) {
        final insertMap = op['insert'] as Map;

        if (insertMap.containsKey('custom_inline_table')) {
          final tableId = insertMap['custom_inline_table'].toString();
          final table = globalTableRegistry[tableId];

          if (table != null) {
            tableMap[tableId] = _buildTableHtml(table);

            compiledDeltas.add({'insert': '__TABLE__$tableId'});

            continue;
          }
        }
      }

      compiledDeltas.add(Map<String, dynamic>.from(op));
    }

    final converter = QuillDeltaToHtmlConverter(compiledDeltas);

    String html = converter.convert();

    // Decode HTML entities
    html = HtmlUnescape().convert(html);

    // Replace table placeholders with generated table HTML
    tableMap.forEach((id, tableHtml) {
      html = html.replaceAll('<p>__TABLE__$id</p>', tableHtml);
      html = html.replaceAll('__TABLE__$id', tableHtml);
    });

    // ---------------------------------------------------
    // Replace ALL tokens with their VALUES
    // ---------------------------------------------------
    for (final token in _systemTokens) {
      final tokenKey = token['token']!;
      final tokenValue = token['value'] ?? '';

      html = html.replaceAll(tokenKey, tokenValue);
    }

    // Remove invalid wrappers around tables
    html = html.replaceAll('<p><table', '<table');
    html = html.replaceAll('</table></p>', '</table>');

    return html;
  }

  String _buildTableHtml(dynamic table) {
    final buffer = StringBuffer();

    buffer.write('''
<table class="rendered-data-table"
style="
width:100%;
border-collapse:collapse;
table-layout:fixed;
margin:12px 0;
border:1px solid #BBDEFB;
">
''');

    for (int r = 0; r < table.rows; r++) {
      // Header + alternating row colors
      final bg = r == 0 ? '#1E88E5' : ((r - 1).isEven ? '#FFFFFF' : '#F9FAFB');

      buffer.write('<tr style="background:$bg;">');

      for (int c = 0; c < table.cols; c++) {
        final delta = table.grid[r][c].controller.document.toDelta().toJson();

        final cellConverter = QuillDeltaToHtmlConverter(
          List<Map<String, dynamic>>.from(delta),
        );

        String cellHtml = cellConverter.convert();

        // Empty cell
        if (cellHtml.replaceAll(RegExp(r'<[^>]+>'), '').trim().isEmpty) {
          cellHtml = '&nbsp;';
        }

        // // Replace placeholder tokens
        // for (final token in _systemTokens) {
        //   cellHtml = cellHtml.replaceAll(
        //     token['token']!,
        //     '<strong><span class="placeholder-token">${token['token']!}</span></strong>',
        //   );
        // }

        for (final token in _systemTokens) {
          final tokenText = token['token']!;
          final tokenValue = token['value'] ?? '';

          cellHtml = cellHtml.replaceAll(
            tokenText,
            '<span class="placeholder-token"><strong>$tokenValue</strong></span>',
          );
        }

        // Remove default paragraph spacing
        cellHtml = cellHtml.replaceAll(
          '<p>',
          '<p style="margin:0;line-height:1.3;">',
        );

        if (r == 0) {
          buffer.write('''
<th
style="
padding:6px 8px;
border:1px solid #BBDEFB;
color:white;
font-weight:bold;
text-align:left;
vertical-align:middle;
word-break:break-word;
">
$cellHtml
</th>
''');
        } else {
          buffer.write('''
<td
style="
padding:6px 8px;
border:1px solid #E5E7EB;
vertical-align:middle;
word-break:break-word;
">
$cellHtml
</td>
''');
        }
      }

      buffer.write('</tr>');
    }

    buffer.write('</table>');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Unified Email Editor Canvas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, color: Colors.purpleAccent),
            label: const Text(
              'Copy HTML Layout',
              style: TextStyle(
                color: Colors.purpleAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () =>
                Clipboard.setData(ClipboardData(text: _currentHtmlPreview)),
          ),
          TextButton.icon(
            icon: const Icon(Icons.table_rows, color: Colors.blueAccent),
            label: const Text(
              'Embed Table Inline',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _insertTableAsCustomEmbedBlock,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    quill.QuillSimpleToolbar(
                      controller: _mainTextController,
                      config: const quill.QuillSimpleToolbarConfig(
                        showSearchButton: false,
                        showFontFamily: false,
                        showFontSize: false,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: quill.QuillEditor(
                          controller: _mainTextController,
                          focusNode: _mainFocusNode,
                          scrollController: ScrollController(),
                          config: quill.QuillEditorConfig(
                            placeholder:
                                'Draft your email workflow structure context here...',
                            autoFocus: true,
                            padding: const EdgeInsets.all(8),
                            embedBuilders: [
                              DynamicTableEmbedBuilder(
                                onTableContentChanged: _updateHtmlPreview,
                                onDeleteRequested: _removeTableBlockFromFlow,
                                onCellTextChanged: (cellController) {
                                  _checkForTokenTrigger(cellController);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                border: Border(left: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey.shade200,
                    child: const Row(
                      children: [
                        Icon(Icons.mark_email_read, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Customer Recipient Mail Box Mock',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SelectionArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Html(
                                    data: _currentHtmlPreview,
                                    style: {
                                      "body": Style(fontSize: FontSize(14)),
                                      "ul": Style(
                                        margin: Margins.only(
                                          left: 16,
                                          bottom: 8,
                                        ),
                                      ),
                                      "ol": Style(
                                        margin: Margins.only(
                                          left: 16,
                                          bottom: 8,
                                        ),
                                      ),
                                      "li": Style(
                                        padding: HtmlPaddings.symmetric(
                                          vertical: 2,
                                        ),
                                      ),
                                      ".rendered-data-table": Style(
                                        width: Width(100, Unit.percent),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                          width: 1.0,
                                        ),
                                        margin: Margins.symmetric(vertical: 12),
                                      ),
                                      ".row-alt": Style(
                                        backgroundColor: Colors.grey.shade50,
                                      ),
                                      ".row-normal": Style(
                                        backgroundColor: Colors.white,
                                      ),
                                      ".table-header-cell": Style(
                                        backgroundColor: Colors.blue.shade600,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        padding: HtmlPaddings.all(10),
                                        textAlign: TextAlign.left,
                                      ),
                                      ".table-data-cell": Style(
                                        padding: HtmlPaddings.all(10),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                      ),
                                      ".placeholder-token": Style(
                                        color: Colors.blue.shade900,
                                        backgroundColor: Colors.blue.shade100,
                                        display: Display.inline,
                                      ),
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
