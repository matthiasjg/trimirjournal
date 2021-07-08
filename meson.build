project('io.trimir.journal', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gresource = gnome.compile_resources(
    'gresource',
    join_paths('data', 'gresource.xml'),
    source_dir: 'data'
)

debs = [
        dependency('libxml-2.0'),
        dependency('libgda-5.0'),
        dependency('glib-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        dependency('json-glib-1.0'),
	    dependency('granite', version: '>=0.5'),
        dependency('libhandy-1', version: '>=0.90.0'),
        dependency('gtksourceview-4')
    ]

utils_files = [
    'src/Utils.vala'
]

model_files = [
    'src/LogModel.vala'
]

dao_files = [
    'src/LogDao.vala'
]

app_files = [
    'src/Application.vala',
    'src/LogReader.vala',
    'src/MainWindow.vala',
    'src/Controller.vala',
    'src/LogRow.vala',
    'src/LogView.vala',
    'src/JournalRow.vala',
    'src/TagButton.vala'
]

executable(
    meson.project_name(),
    gresource,
    utils_files,
    model_files,
    dao_files,
    app_files,
    dependencies: debs,
    install: true
)

tests_name = meson.project_name() + '-tests'

tests_deps = debs

tests_files = [
    utils_files,
    model_files,
    dao_files,
    'src/Tests.vala'
]

tests = executable(
    tests_name,
    tests_files,
    dependencies: tests_deps
)

test('Tests', tests)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
