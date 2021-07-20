# trimirjournal

## Building and Installation

You'll need the following dependencies:

* libxml2-dev
* libgda-5.0-dev
* glib-2.0
* gobject-2.0
* gtk+-3.0
* libjson-glib-dev
* libgtksourceview-4.0-dev
* libhandy-1-dev
* libgranite-dev
* meson
* valac

You'll also need to init and update these Git submodules with required subprojects (in `subprojects/` directory):

* [Live Chart](https://github.com/lcallarec/live-chart) a real-time charting library for GTK3 and Vala, based on Cairo.

```bash
git submodule init
git submodule update
```

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

# one liner to lint, build and run with debugging enabled
io.elementary.vala-lint && \
    cd build \
    && ninja \
    && ninja install \
    && G_MESSAGES_DEBUG=all io.trimir.journal \
    ; cd -
```

## Translations (i18n)

The app is fully translatable.

Each time new translatable strings are added or old ones change, one should regenerate the `.pot` and `po` files using the commands (targets) `ninja io.trimir.journal-pot` and `ninja io.trimi.journal-update-po` from `build/` dir.

For new languages, just list them in the `po/LINGUAS` file and generate the new `.po` file with the command (target) `ninja io.trimir.journal-update-po`.

... or `make i18n` ;-).

## Build .deb locally

```bash
meson build --prefix=/usr
cd build
ninja
cd ..
dpkg-buildpackage
```

## Flatbak build on Debian Buster

```bash
# flatpak remote-add --if-not-exists elementary https://flatpak.elementary.io/repo.flatpakrepo
# flatpak install io.elementary.Platform
# flatpak install io.elementary.Sdk
flatpak-builder build  io.trimir.journal.yml --user --install --force-clean
flatpak run io.trimir.journal
```

## Editor/ IDE

**Visual Studio Code**

Install Princeton et al's uber-awesome [vala-vscode](https://marketplace.visualstudio.com/items?itemName=prince781.vala) ([src](https://github.com/Prince781/vala-vscode)).

**Codium**

Install [recommended extensions](https://wiki.gnome.org/Projects/Vala/Tools/VisualStudioCode) from `*.vsix` file by downloading it from Visual Studio Marketplace.

## elementary Resources

- https://elementary.io/docs/human-interface-guidelines#color
- https://github.com/elementary/icons

## Vala & GTK Resources

[vala-language-server](https://github.com/Prince781/vala-language-server)

[Vala support for Visual Studio Code](https://github.com/Prince781/vala-vscode)

To make it easier to follow the [elementary Code-Style guidelines](https://elementary.io/docs/code/reference#code-style) one can use [vala-lint](https://github.com/vala-lang/vala-lint):

```bash
cd  ~/Code
git clone https://github.com/vala-lang/vala-lint
cd vala-lint
sudo apt install cmake libvala-0.48-dev
meson build --prefix=/usr
cd build
ninja test
sudo ninja install
io.elementary.vala-lint
```

[Gtk Inspecteur](https://elementary.io/docs/code/os-dev#gtk-inspector) (from ` elementary-sdk`):

```bash
gsettings set org.gtk.Settings.Debug enable-inspector-keybinding true
# GTK_DEBUG=interactive io.trimir.journal
```

[awesome-vala](https://github.com/desiderantes/awesome-vala)

[awesome-gtk](https://github.com/unrelentingtech/awesome-gtk), a list of native, open source GTK (3 and 4) applications.

[libgda vala samples](https://gitlab.gnome.org/GNOME/libgda/-/tree/LIBGDA_5_2_8/samples/vala)

[todo-vala-example (gda)](https://github.com/undeadspez/todo-vala-example)

[Writing tests for Vala](https://esite.ch/2012/06/writing-tests-for-vala/)

[design-patterns-for-humans/vala](https://github.com/design-patterns-for-humans/vala)

[live-chart](https://github.com/lcallarec/live-chart)

[vala: Serializing object property with Json.gobject_serialize?](https://stackoverflow.com/questions/43344017/vala-serializing-object-property-with-json-gobject-serialize/58461239)

## Flatpak Resources

- https://docs.flatpak.org/en/latest/sandbox-permissions.html

## elementary OS Resources

[awesome-elementaryos](https://github.com/kleinrein/awesome-elementaryos)