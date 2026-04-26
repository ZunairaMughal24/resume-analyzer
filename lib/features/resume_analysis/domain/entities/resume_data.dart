import 'package:equatable/equatable.dart';

class ResumeData extends Equatable {
  final String fullName;
  final ResumeContact contact;
  final String summary;
  final List<ExperienceEntry> experience;
  final List<EducationEntry> education;
  final List<String> skills;
  final List<String> certifications;
  final List<ProjectEntry> projects;
  final List<String> languages;

  const ResumeData({
    required this.fullName,
    required this.contact,
    this.summary = '',
    this.experience = const [],
    this.education = const [],
    this.skills = const [],
    this.certifications = const [],
    this.projects = const [],
    this.languages = const [],
  });

  /// Creates a ResumeData from AI-returned structured JSON.
  factory ResumeData.fromJson(Map<String, dynamic> json) {
    return ResumeData(
      fullName: json['fullName'] as String? ?? '',
      contact: ResumeContact.fromJson(
          json['contact'] as Map<String, dynamic>? ?? {}),
      summary: json['summary'] as String? ?? '',
      experience: ((json['experience'] as List?) ?? [])
          .map(
              (e) => ExperienceEntry.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      education: ((json['education'] as List?) ?? [])
          .map((e) => EducationEntry.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      skills: List<String>.from(json['skills'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      projects: ((json['projects'] as List?) ?? [])
          .map((e) => ProjectEntry.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      languages: List<String>.from(json['languages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'contact': contact.toJson(),
        'summary': summary,
        'experience': experience.map((e) => e.toJson()).toList(),
        'education': education.map((e) => e.toJson()).toList(),
        'skills': skills,
        'certifications': certifications,
        'projects': projects.map((e) => e.toJson()).toList(),
        'languages': languages,
      };

  /// Generates clean plain-text representation for sharing/export.
  String toPlainText() {
    final buffer = StringBuffer();
    buffer.writeln(fullName.toUpperCase());
    final contactParts = <String>[];
    if (contact.email.isNotEmpty) contactParts.add(contact.email);
    if (contact.phone.isNotEmpty) contactParts.add(contact.phone);
    if (contact.location.isNotEmpty) contactParts.add(contact.location);
    if (contact.linkedin.isNotEmpty) contactParts.add(contact.linkedin);
    if (contact.github.isNotEmpty) contactParts.add(contact.github);
    if (contact.website.isNotEmpty) contactParts.add(contact.website);
    buffer.writeln(contactParts.join(' | '));
    buffer.writeln();

    if (summary.isNotEmpty) {
      buffer.writeln('PROFESSIONAL SUMMARY');
      buffer.writeln(summary);
      buffer.writeln();
    }

    if (experience.isNotEmpty) {
      buffer.writeln('EXPERIENCE');
      for (final exp in experience) {
        buffer.writeln('${exp.title} | ${exp.company}');
        if (exp.dates.isNotEmpty) buffer.writeln(exp.dates);
        if (exp.location.isNotEmpty) buffer.writeln(exp.location);
        for (final bullet in exp.bullets) {
          buffer.writeln('- $bullet');
        }
        buffer.writeln();
      }
    }

    if (education.isNotEmpty) {
      buffer.writeln('EDUCATION');
      for (final edu in education) {
        buffer.writeln('${edu.degree} | ${edu.institution}');
        if (edu.dates.isNotEmpty) buffer.writeln(edu.dates);
        if (edu.details.isNotEmpty) buffer.writeln(edu.details);
        buffer.writeln();
      }
    }

    if (skills.isNotEmpty) {
      buffer.writeln('SKILLS');
      buffer.writeln(skills.join(', '));
      buffer.writeln();
    }

    if (certifications.isNotEmpty) {
      buffer.writeln('CERTIFICATIONS');
      for (final cert in certifications) {
        buffer.writeln('- $cert');
      }
      buffer.writeln();
    }

    if (projects.isNotEmpty) {
      buffer.writeln('PROJECTS');
      for (final proj in projects) {
        buffer.writeln(proj.name);
        if (proj.description.isNotEmpty) buffer.writeln(proj.description);
        for (final bullet in proj.bullets) {
          buffer.writeln('- $bullet');
        }
        buffer.writeln();
      }
    }

    if (languages.isNotEmpty) {
      buffer.writeln('LANGUAGES');
      buffer.writeln(languages.join(', '));
    }

    return buffer.toString().trim();
  }

  ResumeData copyWith({
    String? fullName,
    ResumeContact? contact,
    String? summary,
    List<ExperienceEntry>? experience,
    List<EducationEntry>? education,
    List<String>? skills,
    List<String>? certifications,
    List<ProjectEntry>? projects,
    List<String>? languages,
  }) {
    return ResumeData(
      fullName: fullName ?? this.fullName,
      contact: contact ?? this.contact,
      summary: summary ?? this.summary,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      projects: projects ?? this.projects,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        contact,
        summary,
        experience,
        education,
        skills,
        certifications,
        projects,
        languages,
      ];
}

class ResumeContact extends Equatable {
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String github;
  final String website;

  const ResumeContact({
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.github = '',
    this.website = '',
  });

  factory ResumeContact.fromJson(Map<String, dynamic> json) {
    return ResumeContact(
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      location: json['location'] as String? ?? '',
      linkedin: json['linkedin'] as String? ?? '',
      github: json['github'] as String? ?? '',
      website: json['website'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'phone': phone,
        'location': location,
        'linkedin': linkedin,
        'github': github,
        'website': website,
      };

  ResumeContact copyWith({
    String? email,
    String? phone,
    String? location,
    String? linkedin,
    String? github,
    String? website,
  }) {
    return ResumeContact(
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      website: website ?? this.website,
    );
  }

  @override
  List<Object?> get props =>
      [email, phone, location, linkedin, github, website];
}

class ExperienceEntry extends Equatable {
  final String title;
  final String company;
  final String dates;
  final String location;
  final List<String> bullets;

  const ExperienceEntry({
    required this.title,
    required this.company,
    this.dates = '',
    this.location = '',
    this.bullets = const [],
  });

  factory ExperienceEntry.fromJson(Map<String, dynamic> json) {
    return ExperienceEntry(
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      dates: json['dates'] as String? ?? '',
      location: json['location'] as String? ?? '',
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'company': company,
        'dates': dates,
        'location': location,
        'bullets': bullets,
      };

  ExperienceEntry copyWith({
    String? title,
    String? company,
    String? dates,
    String? location,
    List<String>? bullets,
  }) {
    return ExperienceEntry(
      title: title ?? this.title,
      company: company ?? this.company,
      dates: dates ?? this.dates,
      location: location ?? this.location,
      bullets: bullets ?? this.bullets,
    );
  }

  @override
  List<Object?> get props => [title, company, dates, location, bullets];
}

class EducationEntry extends Equatable {
  final String degree;
  final String institution;
  final String dates;
  final String details;

  const EducationEntry({
    required this.degree,
    required this.institution,
    this.dates = '',
    this.details = '',
  });

  factory EducationEntry.fromJson(Map<String, dynamic> json) {
    return EducationEntry(
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      dates: json['dates'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'degree': degree,
        'institution': institution,
        'dates': dates,
        'details': details,
      };

  EducationEntry copyWith({
    String? degree,
    String? institution,
    String? dates,
    String? details,
  }) {
    return EducationEntry(
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      dates: dates ?? this.dates,
      details: details ?? this.details,
    );
  }

  @override
  List<Object?> get props => [degree, institution, dates, details];
}

class ProjectEntry extends Equatable {
  final String name;
  final String description;
  final List<String> bullets;

  const ProjectEntry({
    required this.name,
    this.description = '',
    this.bullets = const [],
  });

  factory ProjectEntry.fromJson(Map<String, dynamic> json) {
    return ProjectEntry(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'bullets': bullets,
      };

  ProjectEntry copyWith({
    String? name,
    String? description,
    List<String>? bullets,
  }) {
    return ProjectEntry(
      name: name ?? this.name,
      description: description ?? this.description,
      bullets: bullets ?? this.bullets,
    );
  }

  @override
  List<Object?> get props => [name, description, bullets];
}
