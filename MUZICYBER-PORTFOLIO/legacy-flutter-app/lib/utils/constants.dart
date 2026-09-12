import 'package:flutter/material.dart';

const toolDefinitions =
    <
      ({String id, String name, String description, IconData icon, String hint})
    >[
      (
        id: 'phone',
        name: 'Phone intelligence',
        description: 'International format & number validation',
        icon: Icons.phone_outlined,
        hint: '+923001234567',
      ),
      (
        id: 'email',
        name: 'Email intelligence',
        description: 'Email syntax & domain research leads',
        icon: Icons.alternate_email,
        hint: 'analyst@example.com',
      ),
      (
        id: 'username',
        name: 'Username search',
        description: 'Public profile leads for manual review',
        icon: Icons.person_search_outlined,
        hint: 'username',
      ),
      (
        id: 'domain',
        name: 'Domain intelligence',
        description: 'Live DNS records & registration leads',
        icon: Icons.language,
        hint: 'example.com',
      ),
      (
        id: 'ip',
        name: 'IP intelligence',
        description: 'Address analysis & registration leads',
        icon: Icons.router_outlined,
        hint: '8.8.8.8',
      ),
    ];
String shortDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
