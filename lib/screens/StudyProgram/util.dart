import 'dart:ui';

import 'package:flutter/material.dart';

import '../../models.dart';

Color getColorSubject(SubjectWithUserInfo v) {
  if (v.doingNow == true) return Color(0xffF2C214);

  if (v.tp == true) if (v.grade != null)
    return Color(0xff00AF89);
  else
    return Colors.purple[600]!;
  return Colors.transparent;
}
