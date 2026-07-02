import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

// Template Data Model
class EmailTemplate {
  String id;
  String name;
  String htmlContent;

  EmailTemplate({
    required this.id,
    required this.name,
    required this.htmlContent,
  });
}

class TemplateBuilderDashboard extends StatefulWidget {
  const TemplateBuilderDashboard({super.key});

  @override
  State<TemplateBuilderDashboard> createState() =>
      _TemplateBuilderDashboardState();
}

class _TemplateBuilderDashboardState extends State<TemplateBuilderDashboard> {
  // Dummy API Data Source
  List<EmailTemplate> _templates = [];
  EmailTemplate? _selectedTemplate;

  // Controller for AI prompt input
  final TextEditingController _promptController = TextEditingController();

  // Temporary holding variable for AI generated layout before saving
  String? _previewHtml;
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    // Injecting standard dummy templates (White background, Blue CTA buttons)
    _templates = [
      EmailTemplate(
        id: "1",
        name: "Invoice 1",
        htmlContent: '''
         <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tax Invoice / Bill of Supply</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .invoice-container {
            max-width: 900px;
            margin: auto;
            background: white;
            padding: 20px;
            border: 1px solid #ccc;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #000;
            padding-bottom: 10px;
            margin-bottom: 10px;
        }
        .logo-placeholder {
            font-weight: bold;
            font-size: 18px;
            color: #1e3d59;
        }
        .title-block {
            text-align: center;
            flex-grow: 1;
        }
        .title-block h1 {
            font-size: 20px;
            margin: 0 0 5px 0;
            text-transform: uppercase;
        }
        .copy-type {
            font-size: 12px;
            font-weight: bold;
            text-align: right;
        }
        .section-heading {
            background-color: #b4c7e7;
            font-weight: bold;
            padding: 5px;
            border: 1px solid #000;
            font-size: 14px;
        }
        .grid-2 {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-bottom: 1px solid #000;
        }
        .grid-col {
            padding: 8px;
        }
        .grid-col:first-child {
            border-right: 1px solid #000;
        }
        .address-block {
            border-left: 1px solid #000;
            border-right: 1px solid #000;
            border-bottom: 1px solid #000;
            padding: 8px;
        }
        p {
            margin: 4px 0;
            font-size: 13px;
        }
        strong {
            display: inline-block;
            width: 120px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 13px;
        }
        th, td {
            border: 1px solid #000;
            padding: 6px;
            text-align: left;
        }
        th {
            background-color: #d9e1f2;
        }
        .text-right {
            text-align: right;
        }
        .text-center {
            text-align: center;
        }
        .total-row {
            font-weight: bold;
            background-color: #f2f2f2;
        }
        .words-block {
            border: 1px solid #000;
            border-top: none;
            padding: 8px;
            font-size: 13px;
        }
        .footer-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border: 1px solid #000;
            border-top: none;
            min-height: 100px;
        }
        .sign-block {
            text-align: right;
            padding: 8px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            align-items: flex-end;
        }
    </style>
</head>
<body>

<div class="invoice-container">
    
    <!-- Header Section -->
    <div class="header">
        <div class="logo-placeholder">
            TECHNOVATE<br><span style="font-size: 12px; color: #555;">SOLUTIONS</span>
        </div>
        <div class="title-block">
            <h1>Tax Invoice / Bill of Supply</h1>
        </div>
        <div class="copy-type">
            ORIGINAL FOR RECIPIENT<br>ORIGINAL FOR RECIPIENT
        </div>
    </div>

    <!-- Supplier & Invoice Details -->
    <div class="section-heading">Supplier Details</div>
    <div class="grid-2">
        <div class="grid-col">
            <p><strong>Company Name:</strong> TECHNOVATE SOLUTIONS</p>
            <p><strong>Address:</strong> 123, Sector 1B, Noida, UP, 201301, India</p>
            <p><strong>GSTIN:</strong> 09AAACT1234M1Z1</p>
            <p><strong>State:</strong> Uttar Pradesh</p>
        </div>
        <div class="grid-col">
            <p><strong>Invoice No:</strong> TSIPL/24-25/0123</p>
            <p><strong>Date:</strong> 25/10/2024</p>
            <p><strong>Place of Supply:</strong> Uttar Pradesh</p>
            <p><strong>State Code:</strong> 09</p>
        </div>
    </div>

    <!-- Receiver Details -->
    <div class="section-heading" style="margin-top: 10px;">Details of Receiver / Billed To</div>
    <div class="address-block">
        <p><strong>Name:</strong> ABC Pvt Ltd</p>
        <p><strong>Address:</strong> 456, Okhla Phase III, New Delhi, 110020, India</p>
        <p><strong>GSTIN:</strong> 07AABCA5678M1Z2</p>
        <p><strong>State:</strong> Delhi</p>
    </div>

    <!-- Item Details Table -->
    <div class="section-heading" style="margin-top: 10px;">Item Details Table</div>
    <table>
        <thead>
            <tr>
                <th style="width: 5%;">S.No.</th>
                <th style="width: 45%;">Description of Goods/Services</th>
                <th style="width: 10%;">HSN/SAC</th>
                <th style="width: 10%;" class="text-center">Qty</th>
                <th style="width: 15%;" class="text-right">Rate (₹)</th>
                <th style="width: 15%;" class="text-right">Amount (₹)</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-center">1.</td>
                <td>Laptop (Dell XPS 13) - 847130</td>
                <td></td>
                <td class="text-center">2 Nos</td>
                <td class="text-right">78000.00</td>
                <td class="text-right">1,56,000.00</td>
            </tr>
            <tr>
                <td class="text-center">2.</td>
                <td>Monitor (LG UltraWide) - 852852</td>
                <td></td>
                <td class="text-center">2 Nos</td>
                <td class="text-right">28500.00</td>
                <td class="text-right">57,000.00</td>
            </tr>
            <tr>
                <td class="text-center">3.</td>
                <td>IT Consulting Services - 998311</td>
                <td></td>
                <td class="text-center">10 Hrs</td>
                <td class="text-right">15000.00</td>
                <td class="text-right">15,000.00</td>
            </tr>
            <tr class="total-row">
                <td colspan="5" class="text-right">Total Amount before Tax:</td>
                <td class="text-right">2,28,000.00</td>
            </tr>
        </tbody>
    </table>

    <!-- Tax Summary Table -->
    <div class="section-heading" style="margin-top: 10px;">Tax Summary Table</div>
    <table>
        <thead>
            <tr>
                <th style="width: 5%;">S.No.</th>
                <th style="width: 20%;">Type</th>
                <th style="width: 15%;" class="text-right">Taxable Value</th>
                <th style="width: 15%;" class="text-right">CGST (9%)</th>
                <th style="width: 15%;" class="text-right">SGST (9%)</th>
                <th style="width: 15%;" class="text-right">IGST (18%)</th>
                <th style="width: 15%;" class="text-right">Total Tax Amount</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td class="text-center">1.</td>
                <td>Goods</td>
                <td class="text-right">2,13,000.00</td>
                <td class="text-right">19170.00</td>
                <td class="text-right">19170.00</td>
                <td class="text-right">-</td>
                <td class="text-right">38,340.00</td>
            </tr>
            <tr>
                <td class="text-center">2.</td>
                <td>Services</td>
                <td class="text-right">15,000.00</td>
                <td class="text-right">-</td>
                <td class="text-right">-</td>
                <td class="text-right">2700.00</td>
                <td class="text-right">2,700.00</td>
            </tr>
            <tr class="total-row">
                <td colspan="6" class="text-right">Total Tax Amount:</td>
                <td class="text-right">41,040.00</td>
            </tr>
        </tbody>
    </table>

    <!-- Amount in Words -->
    <div class="words-block">
        <strong>Total Invoice Amount in Words:</strong><br>
        <span style="font-weight: bold;">Two Lakh Sixty-Nine Thousand Forty Rupees Only</span>
    </div>

    <!-- Bank Details & Signatory -->
    <div class="footer-grid">
        <div class="grid-col">
            <p style="font-weight: bold; text-decoration: underline;">Bank Details</p>
            <p><strong>Bank:</strong> HDFC Bank</p>
            <p><strong>A/c No:</strong> 123456789012</p>
            <p><strong>IFSC:</strong> HDFC0000123</p>
        </div>
        <div class="sign-block">
            <p style="font-weight: bold; margin: 0;">Authorized Signatory</p>
            <p style="font-size: 11px; color: #555; margin: 0;">Signature & Stamp</p>
            <p style="font-weight: bold; font-size: 14px; margin: 0; text-transform: uppercase;">TECHNOVATE SOLUTIONS</p>
        </div>
    </div>

</div>

</body>
</html>

        ''',
      ),
      EmailTemplate(
        id: "2",
        name: "Invoice 2",
        htmlContent: '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receivables Aging Report by State</title>
    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f8f9fa;
            color: #333;
        }
        .report-container {
            max-width: 1100px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            border: 1px solid #e0e0e0;
        }
        .header {
            border-bottom: 3px solid #1e3d59;
            padding-bottom: 15px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }
        .header h1 {
            font-size: 24px;
            color: #1e3d59;
            margin: 0 0 5px 0;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .meta-info {
            text-align: right;
            font-size: 13px;
            color: #666;
            line-height: 1.5;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            font-size: 13px;
        }
        th, td {
            padding: 10px 12px;
            border: 1px solid #dcdcdc;
            text-align: right;
        }
        th {
            background-color: #1e3d59;
            color: white;
            font-weight: 600;
            text-align: center;
            font-size: 12px;
            text-transform: uppercase;
        }
        tr:nth-child(even) {
            background-color: #f9fbfd;
        }
        .state-row {
            background-color: #eaeff5 !important;
            font-weight: bold;
        }
        .state-name {
            text-align: left;
            font-size: 14px;
            color: #1e3d59;
        }
        .customer-name {
            text-align: left;
            padding-left: 25px;
            color: #555;
        }
        .total-row {
            font-weight: bold;
            background-color: #d9e1f2 !important;
            border-top: 2px solid #1e3d59;
            border-bottom: 2px solid #1e3d59;
            font-size: 14px;
        }
        .total-label {
            text-align: left;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .text-center {
            text-align: center;
        }
        .negative {
            color: #c0392b;
        }
    </style>
</head>
<body>

<div class="report-container">
    
    <!-- Report Header -->
    <div class="header">
        <div>
            <h1>Accounts Receivable Aging Report</h1>
            <span style="font-size: 14px; color: #555; font-weight: 500;">Grouped by State & Aging Buckets</span>
        </div>
        <div class="meta-info">
            <p><strong>Report Date:</strong> 02/07/2026</p>
            <p><strong>Currency:</strong> INR (₹)</p>
        </div>
    </div>

    <!-- Aging Table -->
    <table>
        <thead>
            <tr>
                <th rowspan="2" style="width: 25%; text-align: left;">State / Customer Name</th>
                <th rowspan="2" style="width: 13%;">Total Outstanding</th>
                <th colspan="5">Aging Breakdown (Days)</th>
            </tr>
            <tr>
                <th style="width: 12%;">&lt; 30</th>
                <th style="width: 12%;">&lt; 45</th>
                <th style="width: 12%;">&lt; 60</th>
                <th style="width: 12%;">&lt; 90</th>
                <th style="width: 14%;">&gt; 90+</th>
            </tr>
        </thead>
        <tbody>
            
            <!-- KARNATAKA -->
            <tr class="state-row">
                <td class="state-name">Karnataka Total</td>
                <td>4,85,000.00</td>
                <td>1,80,000.00</td>
                <td>1,20,000.00</td>
                <td>75,000.00</td>
                <td>60,000.00</td>
                <td>50,000.00</td>
            </tr>
            <tr>
                <td class="customer-name">Bengaluru Tech Park Corp</td>
                <td>2,50,000.00</td>
                <td>1,10,000.00</td>
                <td>80,000.00</td>
                <td>40,000.00</td>
                <td>20,000.00</td>
                <td>-</td>
            </tr>
            <tr>
                <td class="customer-name">Mysore Retail Enterprises</td>
                <td>1,35,000.00</td>
                <td>70,000.00</td>
                <td>40,000.00</td>
                <td>25,000.00</td>
                <td>-</td>
                <td>-</td>
            </tr>
            <tr>
                <td class="customer-name">Mangalore Logistics Ltd</td>
                <td>1,00,000.00</td>
                <td>-</td>
                <td>-</td>
                <td>10,000.00</td>
                <td>40,000.00</td>
                <td>50,000.00</td>
            </tr>

            <!-- TAMIL NADU -->
            <tr class="state-row">
                <td class="state-name">Tamil Nadu Total</td>
                <td>6,10,000.00</td>
                <td>2,45,000.00</td>
                <td>1,50,000.00</td>
                <td>95,000.00</td>
                <td>45,000.00</td>
                <td>75,000.00</td>
            </tr>
            <tr>
                <td class="customer-name">Chennai Auto Component Ltd</td>
                <td>3,20,000.00</td>
                <td>1,50,000.00</td>
                <td>90,000.00</td>
                <td>50,000.00</td>
                <td>30,000.00</td>
                <td>-</td>
            </tr>
            <tr>
                <td class="customer-name">Coimbatore Textiles Inc</td>
                <td>1,65,000.00</td>
                <td>95,000.00</td>
                <td>60,000.00</td>
                <td>10,000.00</td>
                <td>-</td>
                <td>-</td>
            </tr>
            <tr>
                <td class="customer-name">Madurai Traders & Co</td>
                <td>1,25,000.00</td>
                <td>-</td>
                <td>-</td>
                <td>35,000.00</td>
                <td>15,000.00</td>
                <td>75,000.00</td>
            </tr>

            <!-- KERALA -->
            <tr class="state-row">
                <td class="state-name">Kerala Total</td>
                <td>3,25,000.00</td>
                <td>1,05,000.00</td>
                <td>65,000.00</td>
                <td>40,000.00</td>
                <td>35,000.00</td>
                <td>80,000.00</td>
            </tr>
            <tr>
                <td class="customer-name">Kochi Marine Exports</td>
                <td>1,80,000.00</td>
                <td>75,000.00</td>
                <td>45,000.00</td>
                <td>30,000.00</td>
                <td>30,000.00</td>
                <td>-</td>
            </tr>
            <tr>
                <td class="customer-name">Trivandrum Infotech Ltd</td>
                <td>1,45,000.00</td>
                <td>30,000.00</td>
                <td>20,000.00</td>
                <td>10,000.00</td>
                <td>5,000.00</td>
                <td>80,000.00</td>
            </tr>

            <!-- GRAND TOTAL -->
            <tr class="total-row">
                <td class="total-label">Grand Total</td>
                <td>14,20,000.00</td>
                <td>5,30,000.00</td>
                <td>3,35,000.00</td>
                <td>2,10,000.00</td>
                <td>1,40,000.00</td>
                <td>2,05,000.00</td>
            </tr>
        </tbody>
    </table>

</div>

</body>
</html>

''',
      ),
    ];

    // Default selecting the first template
    _selectedTemplate = _templates.first;
    _previewHtml = _selectedTemplate?.htmlContent;
  }

  // Simulating an LLM Generation Endpoint
  Future<void> _runLlmModification(String prompt) async {
    if (prompt.trim().isEmpty) return;

    setState(() {
      _isAiLoading = true;
    });

    // Simulating API Latency
    await Future.delayed(const Duration(seconds: 2));

    // Dynamic Mock responses based on keywords
    String generatedHtml = _previewHtml!;
    if (prompt.toLowerCase().contains('discount') ||
        prompt.toLowerCase().contains('offer')) {
      generatedHtml = '''
        <div style="background-color: #ffffff; padding: 24px; border-radius: 8px; font-family: sans-serif; color: #333; border: 2px dashed #0175C2;">
          <h2 style="color: #E63946; margin-top: 0;">🔥 Special Limited Offer!</h2>
          <p>As requested, we updated your template with promotional items. Claim your <b>30% discount</b> on all professional tiers this weekend.</p>
          <div style="text-align: center; margin: 24px 0;">
            <a href="#" style="background-color: #0175C2; color: #ffffff; padding: 14px 28px; text-decoration: none; border-radius: 4px; display: inline-block; font-weight: bold; font-size: 16px;">Claim 30% Off Now</a>
          </div>
          <p style="font-size: 11px; text-align: center; color: #999;">Use code: AI30 AT CHECKOUT</p>
        </div>
      ''';
    } else {
      // Default Generic prompt modification wrap
      generatedHtml =
          '''
        <div style="background-color: #ffffff; padding: 24px; border-radius: 8px; font-family: sans-serif; color: #333;">
          <h2 style="color: #0175C2; margin-top: 0;">${_selectedTemplate?.name} (AI Modified)</h2>
          <p>Here is your modified section optimized for: <i>"$prompt"</i>.</p>
          <p>All brand colors have been preserved successfully.</p>
          <div style="text-align: center; margin: 24px 0;">
            <a href="#" style="background-color: #0175C2; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 4px; display: inline-block; font-weight: bold;">Proceed to Platform</a>
          </div>
        </div>
      ''';
    }

    setState(() {
      _previewHtml = generatedHtml;
      _isAiLoading = false;
      _promptController.clear();
    });
  }

  // Method to persist the modified preview layout as a new template block
  void _saveAsNewTemplate() {
    if (_previewHtml == null) return;

    final newId = (_templates.length + 1).toString();
    final newTemplate = EmailTemplate(
      id: newId,
      name: "${_selectedTemplate?.name ?? 'Template'} Clone ($newId)",
      htmlContent: _previewHtml!,
    );

    setState(() {
      _templates.add(newTemplate);
      _selectedTemplate = newTemplate;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${newTemplate.name}" saved as new template!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Email Template Engine Studio',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0175C2),
        elevation: 1,
      ),
      body: Row(
        children: [
          // ---------------- LEFT SIDEBAR (Template Selection list) ----------------
          Container(
            width: 320,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  key: ValueKey('sidebar_header'),
                  child: Text(
                    "Standard Templates",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: _templates.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _templates[index];
                      final isSelected = _selectedTemplate?.id == item.id;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: const Color(
                          0xFF0175C2,
                        ).withOpacity(0.06),
                        title: Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                          // Scaled Mini-HTML viewer layout for thumbnail logic
                          child: Container(
                            height: 100,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0175C2)
                                    : Colors.grey.shade300,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: IgnorePointer(
                              child: SingleChildScrollView(
                                child: Html(data: item.htmlContent),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedTemplate = item;
                            _previewHtml = item.htmlContent;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ---------------- RIGHT PREVIEW & AI PANEL ----------------
          Expanded(
            child: Container(
              color: const Color(0xFFF4F6F9),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Main Active Workspace Render View Canvas
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Email Mock Frame Panel
                        Expanded(
                          flex: 3,
                          child: Card(
                            elevation: 2,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Live Preview: ${_selectedTemplate?.name}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: _saveAsNewTemplate,
                                        icon: const Icon(
                                          Icons.save_as,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        label: const Text(
                                          "Save as New",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0175C2,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE9ECEF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 1000,
                                        ),
                                        child: _isAiLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Color(0xFF0175C2),
                                                    ),
                                              )
                                            : SingleChildScrollView(
                                                child: Html(
                                                  data: _previewHtml ?? "",
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Execution Dock (LLM Prompt Area Input Block)
                  Card(
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.psychology,
                            color: Color(0xFF0175C2),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _promptController,
                              decoration: const InputDecoration(
                                hintText:
                                    "Ask LLM to modify this template (e.g., 'Add a 30% coupon section with dynamic text')...",
                                border: InputBorder.none,
                              ),
                              onSubmitted: (value) =>
                                  _runLlmModification(value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () =>
                                _runLlmModification(_promptController.text),
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Color(0xFF0175C2),
                            ),
                            tooltip: "Modify with AI",
                          ),
                        ],
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
