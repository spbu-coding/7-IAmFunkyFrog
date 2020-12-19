#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define error(...) (fprintf(stderr, __VA_ARGS__))
#define  MAX_INPUT_STRING_SIZE 1000

typedef char** strings_array_t;

int isprintable(char c) {
    char not_printable[] = ".,;:!?";
    for(size_t i = 0; i < strlen(not_printable); i++) {
        if(not_printable[i] == c) return 0;
    }
    return 1;
}

int des(const void* str1, const void* str2) {
    return -strcmp(*((char**) str1), *((char**) str2));
}

void free_strings_array(strings_array_t strings_array, size_t size) {
    for(size_t i = 0; i < size; i++)
        free(strings_array[i]);
    free(strings_array);
    strings_array = NULL;
}

int get_strings_from_file(FILE* file, size_t max_string_length, strings_array_t *strings_array) {
    const int realloc_size = 10;
    int size;
    char buffer[MAX_INPUT_STRING_SIZE];

    for(size = 0;; size++) {
        if(fgets(buffer, max_string_length, file) == NULL) break;
        if(size % realloc_size == 0) {
            void *memory = realloc(*strings_array, (size + realloc_size) * sizeof(char*));
            if(memory == NULL) {
                error("Error with allocation memory in get_strings_from_file");
                free_strings_array(*strings_array, size);
                free(*strings_array);
                return -1;
            }
            else {
                *strings_array = memory;
            }
        }
        (*strings_array)[size] = calloc(sizeof(char), MAX_INPUT_STRING_SIZE);
        for(size_t i = 0, j = 0; i < strlen(buffer); i++) {
            if(isprintable(buffer[i])) (*strings_array)[size][j++] = buffer[i];
        }
        (*strings_array)[size][strlen(buffer)] = '\0';
    }

    return size;
}

int put_strings_in_file(FILE* file, size_t strings_count, strings_array_t strings_array) {
    const size_t max_strings_count = 100;
    if(strings_count > 0) {
        for(size_t i = 0; i < strings_count && i < max_strings_count; i++) {
            if(fputs(strings_array[i], file) == EOF) {
                error("Error with fputs() in output file\n");
                return -1;
            }
            if(strcspn(strings_array[i], "\n") == strlen(strings_array[i])) {
                if(fputs("\n", file) == EOF) {
                    error("Error with fputs() in output file\n");
                    return -1;
                }
            }
        }
    }
    else {
        if(fputs("\n", file) == EOF) {
            error("Error with fputs() in output file\n");
            return -1;
        }
    }

    return 0;
}

int main(int argc, char **argv) {

    if (argc != 2) {
        error("Expected 1 command line argument (filename)\n");
        return -1;
    }

    FILE *in_file = fopen(argv[1], "r");
    if(in_file == NULL) {
        error("Error with fopen() of input file\n");
        return -1;
    }

    strings_array_t strings_array = NULL;
    int strings_count;
    if((strings_count = get_strings_from_file(in_file, MAX_INPUT_STRING_SIZE, &strings_array)) < 0) {
        fclose(in_file);
        error("Error with reading file\n");
        return -1;
    }

    qsort(strings_array, (size_t)strings_count, sizeof(char*), des);

    if(put_strings_in_file(stdout, (size_t)strings_count, strings_array) != 0) {
        fclose(in_file);
        free_strings_array(strings_array, (size_t)strings_count);
        error("Error with writing file\n");
        return -1;
    }

    fclose(in_file);
    free_strings_array(strings_array, (size_t)strings_count);

    return 0;
}
