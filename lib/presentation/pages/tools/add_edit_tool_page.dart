import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:power_tool_tracking/core/constants/app_constants.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/extensions/context_extensions.dart';
import 'package:power_tool_tracking/core/theme/app_colors.dart';
import 'package:power_tool_tracking/core/utils/input_validators.dart';
import 'package:power_tool_tracking/domain/entities/tool_entity.dart';
import 'package:power_tool_tracking/domain/usecases/tool/get_tool_by_id_usecase.dart';
import 'package:power_tool_tracking/presentation/blocs/tool/tool_bloc.dart';
import 'package:power_tool_tracking/presentation/widgets/common/app_button.dart';
import 'package:power_tool_tracking/presentation/widgets/common/app_text_field.dart';
import 'package:uuid/uuid.dart';

class AddEditToolPage extends StatefulWidget {
  const AddEditToolPage({super.key, this.toolId});
  final String? toolId;

  bool get isEditing => toolId != null;

  @override
  State<AddEditToolPage> createState() => _AddEditToolPageState();
}

class _AddEditToolPageState extends State<AddEditToolPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();
  final _assetTagCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _purchaseCostCtrl = TextEditingController();

  String _selectedCategory = AppConstants.toolCategories.first;
  ToolCondition _selectedCondition = ToolCondition.good;
  DateTime? _purchaseDate;
  DateTime? _nextMaintenanceDue;

  bool _isLoading = false;
  ToolEntity? _existingTool;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) _loadTool();
  }

  Future<void> _loadTool() async {
    setState(() => _isLoading = true);
    final result = await sl<GetToolByIdUseCase>()(widget.toolId!);
    result.fold(
      onSuccess: (tool) {
        _existingTool = tool;
        _populateFields(tool);
      },
      onFailure: (f) => context.showErrorSnackBar(f.message),
    );
    if (mounted) setState(() => _isLoading = false);
  }

  void _populateFields(ToolEntity tool) {
    _nameCtrl.text = tool.name;
    _brandCtrl.text = tool.brand;
    _modelCtrl.text = tool.model;
    _serialCtrl.text = tool.serialNumber;
    _assetTagCtrl.text = tool.assetTag ?? '';
    _locationCtrl.text = tool.location ?? '';
    _notesCtrl.text = tool.notes ?? '';
    _purchaseCostCtrl.text = tool.purchaseCost?.toString() ?? '';
    _selectedCategory = tool.category;
    _selectedCondition = tool.condition;
    _purchaseDate = tool.purchaseDate;
    _nextMaintenanceDue = tool.nextMaintenanceDue;
  }

  @override
  void dispose() {
    for (final ctrl in [
      _nameCtrl, _brandCtrl, _modelCtrl, _serialCtrl,
      _assetTagCtrl, _locationCtrl, _notesCtrl, _purchaseCostCtrl,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _onSubmit() {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final tool = ToolEntity(
      id: _existingTool?.id ?? const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      serialNumber: _serialCtrl.text.trim(),
      category: _selectedCategory,
      status: _existingTool?.status ?? ToolStatus.available,
      condition: _selectedCondition,
      assetTag: _assetTagCtrl.text.trim().isEmpty ? null : _assetTagCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      purchaseCost: double.tryParse(_purchaseCostCtrl.text),
      purchaseDate: _purchaseDate,
      nextMaintenanceDue: _nextMaintenanceDue,
      createdAt: _existingTool?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.isEditing) {
      context.read<ToolBloc>().add(ToolUpdateRequested(tool: tool));
    } else {
      context.read<ToolBloc>().add(ToolCreateRequested(tool: tool));
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Tool' : 'Add New Tool'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Basic Information', [
              AppTextField(
                controller: _nameCtrl,
                label: 'Tool Name *',
                hint: 'e.g., M18 Fuel Drill',
                prefixIcon: Icons.construction_outlined,
                validator: (v) => InputValidators.required(v, fieldName: 'Tool name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _brandCtrl,
                label: 'Brand *',
                hint: 'e.g., Milwaukee, DeWalt, Bosch',
                prefixIcon: Icons.business_outlined,
                validator: (v) => InputValidators.required(v, fieldName: 'Brand'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _modelCtrl,
                label: 'Model *',
                hint: 'e.g., 2804-20',
                prefixIcon: Icons.info_outline,
                validator: (v) => InputValidators.required(v, fieldName: 'Model'),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Identification', [
              AppTextField(
                controller: _serialCtrl,
                label: 'Serial Number *',
                hint: 'Enter manufacturer serial number',
                prefixIcon: Icons.tag,
                validator: InputValidators.serialNumber,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _assetTagCtrl,
                label: 'Asset Tag',
                hint: 'Internal asset tag (optional)',
                prefixIcon: Icons.qr_code,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Classification', [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.toolCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ToolCondition>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: 'Condition *',
                  prefixIcon: Icon(Icons.stars_outlined),
                ),
                items: ToolCondition.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.displayName),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCondition = value!),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Location & Notes', [
              AppTextField(
                controller: _locationCtrl,
                label: 'Storage Location',
                hint: 'e.g., Warehouse A, Shelf 3',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _notesCtrl,
                label: 'Notes',
                hint: 'Additional notes about this tool',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('Purchase & Maintenance', [
              AppTextField(
                controller: _purchaseCostCtrl,
                label: 'Purchase Cost',
                hint: '0.00',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Purchase Date',
                selectedDate: _purchaseDate,
                onDateSelected: (date) => setState(() => _purchaseDate = date),
              ),
              const SizedBox(height: 12),
              _DatePickerField(
                label: 'Next Maintenance Due',
                selectedDate: _nextMaintenanceDue,
                onDateSelected: (date) => setState(() => _nextMaintenanceDue = date),
              ),
            ]),
            const SizedBox(height: 32),
            AppButton(
              onPressed: _onSubmit,
              label: widget.isEditing ? 'Update Tool' : 'Add Tool',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      );
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateSelected;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          onDateSelected(date);
        },
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_today_outlined),
            suffixIcon: selectedDate != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onDateSelected(null),
                  )
                : null,
          ),
          child: Text(
            selectedDate != null
                ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                : 'Select date',
            style: TextStyle(
              color: selectedDate != null
                  ? context.colorScheme.onSurface
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
}
