# kfs
This is a own made operating system (OS)


# Requirements
## Install grub version
The school computer provides a version of grub that doesn't allow us to boot the iso. We downgrade to version 2.06.<br>
`sh install_grub.sh`<br><br>
Of course, add the newly installed binary to the path.<br>
`export PATH="$PWD/packages/bin:$PATH"`<br><br>
`brew install i686-elf-gcc`

`brew install --with-x86_64-pc-elf --HEAD`

`brew install qemu`
