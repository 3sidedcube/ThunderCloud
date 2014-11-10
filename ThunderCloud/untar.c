#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include <sys/stat.h>
#include <errno.h>

#include <zlib.h>

#include "untar.h"

/* Parse an octal number, ignoring leading and trailing nonsense. */
int
parseoct(const char *p, size_t n)
{
	int i = 0;
    
	while ((*p < '0' || *p > '7') && n > 0) {
		++p;
		--n;
	}
	while (*p >= '0' && *p <= '7' && n > 0) {
		i *= 8;
		i += *p - '0';
		++p;
		--n;
	}
	return (i);
}

/* Returns true if this is 512 zero bytes. */
int
is_end_of_archive(const char *p)
{
	int n;
	for (n = 511; n >= 0; --n)
		if (p[n] != '\0')
			return (0);
	return (1);
}

/* Create a directory, including parent directories as necessary. */
void
create_dir(char *pathname, int mode)
{
    if (pathname != NULL) {
        
        char *p;
        int r;
        
        /* Strip trailing '/' */
        if (pathname[strlen(pathname) - 1] == '/')
            pathname[strlen(pathname) - 1] = '\0';
        
        /* Try creating the directory. */
        r = mkdir(pathname, mode);
        
        if (r != 0 && errno != EEXIST) {
            /* On failure, try creating parent directory. */
            p = strrchr(pathname, '/');
            if (p != NULL) {
                *p = '\0';
                create_dir(pathname, 0755);
                *p = '/';
                r = mkdir(pathname, mode);
            }
        }
        if (r != 0 && errno != EEXIST)
            fprintf(stderr, "ERROR CREATING DIRECTORY %s\n", pathname);
        
    }
}

/* Create a file, including parent directory as necessary. */
FILE *
create_file(char *pathname, int mode)
{
	FILE *f;
	f = fopen(pathname, "w+");
	if (f == NULL) {
		/* Try creating parent dir and then creating file. */
		char *p = strrchr(pathname, '/');
		if (p != NULL) {
			*p = '\0';
			create_dir(pathname, 0755);
			*p = '/';
			f = fopen(pathname, "w+");
		}
	}
	return (f);
}

/* Verify the tar checksum. */
int
verify_checksum(const char *p)
{
	int n, u = 0;
	for (n = 0; n < 512; ++n) {
		if (n < 148 || n > 155)
        /* Standard tar checksum adds unsigned bytes. */
			u += ((unsigned char *)p)[n];
		else
			u += 0x20;
        
	}
	return (u == parseoct(p + 148, 8));
}

/* Extract a tar archive. */
void
untar(FILE *a, const char *path)
{
#ifdef ASSET_VERBOSE
    printf("==== storm untar v1.1.2 ====\n");
    clock_t start = clock() / (CLOCKS_PER_SEC / 1000);
    printf("unpacking archive..\n");
#endif
    
	char buff[512];
	FILE *f = NULL;
	size_t bytes_read;
	int filesize;
    
	for (;;) {
		bytes_read = fread(buff, 1, 512, a);
		if (bytes_read < 512) {
#ifdef ASSET_VERBOSE
			fprintf(stderr,
                    "Short read: expected 512, got %d\n", (int)bytes_read);
#endif
			return;
		}
		if (is_end_of_archive(buff)) {
#ifdef ASSET_VERBOSE
            printf("===== completed in %lums ======\n", (clock() / (CLOCKS_PER_SEC / 1000)) - start);
#endif
			return;
		}
		if (!verify_checksum(buff)) {
#ifdef ASSET_VERBOSE
			fprintf(stderr, "Checksum failure\n");
#endif
			return;
		}
		filesize = parseoct(buff + 124, 12);
        
        char *filepath = malloc(sizeof(buff) + sizeof(path) + sizeof("/"));
        if (filepath) {
            strcpy(filepath, path);
            strcat(filepath, "/");
            strcat(filepath, buff);
        }
        
		switch (buff[156]) {
            case '1':
//                printf("> Ignoring hardlink %s\n", buff);
                break;
            case '2':
//                printf("> Ignoring symlink %s\n", buff);
                break;
            case '3':
//                printf("> Ignoring character device %s\n", buff);
				break;
            case '4':
//                printf("> Ignoring block device %s\n", buff);
                break;
            case '5':
                create_dir(filepath, parseoct(buff + 100, 8));
                filesize = 0;
                break;
            case '6':
//                printf("> Ignoring FIFO %s\n", buff);
                break;
            default:
#ifdef ASSET_VERBOSE
                printf("> %s\n", buff);
#endif
                f = create_file(filepath, parseoct(buff + 100, 8));
                break;
		}
		while (filesize > 0) {
			bytes_read = fread(buff, 1, 512, a);
			if (bytes_read < 512) {
#ifdef ASSET_VERBOSE
				fprintf(stderr,
                        "Short read on %s: Expected 512, got %d\n",
                        path, (int)bytes_read);
#endif  
                if (filepath != NULL) free(filepath); // Clear up any memory left for the file path
				return;
			}
			if (filesize < 512)
				bytes_read = filesize;
			if (f != NULL) {
				if (fwrite(buff, 1, bytes_read, f)
				    != bytes_read)
				{
#ifdef ASSET_VERBOSE
					fprintf(stderr, "Failed write\n");
					fclose(f);
					f = NULL;
#endif
				}
			}
			filesize -= bytes_read;
		}
		if (f != NULL) {
			fclose(f);
			f = NULL;
		}
        
        free(filepath);
	}
}

inflatedData
gunzip(const void *data, size_t length)
{
#ifdef ASSET_VERBOSE
    printf("==== storm ungzip v2.0.1 ====\n");
    clock_t start = clock() / (CLOCKS_PER_SEC / 1000);
    printf("inflating archive..\n");
#endif
    
    size_t chunkSize = 4096; // Size of memory page in iOS
    
    if (length > 0) {
        
        size_t decompressed_length = chunkSize;
        Bytef *decompressed = malloc(decompressed_length);
        
        z_stream stream;
        stream.zalloc = Z_NULL;
        stream.zfree = Z_NULL;
        stream.avail_in = (uint)length;
        stream.next_in = (Bytef *)data;
        stream.next_out = decompressed;
        stream.avail_out = (uInt)chunkSize;
        stream.total_out = 0;
        
        // 16+MAX_WBITS enables automatic gzip header recognition
        if (inflateInit2(&stream, 16+MAX_WBITS) == Z_OK)
        {
            int status = Z_OK;
            int chunk = 0;
            while (status == Z_OK)
            {
                if (stream.total_out >= decompressed_length)
                {
                    ++chunk;
                    decompressed_length += chunkSize;
                    decompressed = realloc(decompressed, decompressed_length);
                    stream.next_out = decompressed + stream.total_out;
                    stream.avail_out = (uInt)chunkSize;
                }
                status = inflate(&stream, Z_SYNC_FLUSH);
#ifdef ASSET_VERBOSE
                printf("inflating chunk %d (%lukB)\n", chunk, stream.total_out / 1000);
#endif
            }
            if (inflateEnd(&stream) == Z_OK)
            {
                if (status == Z_STREAM_END)
                {
                    decompressed_length = stream.total_out;
                    
#ifdef ASSET_VERBOSE
                    printf("===== completed in %lums ======\n", (clock() / (CLOCKS_PER_SEC / 1000)) - start);
#endif
                    
                    inflatedData data;
                    data.data = decompressed;
                    data.length = decompressed_length;
                    
                    return data;
                }
            }
        }
        
#ifdef ASSET_VERBOSE
        printf("===== completed in %lums ======\n", (clock() / (CLOCKS_PER_SEC / 1000)) - start);
#endif
        
        inflatedData data;
        data.data = decompressed;
        data.length = decompressed_length;
        
        return data;
    }
    
#ifdef ASSET_VERBOSE
    printf("===== completed in %lums ======\n", (clock() / (CLOCKS_PER_SEC / 1000)) - start);
#endif
    
    inflatedData empty;
    empty.data = NULL;
    empty.length = 0;
    return empty;
}
