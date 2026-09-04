import 'dart:io';

import 'package:khnum/khnum.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final views = p.join(
    Directory.current.path,
    'lib',
    'skeleton',
    'resources',
    'views',
  );
  final fixtures = p.join(Directory.current.path, 'test', 'fixtures', 'views');
  final khnum = Khnum(
    viewsPath: fixtures,
    componentsPath: p.join(views, 'components'),
  );
  // Layouts live under the real skeleton views (not the fixtures dir), so
  // they need a Khnum instance rooted there to resolve `layouts.app`.
  final layoutKhnum = Khnum(
    viewsPath: views,
    componentsPath: p.join(views, 'components'),
  );

  test('every component renders', () {
    for (final name in [
      'button',
      'input',
      'label',
      'card',
      'alert',
      'badge',
      'nav-link',
    ]) {
      expect(
        File(p.join(views, 'components', '$name.khnum.html')).existsSync(),
        isTrue,
        reason: 'components/$name.khnum.html is missing',
      );
    }
  });

  test('the button component honours its variant prop', () {
    final html = khnum.renderSync('button-page', {'variant': 'secondary'});
    expect(html, contains('Save'));
    expect(html, contains('<button'));
    expect(html, contains('bg-white'));
  });

  test('@props defaults apply when a component is used without overrides', () {
    final html = khnum.renderSync('button-default-page');
    expect(html, contains('Save'));
    expect(html, contains('bg-indigo-600'));
  });

  test('the badge component escapes its slot', () {
    final html = khnum.renderSync('badge-page', {
      'script': '<script>alert(1)</script>',
    });
    expect(html, isNot(contains('<script>')));
    expect(html, contains('&lt;script&gt;'));
  });

  test('the app layout links the compiled stylesheet and loads Alpine', () {
    layoutKhnum.function('asset', (args) => '/${args.first}');
    final html = layoutKhnum.renderSync('layouts.app', {'appName': 'Test'});
    expect(html, contains('/css/app.css'));
    expect(html, contains('alpinejs@3.17.1'));
    expect(html, contains('integrity="sha384-'));
    expect(html, contains('x-data'));
    // The sidebar renders <x-nav-link> for real, not just references it:
    // check its actual output (href + the classes @props renders).
    expect(html, contains('href="/"'));
    expect(html, contains('group flex gap-x-3 rounded-md'));
  });

  test('the guest layout has no navigation chrome', () {
    layoutKhnum.function('asset', (args) => '/${args.first}');
    final html = layoutKhnum.renderSync('layouts.guest', {'appName': 'Test'});
    expect(html, contains('/css/app.css'));
    expect(html, isNot(contains('<nav')));
  });

  test('welcome renders through the guest layout', () {
    layoutKhnum.function('asset', (args) => '/${args.first}');
    final html = layoutKhnum.renderSync('welcome', {'appName': 'Test'});
    expect(html, contains('<!doctype html>'));
    expect(html, contains('/css/app.css'));
    expect(html, contains('Test'));
  });

  test('dashboard renders through the app layout', () {
    layoutKhnum.function('asset', (args) => '/${args.first}');
    final html = layoutKhnum.renderSync('dashboard', {'appName': 'Test'});
    expect(html, contains('x-data'));
    expect(html, contains('/css/app.css'));
    // <x-card> renders for real, not just referenced: check its actual
    // heading markup and container classes.
    expect(
      html,
      contains(
        '<h3 class="text-base font-semibold leading-6 text-gray-900 dark:text-white">Getting started</h3>',
      ),
    );
    expect(
      html,
      contains(
        'overflow-hidden rounded-lg bg-white shadow-sm ring-1 ring-gray-900/5',
      ),
    );
  });
}
