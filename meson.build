project('com.github.KaltWulx.duplicatefiles', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)
i18n = import('i18n')
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

dependencies = [
	dependency('gobject-2.0'),
	dependency('glib-2.0'),
	dependency('gtk+-3.0'),
	dependency('granite'),
	dependency('gee-0.8'),
]

sources = files(
	'src/Application.vala',


	'src/View/Welcome.vala',
	'src/View/PrepareHomeScan.vala',
	'src/View/StartHomeScan.vala',
	'src/View/Resume.vala',
		'src/View/Widgets/CategoryListRow.vala',
		'src/View/Widgets/Panel.vala',
		'src/View/Widgets/DuplicateViewer.vala',

	'src/core/Scanner.vala',
	'src/core/FileOcurrence.vala',
)

subdir('src')

executable(
	meson.project_name(),
	sources,
	dependencies: dependencies, install:true
)
