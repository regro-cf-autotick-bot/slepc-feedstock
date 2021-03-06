#!/bin/bash

export PETSC_DIR=$PREFIX
export SLEPC_DIR=$SRC_DIR
export SLEPC_ARCH=installed-arch-conda-c-opt

unset CC
unset CXX

$PYTHON ./configure \
  --prefix=$PREFIX

sedinplace() { [[ $(uname) == Darwin ]] && sed -i "" $@ || sed -i"" $@; }
sedinplace s%$SLEPC_DIR%\${SLEPC_DIR}%g $SLEPC_ARCH/include/slepc*.h
sedinplace s%$PETSC_DIR%\${PETSC_DIR}%g $SLEPC_ARCH/include/slepc*.h

make

# FIXME: Workaround mpiexec setting O_NONBLOCK in std{in|out|err}
# See https://github.com/conda-forge/conda-smithy/pull/337
# See https://github.com/pmodels/mpich/pull/2755
make check MPIEXEC="${RECIPE_DIR}/mpiexec.sh"

make install

rm -fr $PREFIX/bin && mkdir $PREFIX/bin
rm -fr $PREFIX/share && mkdir $PREFIX/share
rm -fr $PREFIX/lib/lib$PKG_NAME.*.dylib.dSYM
rm -f  $PREFIX/lib/$PKG_NAME/conf/files
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.py
rm -f  $PREFIX/lib/$PKG_NAME/conf/*.log
rm -f  $PREFIX/lib/$PKG_NAME/conf/RDict.db
rm -f  $PREFIX/lib/$PKG_NAME/conf/*BuildInternal.cmake
find   $PREFIX/include -name '*.html' -delete
