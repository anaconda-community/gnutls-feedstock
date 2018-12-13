#!/bin/bash

if [ "$(uname)" == "Linux" ]
then
   export LDFLAGS="$LDFLAGS -Wl,-rpath-link,${PREFIX}/lib"
fi

# disable libidn for security reasons:
#   http://lists.gnupg.org/pipermail/gnutls-devel/2015-May/007582.html
# if ever want it back, package and link against libidn2 instead
#
# Also --disable-full-test-suite does not disable all tests but rather
# "disable[s] running very slow components of test suite"

export CPPFLAGS="${CPPFLAGS//-DNDEBUG/}"

./configure --prefix="${PREFIX}" \
            --without-idn \
            --without-libidn2 \
            --disable-full-test-suite \
            --with-included-libtasn1 \
            --with-included-unistring \
            --without-p11-kit || { cat config.log; exit 1; }
make -j${CPU_COUNT}
make install
make -j${CPU_COUNT} check V=1 || { cat tests/test-suite.log; cat tests/slow/test-suite.log; exit 1; }
