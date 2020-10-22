{ stdenv, fetchurl, sqlite, postgresql, zlib, acl, ncurses, openssl, readline }:

stdenv.mkDerivation rec {
  name = "bacula-9.6.6";

  src = fetchurl {
    url    = "mirror://sourceforge/bacula/${name}.tar.gz";
    sha256 = "10c25igfvff09nz5ll8rxc46f659rnwimj1v9cdhr67lwdswk1k2";
  };

  buildInputs = [ postgresql sqlite zlib ncurses openssl readline ]
    # acl relies on attr, which I can't get to build on darwin
    ++ stdenv.lib.optional (!stdenv.isDarwin) acl;

  configureFlags = [
    "--with-sqlite3=${sqlite.dev}"
    "--with-postgresql=${postgresql}"
    "--with-logdir=/var/log/bacula"
    "--with-working-dir=/var/lib/bacula"
    "--mandir=\${out}/share/man"
  ] ++ stdenv.lib.optional (stdenv.buildPlatform != stdenv.hostPlatform) "ac_cv_func_setpgrp_void=yes";

  installFlags = [
    "logdir=\${out}/logdir"
    "working_dir=\${out}/workdir"
  ];

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/sbin/* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Enterprise ready, Network Backup Tool";
    homepage    = "http://bacula.org/";
    license     = licenses.gpl2;
    maintainers = with maintainers; [ domenkozar lovek323 eleanor ];
    platforms   = platforms.all;
  };
}
