# trimirjournal

## Building and Installation

You'll need the following dependencies:
* glib-2.0
* gobject-2.0
* gtk+-3.0
* libhandy-1-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

```bash
meson build --prefix=/usr
cd build
ninja
```

To install, use `ninja install`, then execute with `io.trimir.journal`

```bash
ninja install
io.trimir.journal
```

## Translations (i18n)

The app is fully translatable.

Each time new translatable strings are added or old ones change, one should regenerate the `.pot` and `po` files using the commands (targets) `ninja io.trimir-journal-pot` and `ninja io.trimir-journal-update-po` from `build/` dir.

For new languages, just list them in the `po/LINGUAS` file and generate the new `.po` file with the command (target) `ninja io.trimir-journal-update-po`.

## Build .deb locally

```bash
meson build --prefix=/usr
cd build
ninja
cd ..
dpkg-buildpackage
```

## Coding in Vala with ~~Visual Studio Code~~ Codium

Install [recommended extensions](https://wiki.gnome.org/Projects/Vala/Tools/VisualStudioCode) from `*.vsix` file by downloading it from Visual Studio Marketplace.
