require 'ffi-inliner'

module Archive
    module Stat
        extend Inliner
        inline do |builder|
            builder.include 'stdlib.h'
            builder.include 'sys/types.h'
            builder.include 'sys/stat.h'
            builder.c %q{
                 void* ffi_libarchive_create_stat(const char* filename) {
                     struct stat* s = malloc(sizeof(struct stat));
                     if (stat(filename, s) != 0) return NULL;
                     return s;
                 }
            }
            builder.c %q{
                 void* ffi_libarchive_create_lstat(const char* filename) {
                     struct stat* s = malloc(sizeof(struct stat));
                     lstat(filename, s);
                     return s;
                 }
            }
            builder.c %q{
                 void ffi_libarchive_free_stat(void* s) {
                     free((struct stat*)s);
                 }
            }
        end
    end
end
