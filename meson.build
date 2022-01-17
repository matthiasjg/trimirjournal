project('com.github.matthiasjg.trimirjournal', 'vala', 'c')

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

add_project_arguments(
    ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
    language: 'vala'
)

cat_prog = find_program('cat')

log_chart_webview_partials = files(
    'data/html/partials/head.html',
    'data/html/partials/style-simplecss.html',
    'data/html/partials/script-luxon.html',
    'data/html/partials/script-chartjs.html',
    'data/html/partials/script-chartjs-adapter-luxon.html',
    'data/html/LogChartWebView.html'
)

concat_log_chart_webview_partials = custom_target(
  'concat-partials',
  command: [ cat_prog, '@INPUT@' ],
  capture: true,
  input: log_chart_webview_partials,
  output: 'logChartWebView.html',
  build_by_default: true
)

gresource = gnome.compile_resources(
    'gresource',
    join_paths('data', 'gresource.xml'),
    source_dir: 'data',
    dependencies: [concat_log_chart_webview_partials]    
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
        dependency('gtksourceview-4'),
        dependency('livechart'),
        dependency('libarchive'),
        dependency('webkit2gtk-4.0', version: '>=2.28')
    ]

utils_files = [
    'src/Utils/LogReader.vala',
    'src/Utils/LogWriter.vala',
    'src/Utils/Utils.vala',
    'src/Utils/ZipArchiveHandler.vala'
]

model_files = [
    'src/Model/JournalArchiveModel.vala',
    'src/Model/LogModel.vala',
    'src/Model/TagMetricModel.vala'
]

dao_files = [
    'src/Dao/BaseDao.vala',
    'src/Dao/LogDao.vala'
]

view_files = [
    'src/View/LogRow.vala',
    'src/View/LogView.vala',
    'src/View/LogChartView.vala',
    'src/View/LogChartWebView.vala',
    'src/View/JournalRow.vala',
    'src/View/WelcomeRow.vala',
    'src/View/TagsRow.vala',
    'src/View/SavedSearchesRow.vala',
    'src/View/TagButton.vala',
    'src/View/MainWindow.vala',
    'src/View/WelcomeView.vala'
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
    view_files,
    app_files,
    dependencies: deps,
    install: true,
    link_args: ['-lm']
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
