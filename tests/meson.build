tests_name = meson.project_name() + '-tests'

tests_config = configuration_data()
tests_config.set('source_dir', meson.source_root())
tests_conf = configure_file(input: 'Config.vala', output: 'Config.vala', configuration: tests_config)

tests_files = [
    join_paths(meson.build_root(), '@0@'.format(tests_conf)),
    'Tests.vala'
]

tests = executable(
    tests_name,
    tests_files,
    dependencies: tests_deps
)

test('Tests', tests)