#!/usr/bin/bash
if [ -f "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" ]; then
    vspath="C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"
	toolset="12"
elif [ -f "C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat" ]; then
    vspath="C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
	toolset="11"
elif [ -f "C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat" ]; then
    vspath="C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\vsvars32.bat"
	toolset="12"
elif [ -f "C:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat" ]; then
    vspath="C:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools\vsvars32.bat"
	toolset="11"
fi
cd ~/LSW/AviSynth
cat > "bld_lsw_avs.bat" << EOF
@echo off
chcp 1252
call "${vspath}"
devenv LSMASHSourceVCX.sln /upgrade
set CL=/O2 /Oi /DLSMASHSOURCE_EXPORTS /I$(cygpath -was /mingw32/include)
set LINK="libpthread.a" "libiconv.a" "libopenjpeg.a" "libopus.a" "liblzma.a" "libswresample.a" "libmsvcrt.a" /LIBPATH:$(cygpath -was /mingw32/lib) /LIBPATH:$(cygpath -was /mingw32/i686-w64-mingw32/lib) /LIBPATH:$(cygpath -was /mingw32/lib/gcc/i686-w64-mingw32/4.9.2)
msbuild.exe LSMASHSourceVCX.sln /target:Rebuild /p:Configuration=Release;Platform="Win32";PlatformToolset=v${toolset}0_xp
chcp 65001
EOF

cmd.exe /c bld_lsw_avs.bat

cd ~
if [ -f ~/LSW/AviSynth/Release/LSMASHSource.dll ]; then
cd ~/LSW/AviSynth/Release
cp LSMASHSource.dll /ReadyToUse32/
cd ../
cp README /ReadyToUse32/
cp LICENSE /ReadyToUse32/
cd /ReadyToUse32
7z a -y -t7z -m0=lzma2 -mx=9 -ms=on L-Smash_Works_AviSynth_win32_$(date +'%Y%m%d').7z LSMASHSource.dll LICENSE README
ls

echo -e "\E[36;40m DONE!\E[0m"
tput sgr0 # Reset text attributes to normal without clear
else
echo "Failed to build L-Smash_Works_AviSynth_win32"
fi
