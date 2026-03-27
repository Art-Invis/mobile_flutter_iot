import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/models/device_model.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';
import 'package:mobile_flutter_iot/widgets/glass_input.dart';
import 'package:mobile_flutter_iot/widgets/primary_button.dart';

class AddDeviceScreen extends StatefulWidget {
  final DeviceModel? device;

  const AddDeviceScreen({super.key, this.device});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  late TextEditingController _titleController;
  late Color _selectedColor;
  late IconData _selectedIcon;

  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  final List<Color> _colors = [
    const Color(0xFF4ADE80),
    const Color(0xFF38BDF8),
    const Color(0xFFFACC15),
    const Color(0xFFF87171),
    const Color(0xFFC084FC),
  ];

  final List<IconData> _icons = [
    Icons.air,
    Icons.ac_unit,
    Icons.sensors,
    Icons.lightbulb_outline,
    Icons.water_drop_outlined,
    Icons.thermostat,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.device?.title ?? '');
    _selectedColor = widget.device?.color ?? _colors[0];
    _selectedIcon = widget.device?.icon ?? _icons[0];
  }

  Future<void> _handleSave() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    final deviceToSave = DeviceModel(
      id: widget.device?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      value: widget.device?.value ?? '0 units',
      status: widget.device?.status ?? 'INITIALIZING',
      icon: _selectedIcon,
      color: _selectedColor,
    );

    bool success;
    if (widget.device == null) {
      success = await _apiService.addDevice(deviceToSave);
    } else {
      success = await _apiService.updateDevice(deviceToSave);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, deviceToSave);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Error: Saved to local cache only.'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(
        context,
        deviceToSave,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device == null ? 'ADD SENSOR' : 'EDIT SENSOR'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassInput(
              hintText: 'Sensor Name',
              icon: Icons.edit,
              controller: _titleController,
            ),
            const SizedBox(height: 32),
            const Text('SELECT COLOR', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            _buildColorPicker(),
            const SizedBox(height: 32),
            const Text('SELECT ICON', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            _buildIconPicker(),
            const SizedBox(height: 48),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
              )
            else
              PrimaryButton(
                text: widget.device == null ? 'CREATE DEVICE' : 'SAVE CHANGES',
                onPressed: _handleSave,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _colors.map((color) {
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor == color ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 16,
      children: _icons.map((icon) {
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedIcon == icon
                  ? _selectedColor.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    _selectedIcon == icon ? _selectedColor : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              color: _selectedIcon == icon ? _selectedColor : Colors.white38,
            ),
          ),
        );
      }).toList(),
    );
  }
}
