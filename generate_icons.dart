// Script to generate app icons for both flavors
import 'dart:io';

void main() async {
  print('Generating app icons for user flavor...');
  await Process.run('flutter', ['pub', 'run', 'flutter_launcher_icons', '-f', 'flutter_icons_user.yaml']);
  
  print('Generating app icons for admin flavor...');
  await Process.run('flutter', ['pub', 'run', 'flutter_launcher_icons', '-f', 'flutter_icons_admin.yaml']);
  
  print('App icons generated successfully!');
} 