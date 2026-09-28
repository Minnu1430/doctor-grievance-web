import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../services/message_service.dart';

class ComplaintProvider with ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';
  int? _selectedCategoryId;
  String _searchQuery = '';

  // Active Complaint Details Cache
  Complaint? _activeComplaint;
  List<ComplaintDocument> _activeDocuments = [];
  List<ComplaintMessage> _activeMessages = [];
  List<ComplaintHistory> _activeHistory = [];
  Resolution? _activeResolution;
  bool _isLoadingDetails = false;

  // Getters
  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedStatus => _selectedStatus;
  String get selectedPriority => _selectedPriority;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  Complaint? get activeComplaint => _activeComplaint;
  List<ComplaintDocument> get activeDocuments => _activeDocuments;
  List<ComplaintMessage> get activeMessages => _activeMessages;
  List<ComplaintHistory> get activeHistory => _activeHistory;
  Resolution? get activeResolution => _activeResolution;
  bool get isLoadingDetails => _isLoadingDetails;

  // Status Summary Counts
  int get countTotal => _complaints.length;
  int get countDraft => _complaints.where((c) => c.status == 'Draft').length;
  int get countSubmitted =>
      _complaints.where((c) => c.status == 'Submitted').length;
  int get countPending => _complaints
      .where((c) => c.status == 'Under Verification' || c.status == 'Accepted')
      .length;
  int get countUnderInvestigation => _complaints
      .where((c) => c.status == 'Under Investigation' || c.status == 'Assigned')
      .length;
  int get countActionRequired => _complaints
      .where((c) =>
          c.status == 'Action Required' ||
          c.status == 'More Information Required')
      .length;
  int get countResolved =>
      _complaints.where((c) => c.status == 'Resolved').length;
  int get countClosed => _complaints.where((c) => c.status == 'Closed').length;

  void setStatusFilter(String status) {
    _selectedStatus = status;
    fetchComplaints();
  }

  void setPriorityFilter(String priority) {
    _selectedPriority = priority;
    fetchComplaints();
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    fetchComplaints();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchComplaints();
  }

  void clearFilters() {
    _selectedStatus = 'All';
    _selectedPriority = 'All';
    _selectedCategoryId = null;
    _searchQuery = '';
    fetchComplaints();
  }

  Future<void> fetchComplaints({bool? assignedOnly}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await ComplaintService.getComplaints(
        status: _selectedStatus,
        priority: _selectedPriority,
        categoryId: _selectedCategoryId,
        search: _searchQuery,
        assignedOnly: assignedOnly,
      );
      _complaints = list;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComplaintDetails(int complaintId) async {
    _isLoadingDetails = true;
    notifyListeners();

    try {
      final data = await ComplaintService.getComplaintDetails(complaintId);
      _activeComplaint = data['complaint'];
      _activeDocuments = data['documents'] ?? [];
      _activeMessages = data['messages'] ?? [];
      _activeHistory = data['history'] ?? [];
      _activeResolution = data['resolution'];
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int complaintId, String message,
      {bool isInternalNote = false}) async {
    try {
      final newMsg = await MessageService.sendMessage(complaintId, message,
          isInternalNote: isInternalNote);
      _activeMessages.add(newMsg);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(int complaintId, String newStatus,
      {String? comments}) async {
    try {
      await ComplaintService.updateComplaintStatus(complaintId, newStatus,
          comments: comments);
      await fetchComplaintDetails(complaintId);
      await fetchComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignOfficer(int complaintId, int officerId,
      {String? comments}) async {
    try {
      await ComplaintService.assignOfficer(complaintId, officerId,
          comments: comments);
      await fetchComplaintDetails(complaintId);
      await fetchComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordResolution(
      int complaintId, String actionTaken, String resolutionSummary) async {
    try {
      final res = await ComplaintService.submitResolution(
        complaintId,
        actionTaken: actionTaken,
        resolutionSummary: resolutionSummary,
      );
      _activeResolution = res;
      await fetchComplaintDetails(complaintId);
      await fetchComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitFeedback(int complaintId,
      {String? feedback,
      int? rating,
      bool reopenRequested = false,
      String? reopenReason}) async {
    try {
      await ComplaintService.submitFeedback(
        complaintId,
        feedback: feedback,
        rating: rating,
        reopenRequested: reopenRequested,
        reopenReason: reopenReason,
      );
      await fetchComplaintDetails(complaintId);
      await fetchComplaints();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
