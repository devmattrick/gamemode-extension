#!/bin/sh
# Largely inspired by Florian Müllner gnome-shell-extensions/export-zips.sh

builddir="build/"

srcdir=`dirname $0`
srcdir=`(cd $srcdir && pwd)`

# create temp env
builddir=`mktemp -p $srcdir -d _build.XXXXXX` || exit 1
installdir=`mktemp -p $srcdir -d _install.XXXXXX` || exit 1

# build the project
meson setup --prefix=$installdir $srcdir $builddir
ninja -C$builddir install

# extract names from metadata.json
uuid=`(jq -r .uuid "$builddir/metadata.json")`
name=`(jq -r '."extension-id"' "$builddir/metadata.json")`

zipname="$uuid.shell-extension.zip"

rm -f "$srcdir/$zipname"

extensiondir=$installdir/share/gnome-shell/extensions/$uuid
schemadir=$installdir/share/glib-2.0/schemas
localedir=$installdir/share/locale

schema=$schemadir/org.gnome.shell.extensions.$name.gschema.xml

(cd $extensiondir && zip -rmq $srcdir/$zipname .)

rm -rf $builddir
rm -rf $installdir

# optional arguments

usage_error () {
    echo "usage: $0 [install]"
    exit 1
}

install () {
    extensionhome="${HOME}/.local/share/gnome-shell/extensions"
    targetdir="${extensionhome}/${uuid}"

    # remove old stuff
    rm -rf ${targetdir}

    # unzip to the target
    mkdir -p "${extensionhome}"
    unzip "${srcdir}/${zipname}" -d $targetdir}

    echo "${name} installed to ${targetdir}"
}

if [ "$#" -ge 1 ]; then
    case "$1" in
    install)
        install
        ;;
    *)
        usage_error
        ;;
    esac
fi

