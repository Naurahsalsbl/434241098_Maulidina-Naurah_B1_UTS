class TicketRepository {
  final List<TicketModel> _dummyTickets = [
    TicketModel(
      id: '1',
      title: 'Wifi tidak konek',
      description: 'Internet kampus mati',
      status: TicketStatus.open,
      userId: 'user_1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    TicketModel(
      id: '2',
      title: 'Printer error',
      description: 'Tidak bisa print',
      status: TicketStatus.inProgress,
      userId: 'user_2',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // =========================
  // GET TICKETS
  // =========================
  Future<List<TicketModel>> getTickets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _dummyTickets;
  }

  // =========================
  // GET DETAIL
  // =========================
  Future<TicketModel> getTicketDetail(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _dummyTickets.firstWhere((t) => t.id == ticketId);
  }

  // =========================
  // CREATE
  // =========================
  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String userId,
    String? attachmentUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newTicket = TicketModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      status: TicketStatus.open,
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _dummyTickets.insert(0, newTicket);
    return newTicket;
  }

  // =========================
  // UPDATE STATUS
  // =========================
  Future<void> updateTicketStatus(
      String ticketId, TicketStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _dummyTickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _dummyTickets[index] =
          _dummyTickets[index].copyWith(status: status);
    }
  }

  // =========================
  // ASSIGN
  // =========================
  Future<void> assignTicket(String ticketId, String assignee) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _dummyTickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      _dummyTickets[index] =
          _dummyTickets[index].copyWith(assignedTo: assignee);
    }
  }

  // =========================
  // COMMENT
  // =========================
  Future<List<CommentModel>> getComments(String ticketId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String message,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return CommentModel(
      id: DateTime.now().toString(),
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      message: message,
      createdAt: DateTime.now(),
    );
  }
}