FROM        debian:latest 

 RUN        apt-get        update 
 RUN        apt-get        install build-essential xorriso nasm -y 
 RUN        apt-get        install grub-pc-bin -y
 RUN        apt-get        install build-essential procps curl file git -y
#  RUN        test           -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
#  RUN        test           -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#  RUN        test           -r ~/.bash_profile && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bash_profile
#  RUN        echo           "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.profile
 RUN        git            clone --depth=1 https://github.com/Homebrew/brew
 RUN        brew           update
 RUN        brew           install i686-elf-gcc -y

 WORKDIR        /kfs