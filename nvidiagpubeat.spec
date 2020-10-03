%define _build_id_links none
Summary: nvidiagpubeat
Name: nvidiagpubeat
Version: 6.8.0
Release: 1
License: Apache
Source: %{expand:%%(pwd)}
BuildRoot: %{_topdir}/BUILD/%{name}-%{version}-%{release}

%description
%{summary}

%prep
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/share/nvidiagpubeat/bin
mkdir -p $RPM_BUILD_ROOT/etc/nvidiagpubeat
mkdir -p $RPM_BUILD_ROOT/var/lib/nvidiagpubeat
mkdir -p $RPM_BUILD_ROOT/var/log/nvidiagpubeat
mkdir -p $RPM_BUILD_ROOT/lib/systemd/system
mkdir -p $RPM_BUILD_ROOT/etc/init.d
cd $RPM_BUILD_ROOT
cp %{SOURCEURL0}/nvidiagpubeat ./usr/share/nvidiagpubeat/bin/
cp %{SOURCEURL0}/nvidiagpubeat-god ./usr/share/nvidiagpubeat/bin/
cp %{SOURCEURL0}/LICENSE ./usr/share/nvidiagpubeat/
cp %{SOURCEURL0}/nvidiagpubeat.yml ./etc/nvidiagpubeat/
cp %{SOURCEURL0}/nvidiagpubeat.template.json ./etc/nvidiagpubeat/
cp %{SOURCEURL0}/nvidiagpubeat.service ./lib/systemd/system
cp %{SOURCEURL0}/nvidiagpubeat.init.d ./etc/init.d/nvidiagpubeat

%clean
rm -r -f "$RPM_BUILD_ROOT"

%files
%defattr(644,root,root)
"/etc/nvidiagpubeat/nvidiagpubeat.yml"
"/etc/nvidiagpubeat/nvidiagpubeat.template.json"
"/usr/share/nvidiagpubeat/LICENSE"
"/lib/systemd/system/nvidiagpubeat.service"
%attr(755,root,root) "/usr/share/nvidiagpubeat/bin/nvidiagpubeat"
%attr(755,root,root) "/usr/share/nvidiagpubeat/bin/nvidiagpubeat-god"
%attr(755,root,root) "/var/lib/nvidiagpubeat"
%attr(750,root,root) "/var/log/nvidiagpubeat"
%attr(755,root,root) "/etc/init.d/nvidiagpubeat"

