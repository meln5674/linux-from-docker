{{- define "download" -}}
{{- $pkg := . }}
# download {{ $pkg.name }}
{{- $urlVar := print ($pkg.name | strings.SnakeCase | strings.ToUpper) "_URL" }}
ARG {{ $urlVar }}={{ $pkg.url }}
{{- if $pkg.url | strings.HasSuffix "patch" }}
WORKDIR $LFS_SRC
RUN curl -vfL ${{ $urlVar }} > {{ $pkg.name }}.patch
{{- else }}
{{ $extractFlag := "" }}
{{- if $pkg.url | strings.HasSuffix "xz" }}
{{- $extractFlag = "J" }}
{{- else if $pkg.url | strings.HasSuffix "gz" }}
{{- $extractFlag = "z" }}
{{- else if $pkg.url | strings.HasSuffix "bz2" }}
{{- $extractFlag = "j" }}
{{- end }}
WORKDIR $LFS_SRC/{{ $pkg.name }}
{{- $tarFlags := "--strip-components=1" }}
{{- if coll.Has $pkg "tarFlags" }}
{{- $tarFlags = $pkg.tarFlags }}
{{- end }}
RUN curl -vfL ${{ $urlVar }} | tar -x{{ $extractFlag }} {{ $tarFlags }}
{{- end }}
{{- end -}}

{{- define "build" -}}
{{- $pkg := . }}
# build {{ $pkg.name }}
WORKDIR $LFS_SRC/{{ $pkg.name }}
{{- if coll.Has $pkg "preBuildSteps" }}
{{ $pkg.preBuildSteps }}
{{- end }}
RUN --mount=type=bind,source=util/install-{{ $pkg.name }}.sh,target=$LFS_SRC/build.sh \
    \
    $LFS_SRC/build.sh
{{- if coll.Has $pkg "postBuildSteps" }}
{{ $pkg.postBuildSteps }}
{{- end }}

{{ end -}}

{{- $dot := coll.Dict "Values" (datasource "Values") -}}
ARG LFS=/mnt/lfs
ARG LFS_SRC=/src/lfs
ARG LC_ALL=POSIX
ARG LFS_TGT=unknown-lfs-linux-gnu
ARG CONFIG_SITE=$LFS/usr/share/config.site
ARG MAKEFLAGS=

FROM {{ $dot.Values.host.image }} AS host

ARG LFS
ARG LFS_SRC
ARG LC_ALL
ARG LFS_TGT
ARG CONFIG_SITE
ARG MAKEFLAGS


{{ $dot.Values.host.steps }}


ENV LFS=$LFS
ENV LFS_SRC=/src/lfs
ENV LC_ALL=$LC_ALL
ENV LFS_TGT=$LFS_TGT
ENV CONFIG_SITE=$CONFIG_SITE
ENV PATH=$LFS/tools/bin:$PATH
ENV MAKEFLAGS=$MAKEFLAGS

{{- $pkgMap := coll.Dict }}
{{- range $pkgIX, $pkg := $dot.Values.packages }}
{{- $pkgMap = coll.Merge $pkgMap (coll.Dict $pkg.name $pkg) }}
{{ if coll.Has $pkg "srcFrom" -}}
FROM {{ $pkg.srcFrom }}-dl AS {{ $pkg.name }}-dl
RUN ln -s $LFS_SRC/{{ $pkg.srcFrom }} $LFS_SRC/{{ $pkg.name }}
{{- else if coll.Has $pkg "url" }}
FROM host AS {{ $pkg.name }}-dl
{{ template "download" $pkg }}
{{ end }}

{{- end }}


{{- range $stageIX, $stage := $dot.Values.stages }}

FROM {{ $stage.parent }} AS {{ $stage.name }}
ARG LFS
ARG LFS_SRC
ARG LC_ALL
ARG LFS_TGT
ARG CONFIG_SITE
ARG MAKEFLAGS

{{- if coll.Has $stage "lfsInstall" }}
{{- range $pkg := $stage.lfsInstall }}
COPY --from={{ $pkg }} $LFS/. $LFS/
{{- end }}
{{- end }}
{{- if coll.Has $stage "install" }}
{{- range $pkg := $stage.install }}
COPY --from={{ $pkg }} $LFS/. /
{{- end }}
{{- end }}


{{- if coll.Has $stage "preSteps" }}
{{ $stage.preSteps }}
{{- end }}



{{- if coll.Has $stage "packages" }}
{{- range $pkgname := $stage.packages }}
{{- $pkg := index $pkgMap $pkgname }}
{{- if not $pkg }}
{{ print "Stage " $stage.name " has unknown package " $pkgname | test.Fail }}
{{- end }}
FROM {{ $stage.name }} AS {{ $pkg.name }}
ARG LFS
ARG LFS_SRC
ARG LC_ALL
ARG LFS_TGT
ARG CONFIG_SITE
ARG MAKEFLAGS


COPY --from={{ $pkg.name }}-dl $LFS_SRC/. $LFS_SRC/
WORKDIR $LFS_SRC/{{ $pkg.name }}
{{- if coll.Has $pkg "srcDeps" }}
{{- range $dep := $pkg.srcDeps }}
COPY --from={{ $dep }}-dl $LFS_SRC/. $LFS_SRC/
{{- end }}
{{- end }}
{{- if coll.Has $pkg "deps" }}
{{- range $dep := $pkg.deps }}
COPY --from={{ $dep }} $LFS/. /
{{- end }}
{{- end }}
{{- if coll.Has $pkg "lfsDeps" }}
{{- range $dep := $pkg.lfsDeps }}
COPY --from={{ $dep }} $LFS/. $LFS/
{{- end }}
{{- end }}
{{ if coll.Has $pkg "patches" }}
# patch {{ $pkg.name }}
{{- range $patch := $pkg.patches }}
COPY --from={{ $patch.name }}-dl $LFS_SRC/{{ $patch.name }}.patch $LFS_SRC/{{ $patch.name }}.patch
RUN {{ $patch.cmd }} $LFS_SRC/{{ $patch.name }}.patch
{{- end }}
{{- end }}

{{ template "build" $pkg }}

{{- end }}
{{- end }}

{{- end }}
