# Windows installation
# Download the appropriate installer from here:
# https://docs.docker.com/desktop/setup/install/windows-install/
# Put it in the same directory as this script

# Install docker and set directories to D:\ drive
Start-Process 'Docker Desktop Installer.exe' -Wait -ArgumentList 'install',
    '--windows-containers-default-data-root=D:\docker\containers',
    '--wsl-default-data-root=D:\docker\wsl'