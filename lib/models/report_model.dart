class ReportSummary {
  final int totalComplaints;
  final int totalDoctors;
  final int totalHospitals;
  final int totalResolved;
  final double avgResolutionDays;
  final Map<String, int> statusBreakdown;
  final List<CategoryCount> categoryBreakdown;
  final List<PriorityCount> priorityBreakdown;
  final List<HospitalCount> hospitalBreakdown;
  final List<DistrictCount> districtBreakdown;

  ReportSummary({
    required this.totalComplaints,
    required this.totalDoctors,
    required this.totalHospitals,
    required this.totalResolved,
    required this.avgResolutionDays,
    required this.statusBreakdown,
    required this.categoryBreakdown,
    required this.priorityBreakdown,
    required this.hospitalBreakdown,
    required this.districtBreakdown,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, int>{};
    if (json['status_breakdown'] is Map) {
      (json['status_breakdown'] as Map).forEach((k, v) {
        statusMap[k.toString()] = int.tryParse(v.toString()) ?? 0;
      });
    }

    final catList = <CategoryCount>[];
    if (json['category_breakdown'] is List) {
      for (var item in json['category_breakdown']) {
        catList.add(CategoryCount(
          name: item['name'] ?? '',
          count: int.tryParse(item['count'].toString()) ?? 0,
        ));
      }
    }

    final prioList = <PriorityCount>[];
    if (json['priority_breakdown'] is List) {
      for (var item in json['priority_breakdown']) {
        prioList.add(PriorityCount(
          priority: item['priority'] ?? '',
          count: int.tryParse(item['count'].toString()) ?? 0,
        ));
      }
    }

    final hospList = <HospitalCount>[];
    if (json['hospital_breakdown'] is List) {
      for (var item in json['hospital_breakdown']) {
        hospList.add(HospitalCount(
          hospital: item['hospital'] ?? '',
          count: int.tryParse(item['count'].toString()) ?? 0,
        ));
      }
    }

    final distList = <DistrictCount>[];
    if (json['district_breakdown'] is List) {
      for (var item in json['district_breakdown']) {
        distList.add(DistrictCount(
          district: item['district'] ?? '',
          count: int.tryParse(item['count'].toString()) ?? 0,
        ));
      }
    }

    return ReportSummary(
      totalComplaints: json['total_complaints'] != null
          ? int.parse(json['total_complaints'].toString())
          : 0,
      totalDoctors: json['total_doctors'] != null
          ? int.parse(json['total_doctors'].toString())
          : 0,
      totalHospitals: json['total_hospitals'] != null
          ? int.parse(json['total_hospitals'].toString())
          : 0,
      totalResolved: json['total_resolved'] != null
          ? int.parse(json['total_resolved'].toString())
          : 0,
      avgResolutionDays: json['avg_resolution_days'] != null
          ? double.tryParse(json['avg_resolution_days'].toString()) ?? 0.0
          : 0.0,
      statusBreakdown: statusMap,
      categoryBreakdown: catList,
      priorityBreakdown: prioList,
      hospitalBreakdown: hospList,
      districtBreakdown: distList,
    );
  }
}

class CategoryCount {
  final String name;
  final int count;
  CategoryCount({required this.name, required this.count});
}

class PriorityCount {
  final String priority;
  final int count;
  PriorityCount({required this.priority, required this.count});
}

class HospitalCount {
  final String hospital;
  final int count;
  HospitalCount({required this.hospital, required this.count});
}

class DistrictCount {
  final String district;
  final int count;
  DistrictCount({required this.district, required this.count});
}
