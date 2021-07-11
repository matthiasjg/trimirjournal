project('io.trimir.journal', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

gresource = gnome.compile_resources(
    'gresource',
    join_paths('data', 'gresource.xml'),
    source_dir: 'data'
)

deps = [
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
    'src/Utils/Utils.vala',
    'src/Utils/LogReader.vala'
]

model_files = [
    'src/Model/LogModel.vala'
]

dao_files = [
    'src/Dao/BaseDao.vala',
    'src/Dao/LogDao.vala'
]

ui_files = [
    'src/Ui/LogRow.vala',
    'src/Ui/LogView.vala',
    'src/Ui/JournalRow.vala',
    'src/Ui/TagButton.vala',
    'src/Ui/MainWindow.vala'
]

app_files = [
    'src/Application.vala',
    'src/Controller.vala'
]

executable(
    meson.project_name(),
    gresource,
    utils_files,
    model_files,
    dao_files,
    ui_files,
    app_files,
    dependencies: deps,
    install: true
)

subdir('data')
subdir('po')

tests_deps = declare_dependency(
    dependencies: deps,
    sources: [
        utils_files,
        model_files,
        dao_files
    ],
    include_directories: [include_directories('.')]
)
subdir('tests')

meson.add_install_script('meson/post_install.py')
