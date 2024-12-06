# Lamina Operating System

This operating system is written in C++ and is used to build, manage, and create software as i hate linux, BSD, Windows, and most other minor kernels. Why? Because I didn't make them.

## Building Lamina-Nel

1. `git clone https://github.com/UmbraAether/Lamina-Nel.git`
2. `cd Lamina-Nel`
3. `install-deps`  
   *Note: This currently works for pacman, apt may have issues with certain packages, no other package managers included so far.*
3. `install-deps`  *Note: This currently works for pacman, apt may have issues with certain packages, no other package managers included so far.*
4. `make install`
5. `make run`

To clean out the object files, bin files, and other files needed, use:
```bash
make clean
