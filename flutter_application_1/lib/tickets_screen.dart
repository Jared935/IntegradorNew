import 'package:flutter/material.dart';
import 'storage_service.dart';
import 'data_models.dart' as data_models;

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Abierto':
      case 'Pendiente': return Colors.orange;
      case 'Cerrado': 
      case 'Terminado': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  // Función para cambiar el estado en Firebase
  void _toggleTicketStatus(data_models.Ticket ticket) {
    final newStatus = (ticket.status == 'Terminado' || ticket.status == 'Cerrado') 
        ? 'Abierto' 
        : 'Terminado';
    StorageService.updateTicketStatus(ticket.id, newStatus);
  }

  void _deleteTicket(String ticketId) {
    StorageService.deleteTicket(ticketId);
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
                decoration: const InputDecoration(labelText: 'ID del Pedido (Opcional)'),
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
                final subject = subjectController.text.trim();
                final orderId = orderIdController.text.trim();

                if (subject.isNotEmpty) {
                  final newTicket = data_models.Ticket(
                    id: '',
                    subject: subject,
                    status: 'Abierto',
                    orderId: orderId.isEmpty ? 'N/A' : orderId,
                  );
                  
                  StorageService.addTicket(newTicket);
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
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<data_models.Ticket>>(
        stream: StorageService.streamTickets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
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
              final isFinished = ticket.status == 'Terminado' || ticket.status == 'Cerrado';
              final statusColor = _getStatusColor(ticket.status);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(Icons.assignment, color: statusColor),
                  title: Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('ID: ${ticket.id.substring(0, 6)}... | Pedido: ${ticket.orderId}'), 
                  
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón para alternar estado
                      TextButton(
                        onPressed: () => _toggleTicketStatus(ticket),
                        style: TextButton.styleFrom(
                           backgroundColor: statusColor.withOpacity(0.1),
                        ),
                        child: Text(
                          isFinished ? 'TERMINADO' : 'ABIERTO', 
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTicket(ticket.id),
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
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
    );
  }
}