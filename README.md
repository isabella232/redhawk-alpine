# redhawk-alpine
> Core REDHAWK Alpine Linux image resources

## Instructions
Build with default REDHAWK 2.2.6 source code: 

    $ docker build -t redhawk-alpine .
Build with modified Alpine REDHAWK 2.2.6 source code (described below):

    $ docker build -t redhawk-alpine . --build-arg SRC="local"
    
## Notes
The modified Alpine REDHAWK 2.2.6 source code is the product of an attempt to quickly remedy build errors while compiling on Alpine. It's possible that these modification would break REDHAWK functionality -- they should be reviewed should the local code ever build successfully.
Commented out the following lines of the following files:
	redhawk/src/configure.ac 275-279
	redhawk/src/base/framework/ExecutableDevice_impl.cpp 377
	redhawk/src/base/include/ossie/shm/MappedFile.h 38
	redhawk/src/base/framework/shm/MappedFile.cpp 39
	redhawk/src/base/framework/shm/Heap.cpp 220

Replaced all instances of "MappedFile::PAGE\_SIZE" with "sysconf(\_SC\_PAGESIZE)":
	
    $ grep -rli 'MappedFile::PAGE_SIZE' * | xargs -i@ sed -i 's/MappedFile::PAGE\_SIZE/sysconf(\_SC\_PAGESIZE)/g' @
