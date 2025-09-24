import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/routine_provider.dart';
import '../../domain/entities/routine_task.dart';
import '../../core/utils/time_scheduler.dart';

class TimePlannerCalendar extends StatefulWidget {
  const TimePlannerCalendar({super.key});

  @override
  State<TimePlannerCalendar> createState() => _TimePlannerCalendarState();
}

class _TimePlannerCalendarState extends State<TimePlannerCalendar> {
  DateTime selectedDate = DateTime.now();
  final List<String> timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
    '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
    '18:00', '19:00', '20:00', '21:00', '22:00', '23:00'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTimeGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index - 3));
          final isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Consumer<RoutineProvider>(
      builder: (context, provider, child) {
        final tasks = provider.getTasksForDate(selectedDate);
        
        return ListView.builder(
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final timeSlot = timeSlots[index];
            final tasksInSlot = _getTasksForTimeSlot(tasks, timeSlot);

            return Container(
              height: 80,
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Time label
                  SizedBox(
                    width: 60,
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  // Tasks area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: tasksInSlot.isNotEmpty
                          ? _buildTasksInSlot(tasksInSlot, provider)
                          : _buildEmptySlot(timeSlot),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTasksInSlot(List<RoutineTask> tasks, RoutineProvider provider) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: task.isCompleted 
                ? Colors.green[100] 
                : Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: task.isCompleted 
                  ? Colors.green 
                  : Theme.of(context).primaryColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: task.isCompleted ? Colors.green[800] : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.scheduledTime != null)
                Text(
                  TimeScheduler.formatTime(task.scheduledTime!),
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: task.isCompleted ? Colors.green : Colors.grey,
                  ),
                  GestureDetector(
                    onTap: () => _showTaskOptions(context, task, provider),
                    child: Icon(
                      Icons.more_horiz,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySlot(String timeSlot) {
    return Center(
      child: GestureDetector(
        onTap: () => _showAddTaskDialog(timeSlot),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.grey,
            size: 20,
          ),
        ),
      ),
    );
  }

  List<RoutineTask> _getTasksForTimeSlot(List<RoutineTask> tasks, String timeSlot) {
    final hour = int.parse(timeSlot.split(':')[0]);
    
    return tasks.where((task) {
      if (task.scheduledTime != null) {
        // Eğer scheduled time varsa, o saati kullan
        return task.scheduledTime!.hour == hour;
      } else {
        // Fallback: eski mantık
        return (task.id ?? 0) % 24 == hour;
      }
    }).toList();
  }

  void _showTaskOptions(BuildContext context, RoutineTask task, RoutineProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                task.isCompleted ? Icons.close : Icons.check,
                color: task.isCompleted ? Colors.red : Colors.green,
              ),
              title: Text(
                task.isCompleted ? 'Tamamlanmadı olarak işaretle' : 'Tamamlandı olarak işaretle',
              ),
              onTap: () {
                provider.markTaskCompleted(task.id!, !task.isCompleted);
                Navigator.pop(context);
                if (!task.isCompleted) {
                  _showMotivationalMessage();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.blue),
              title: const Text('Saati değiştir'),
              onTap: () {
                Navigator.pop(context);
                _showTimePickerDialog(task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: const Text('Düzenle'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement task editing
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMotivationalMessage() {
    final messages = [
      '🎉 Harika! Bir adım daha yaklaştın!',
      '✨ Süper! Saç sağlığın için önemli bir adım!',
      '🔥 Mükemmel! Rutinine sadık kalıyorsun!',
      '💪 Tebrikler! Hedeflerine doğru ilerliyorsun!',
      '🌟 Fantastic! Saç bakım yolculuğunda ilerliyor',
    ];
    
    final randomMessage = messages[DateTime.now().millisecond % messages.length];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(randomMessage),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Devam Et!',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showAddTaskDialog(String timeSlot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$timeSlot için görev ekle'),
        content: const Text('Bu özellik yakında eklenecek!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showTimePickerDialog(RoutineTask task) {
    final initialTime = task.scheduledTime != null 
        ? TimeOfDay.fromDateTime(task.scheduledTime!)
        : TimeOfDay.now();
        
    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((time) {
      if (time != null && task.id != null) {
        // Create new DateTime with selected time
        final newDateTime = DateTime(
          task.date.year,
          task.date.month,
          task.date.day,
          time.hour,
          time.minute,
        );
        
        // Update task time in provider
        context.read<RoutineProvider>().updateTaskScheduledTime(task.id!, newDateTime);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} saati ${time.format(context)} olarak güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  String _getDayName(int weekday) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[weekday - 1];
  }
}
