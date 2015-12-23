%{!?version: %define version %(cat version)}

Name:      qubes-mgmt-salt-all-privacy
Version:   %{version}
Release:   1%{?dist}
Summary:   Installs some privacy related configurations for all users and root user
License:   GPL 2.0
URL:	   http://www.qubes-os.org/

Group:     System administration tools
BuildArch: noarch
Requires:  qubes-mgmt-salt
Requires:  python-augeas

%define _builddir %(pwd)

%description
Installs some privacy related configurations for all users and root user.
  
Updates `~/.bashrc` with `HISTFILESIZE=0` to prevent .bash_history file from
being written to.

Updates `~/.vimrc` to prevent vim history from being written to `~/.viminfo`.
 
Clears `~/.bash_history` and and removes `~/.viminfo`

Updates `/etc/updatedb.conf` to prevent `locate` / `updatedb` from indexing
`/home/**`, `/rw/**` and bind mounts

%prep
# we operate on the current directory, so no need to unpack anything
# symlink is to generate useful debuginfo packages
rm -f %{name}-%{version}
ln -sf . %{name}-%{version}
%setup -T -D

%build

%install
make install DESTDIR=%{buildroot} LIBDIR=%{_libdir} BINDIR=%{_bindir} SBINDIR=%{_sbindir} SYSCONFDIR=%{_sysconfdir}

%post
# Update Salt Configuration
qubesctl state.sls config -l quiet --out quiet > /dev/null || true
qubesctl saltutil.clear_cache -l quiet --out quiet > /dev/null || true
qubesctl saltutil.sync_all refresh=true -l quiet --out quiet > /dev/null || true

# Enable States
qubesctl top.enable privacy saltenv=all -l quiet --out quiet > /dev/null || true

%files
%defattr(-,root,root)
%doc LICENSE README.rst
%attr(750, root, root) %dir /srv/formulas/all/privacy-formula/privacy

/srv/formulas/all/privacy-formula/LICENSE
/srv/formulas/all/privacy-formula/privacy/files/bash_history
/srv/formulas/all/privacy-formula/privacy/files/vimrc
/srv/formulas/all/privacy-formula/privacy/files/updatedb.aug
/srv/formulas/all/privacy-formula/privacy/init.sls
/srv/formulas/all/privacy-formula/privacy/init.top
/srv/formulas/all/privacy-formula/README.rst

%changelog
