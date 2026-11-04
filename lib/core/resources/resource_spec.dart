import 'package:flutter/material.dart';

import 'json_resource.dart';

/// How a field is rendered and parsed in the shared resource form.
enum ResourceFieldType {
  text,
  multiline,
  integer,
  decimal,
  boolean,
  select,
  date,
  password,
  json,
}

class ResourceOption {
  const ResourceOption(this.value, this.label);

  final String value;
  final String label;
}

/// A single-select query filter rendered as chips above the list.
class ResourceFilterSpec {
  const ResourceFilterSpec({
    required this.param,
    required this.labelKey,
    required this.options,
    this.allLabelKey = 'all',
  });

  final String param;
  final String labelKey;
  final List<ResourceOption> options;
  final String allLabelKey;
}

/// One column of a resource: used by the list card, the detail rows and the
/// create/edit form.
class ResourceFieldSpec {
  const ResourceFieldSpec({
    required this.key,
    required this.labelKey,
    this.type = ResourceFieldType.text,
    this.required = false,
    this.options = const <ResourceOption>[],
    this.maxLines = 1,
    this.helperKey,
    this.showInDetail = true,
    this.showInForm = true,
    this.suffix,
    this.validator,
  });

  final String key;
  final String labelKey;
  final ResourceFieldType type;
  final bool required;
  final List<ResourceOption> options;
  final int maxLines;
  final String? helperKey;
  final bool showInDetail;
  final bool showInForm;
  final String? suffix;
  final String? Function(String? value)? validator;

  bool get isBoolean => type == ResourceFieldType.boolean;
}

/// A POST/PATCH/DELETE action offered on a resource detail screen.
class ResourceActionSpec {
  const ResourceActionSpec({
    required this.labelKey,
    required this.path,
    this.method = 'POST',
    this.body,
    this.confirmKey,
    this.icon,
    this.destructive = false,
    this.visible,
  });

  final String labelKey;
  final String Function(JsonResource resource) path;
  final String method;
  final Map<String, dynamic>? Function(JsonResource resource)? body;
  final String? confirmKey;
  final IconData? icon;
  final bool destructive;
  final bool Function(JsonResource resource)? visible;
}

/// Everything a generic admin screen needs to know about one API resource.
class ResourceSpec {
  const ResourceSpec({
    required this.titleKey,
    required this.path,
    required this.icon,
    required this.fields,
    required this.title,
    this.subtitle,
    this.status,
    this.detailPath,
    this.detailRoute,
    this.fetchDetail = true,
    this.searchable = true,
    this.searchParam = 'search',
    this.extraQuery = const <String, dynamic>{},
    this.filters = const <ResourceFilterSpec>[],
    this.canCreate = false,
    this.createPath,
    this.createLabelKey = 'create',
    this.canEdit = false,
    this.editPath,
    this.canDelete = false,
    this.deletePath,
    this.actions = const <ResourceActionSpec>[],
    this.emptyIcon,
    this.emptyTitleKey = 'nothingHereYet',
    this.extraDetail,
    this.extraForm,
  });

  final String titleKey;
  final String path;
  final IconData icon;
  final List<ResourceFieldSpec> fields;
  final String Function(JsonResource resource) title;
  final String? Function(JsonResource resource)? subtitle;
  final String? Function(JsonResource resource)? status;

  /// The API endpoint that returns one row. Defaults to `path/id`.
  final String? Function(JsonResource resource)? detailPath;

  /// The in-app route that shows one row. Defaults to [detailPathFor] because
  /// most admin resources deliberately mirror their API path in the router.
  final String? Function(JsonResource resource)? detailRoute;

  final bool fetchDetail;
  final bool searchable;
  final String searchParam;
  final Map<String, dynamic> extraQuery;
  final List<ResourceFilterSpec> filters;
  final bool canCreate;
  final String? createPath;
  final String createLabelKey;
  final bool canEdit;
  final String? Function(JsonResource resource)? editPath;
  final bool canDelete;
  final String? Function(JsonResource resource)? deletePath;
  final List<ResourceActionSpec> actions;
  final IconData? emptyIcon;
  final String emptyTitleKey;

  /// Optional bespoke section rendered below the generic detail rows.
  final Widget Function(BuildContext context, JsonResource resource)?
      extraDetail;

  /// Optional bespoke widgets rendered above the generic form fields.
  final Widget Function(BuildContext context)? extraForm;

  String detailPathFor(JsonResource resource) =>
      detailPath?.call(resource) ?? '$path/${resource.id}';

  String detailRouteFor(JsonResource resource) =>
      detailRoute?.call(resource) ?? detailPathFor(resource);
}
