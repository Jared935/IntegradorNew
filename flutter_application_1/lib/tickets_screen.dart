// tickets_screen.dart
import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class Ticket {
  String id;
  String subject;
  String status; // 'Abierto', 'Pendiente', 'Cerrado'
  String orderId;
  Ticket(this.id, this.subject, this.status, this.orderId);
}

class TicketsDataService {
  static final List<Ticket> _tickets = [];
  
  static List<Ticket> get ticketList => _tickets;

  static int get pendingTicketsCount {
    return _tickets.where((t) => t.status != 'Cerrado').length;
  }

  static final Stream<List<Ticket>> ticketStream = StorageService.streamTickets().map((loadedTickets) {
    _tickets.clear();
    final screenTickets = loadedTickets.map((t) => Ticket(t.id, t.subject, t.status, t.orderId)).toList();
    _tickets.addAll(screenTickets);
    return screenTickets;
  });

  static Future<void> initialize() async {}
  
  static Future<void> save() async {
    final storageTickets = _tickets.map((t) => data_models.Ticket(id: t.id, subject: t.subject, status: t.status, orderId: t.orderId)).toList();
    await StorageService.saveTickets(storageTickets);
  }
}

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState(); 
}

class _TicketsScreenState extends State<TicketsScreen> {

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Abierto':
      case 'Pendiente':
        return Colors.red;
      case 'Cerrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  void _toggleTicketStatus(int index) {
    final currentTicket = TicketsDataService._tickets[index];
    
    if (currentTicket.status == 'Cerrado') {
      currentTicket.status = 'Pendiente';
    } else {
      currentTicket.status = 'Cerrado';
    }
    TicketsDataService.save(); // Guarda el cambio
  }

  void _deleteTicket(int index) {
    final dismissedTicket = TicketsDataService._tickets.removeAt(index);
    
    TicketsDataService.save(); // Guarda después de eliminar

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket ${dismissedTicket.id} eliminado.'),
        action: SnackBarAction(
          label: 'DESHACER',
          onPressed: () {
            TicketsDataService._tickets.insert(index, dismissedTicket);
            TicketsDataService.save();
          },
        ),
      ),
    );
  }

  void _addTicket() {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController orderIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Crear Nuevo Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Asunto del Ticket'),
              ),
              TextField(
                controller: orderIdController,
                decoration: const InputDecoration(labelText: 'ID del Pedido/Artículo (Opcional)'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              onPressed: () {
                final subject = subjectController.text;
                final orderId = orderIdController.text.isEmpty ? 'N/A' : orderIdController.text;

                if (subject.isNotEmpty) {
                  String newId = 'T-${(TicketsDataService._tickets.length + 1).toString().padLeft(3, '0')}';
                  TicketsDataService._tickets.add(Ticket(newId, subject, 'Abierto', orderId));
                  TicketsDataService.save(); // Guarda después de añadir
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets de Soporte'),
        backgroundColor: Colors.orange,
      ),
      body: StreamBuilder<List<Ticket>>(
        stream: TicketsDataService.ticketStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          final liveTickets = snapshot.data ?? [];
          
          if (liveTickets.isEmpty) {
            return const Center(child: Text('No hay tickets registrados.'));
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveTickets.length,
            itemBuilder: (context, index) {
              final ticket = liveTickets[index];
              final color = _getStatusColor(ticket.status);
              
              final isFinished = ticket.status == 'Cerrado';
              final progressText = isFinished ? 'TERMINADO' : 'EN PROGRESO';
              final progressColor = isFinished ? Colors.green.shade800 : Colors.red.shade800;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                shape: Border(left: BorderSide(color: progressColor, width: 5)),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: color),
                  title: Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID Ticket: ${ticket.id} | Pedido: ${ticket.orderId}'), 
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isFinished ? Icons.undo : Icons.check_circle_outline,
                          color: isFinished ? Colors.blueGrey : Colors.green,
                        ),
                        tooltip: isFinished ? 'Marcar como Pendiente' : 'Marcar como Terminado',
                        onPressed: () => _toggleTicketStatus(index),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: progressColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          progressText, 
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteTicket(index);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTicket,
        label: const Text('Crear Nuevo Ticket'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
    );
  }
}