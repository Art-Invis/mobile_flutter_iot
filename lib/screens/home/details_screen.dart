import 'package:flutter/material.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/widgets/glass_card.dart';
import 'package:mobile_flutter_iot/widgets/sensor_chart.dart';
import 'package:provider/provider.dart';

class SensorArguments {
  final String id;
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String status;
  final String ipAddress;

  SensorArguments({
    required this.id,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.status = 'Stable',
    this.ipAddress = '192.168.1.XXX',
  });
}

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  bool _isManualControlOn = true;
  String? _currentValue;
  String? _customIp;
  final _userRepository = LocalUserRepository();

  Future<void> _editIpAddress(SensorArguments args) async {
    final mqtt = Provider.of<MqttProvider>(context, listen: false);
    final controller = TextEditingController(text: _customIp ?? args.ipAddress);

    final newIp = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Edit Device IP / Broker'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. 192.168.1.XXX',
            labelText: 'Target IP Address',
            labelStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text(
              'Update & Reconnect',
              style: TextStyle(color: Color(0xFF4ADE80)),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (newIp != null && newIp.isNotEmpty) {
      setState(() => _customIp = newIp);

      mqtt.disconnect();
      mqtt.initMqtt(newIp, 'flutter_client_reconnect');
      mqtt.connect();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reconnecting to $newIp...'),
          backgroundColor: Colors.blueGrey,
        ),
      );
    }
  }

  Future<void> _editValue(SensorArguments args) async {
    final controller = TextEditingController(text: _currentValue ?? args.value);
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('Edit ${args.title} Value'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration:
              const InputDecoration(hintText: 'Enter new value (e.g. 25.5°C)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child:
                const Text('Save', style: TextStyle(color: Color(0xFF38BDF8))),
          ),
        ],
      ),
    );

    if (newValue != null && newValue.isNotEmpty) {
      final devices = await _userRepository.getDevices();
      final index = devices.indexWhere((d) => d.id == args.id);
      if (index != -1) {
        devices[index].value = newValue;
        await _userRepository.saveDevices(devices);
        setState(() => _currentValue = newValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? rawArgs = ModalRoute.of(context)?.settings.arguments;
    if (rawArgs == null || rawArgs is! SensorArguments) {
      return const _ErrorDetailsView();
    }
    final args = rawArgs;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${args.title.toUpperCase()} ANALYSIS'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(context, {'deleteId': args.id}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${args.title} History',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  const SensorChart(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _editIpAddress(args),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    const Icon(Icons.lan_outlined, color: Colors.white38),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DEVICE IP / BROKER',
                          style: TextStyle(fontSize: 10, color: Colors.white38),
                        ),
                        Text(
                          _customIp ?? args.ipAddress,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.edit_note,
                      color: Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _editValue(args),
                    child: _buildMiniStat(
                      'Current Value',
                      _currentValue ?? args.value,
                      args.icon,
                      args.color,
                      isEditable: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMiniStat(
                    'Status',
                    args.status,
                    Icons.check_circle_outline,
                    const Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: ListTile(
                leading: Icon(
                  _isManualControlOn ? args.icon : Icons.power_off_outlined,
                  color: _isManualControlOn ? args.color : Colors.white24,
                ),
                title: Text('Manual ${args.title} Control'),
                subtitle: Text(
                  _isManualControlOn ? 'System Active' : 'System Paused',
                ),
                trailing: Switch(
                  value: _isManualControlOn,
                  onChanged: (v) => setState(() => _isManualControlOn = v),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isEditable = false,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              if (isEditable) ...[
                const SizedBox(width: 4),
                const Icon(Icons.edit, color: Colors.white24, size: 12),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white54),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ErrorDetailsView extends StatelessWidget {
  const _ErrorDetailsView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ERROR')),
      body: const Center(
        child: Text(
          'Sensor data not found.',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
