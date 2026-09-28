#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/utsname.h>

int global_var = 42; // Data segment

int main(int argc, char *argv[]) {
    (void)argc;
    (void)argv;
    int local_var = 100; // Stack segment
    int *heap_var = (int *)malloc(sizeof(int)); // Heap segment
    *heap_var = 500;

    printf("=========================================\n");
    printf("        OS LAB LINUX TEST ENVIRONMENT     \n");
    printf("=========================================\n\n");

    // 1. Linux Kernel & System Information
    struct utsname sys_info;
    if (uname(&sys_info) == 0) {
        printf("[SysInfo] OS: %s\n", sys_info.sysname);
        printf("[SysInfo] Node: %s\n", sys_info.nodename);
        printf("[SysInfo] Release: %s\n", sys_info.release);
        printf("[SysInfo] Architecture: %s\n\n", sys_info.machine);
    }

    // 2. Memory Layout Inspection
    printf("[Memory Layout]\n");
    printf("  Code (main) address:    %p\n", (void *)main);
    printf("  Data (global_var):      %p (val: %d)\n", (void *)&global_var, global_var);
    printf("  Heap (heap_var):        %p (val: %d)\n", (void *)heap_var, *heap_var);
    printf("  Stack (local_var):      %p (val: %d)\n\n", (void *)&local_var, local_var);

    // 3. Process Creation & System Calls (fork, getpid, getppid, wait)
    printf("[Process Lifecycle Demo]\n");
    printf("  Parent Process PID: %d (Parent of parent: %d)\n", getpid(), getppid());

    pid_t pid = fork();

    if (pid < 0) {
        perror("fork failed");
        free(heap_var);
        return 1;
    } else if (pid == 0) {
        // Child Process
        printf("  [CHILD] PID: %d | My Parent PID: %d\n", getpid(), getppid());
        printf("  [CHILD] Modifying local_var to 999...\n");
        local_var = 999;
        printf("  [CHILD] local_var is now: %d\n", local_var);
        free(heap_var);
        printf("  [CHILD] Exiting with status 0\n");
        exit(0);
    } else {
        // Parent Process
        printf("  [PARENT] Created child with PID: %d\n", pid);
        int status;
        waitpid(pid, &status, 0); // Wait for child to finish
        if (WIFEXITED(status)) {
            printf("  [PARENT] Child %d terminated normally with exit code %d\n", pid, WEXITSTATUS(status));
        }
        printf("  [PARENT] Parent's local_var is still: %d (Copy-on-Write verified!)\n", local_var);
    }

    free(heap_var);
    printf("\nAll OS lab tests completed successfully!\n");
    return 0;
}
