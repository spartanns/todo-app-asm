section .data
    menu_msg db "Todo App", 10, "1. Add task", 10, "2. View task", 10, "3. Remove task", 10, "4. Exit", 10, "Enter choice: ", 0
    menu_len equ $ - menu_msg

    prompt_msg db "Enter task: ", 0
    prompt_len equ $ - prompt_msg

    tasks_msg db "Current tasks: ", 10, 0
    tasks_len equ $ - tasks_msg

    no_tasks_msg db "No tasks available.", 10, 0
    no_tasks_len equ $ - no_tasks_msg

    remove_msg db "Enter task number to remove: ", 10, 0
    remove_len equ $ - remove_msg

    invalid_msg db "Invalid choice. Try again!", 10, 0
    invalid_len equ $ - invalid_msg

    task_added_msg db "Task added successfully.", 10, 0
    task_added_len equ $ - task_added_msg

    task_removed_msg db "Task removed successfully.", 10, 0
    task_removed_len equ $ - task_removed_msg

    MAX_TASKS equ 20
    MAX_TASK_LEN equ 100

    task_count db 0
    task_buffer_size equ MAX_TASKS * MAX_TASK_LEN

section .bss
    choice resb 4
    task_input resb MAX_TASK_LEN
    task_storage resb task_buffer_size
    remove_num resb 4

section .text
    global _start
_start:

main_loop:
    ; Display menu
    mov rax, 1
    mov rdi, 1
    mov rsi, menu_msg
    mov rdx, menu_len
    syscall

    ; Get user choice
    mov rax, 0
    mov rdi, 0
    mov rsi, choice
    mov rdx, 4
    syscall

    ; Process user choice
    mov al, byte [choice]

    cmp al, '1'
    je add_task
    
    cmp al, '2'
    je view_task

    cmp al, '3'
    je remove_task

    cmp al, '4'
    je exit_program

    ; Invalid choice
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_msg
    mov rdx, invalid_len
    syscall
    jmp main_loop

add_task:
    ; Check if task storage is full
    movzx rax, byte [task_count]
    cmp rax, MAX_TASKS
    jge main_loop

    ; Prompt for task input
    mov rax, 1
    mov rdi, 1
    mov rsi, prompt_msg
    mov rdx, prompt_len
    syscall

    ; Get task input
    mov rax, 0
    mov rdi, 0
    mov rsi, task_input
    mov rdx, MAX_TASK_LEN
    syscall

    ; Calculate destination address in task storage
    movzx r8, byte [task_count]
    imul r8, MAX_TASK_LEN
    lea rdi, [task_storage + r8]

    ; Copy task input to task storage
    mov rsi, task_input
    mov rcx, MAX_TASK_LEN
    cld
    rep movsb

    ; Increment task count
    inc byte [task_count]

    ; Confirmation message
    mov rax, 1
    mov rdi, 1
    mov rsi, task_added_msg
    mov rdx, task_added_len
    syscall

    jmp main_loop

view_task:
    ; Check if there are any tasks
    cmp byte [task_count], 0
    je no_tasks

    ; Display tasks header
    mov rax, 1
    mov rdi, 1
    mov rsi, tasks_msg
    mov rdx, tasks_len
    syscall

    ; Display each task
    xor r8, r8

display_task_loop:
    ; Check if we've displayed all the tasks
    movzx rax, byte [task_count]
    cmp r8, rax
    jge main_loop

    ; Display task number (r8 + 1)
    add r8, 1
    mov rax, r8
    add rax, '0'
    mov [choice], al
    mov byte [choice + 1], '.'
    mov byte [choice + 2], ' '

    ; Display task number
    mov rax, 1
    mov rdi, 1
    mov rsi, choice
    mov rdx, 3
    syscall

    ; Calculate task address
    sub r8, 1
    mov r9, r8
    imul r9, MAX_TASK_LEN
    lea rsi, [task_storage + r9]

    ; Display task
    mov rax, 1
    mov rdi, 1
    mov rdx, MAX_TASK_LEN
    syscall

    add r8, 1
    jmp display_task_loop

no_tasks:
    ; Display "no tasks" message
    mov rax, 1
    mov rdi, 1
    mov rsi, no_tasks_msg
    mov rdx, no_tasks_len
    syscall

    jmp main_loop

remove_task:
    ; Check if there are any tasks
    cmp byte [task_count], 0
    je no_tasks

    ; Prompt for task number to remove
    mov rax, 1
    mov rdi, 1
    mov rsi, remove_msg
    mov rdx, remove_len
    syscall

    ; Get task number
    mov rax, 0
    mov rdi, 0
    mov rsi, remove_num
    mov rdx, 4
    syscall

    ; Convert ASCII to number
    movzx r8, byte [remove_num]
    sub r8, '0'

    ; Check if number is valid
    cmp r8, 1
    jl invalid_remove

    movzx rax, byte [task_count]
    cmp r8, rax
    jg invalid_remove

    ; Adjust to 0 based index
    dec r8

    ; Calculate source and destination addresses for moving tasks
    mov r9, r8
    add r9, 1
    imul r9, MAX_TASK_LEN
    lea rsi, [task_storage + r9]

    mov r9, r8
    imul r9, MAX_TASK_LEN
    lea rdi, [task_storage + r9]

    ; Calculate number of bytes to move
    movzx rax, byte [task_count]
    sub rax, r8
    dec rax
    imul rax, MAX_TASK_LEN
    mov rcx, rax

    ; Move remaining tasks up
    cld
    rep movsb

    ; Decrement task count
    dec byte [task_count]

    ; Confirmation message
    mov rax, 1
    mov rdi, 1
    mov rsi, task_removed_msg
    mov rdx, task_removed_len
    syscall

    jmp main_loop

invalid_remove:
    mov rax, 1
    mov rdi, 1
    mov rsi, invalid_msg
    mov rdx, invalid_len
    syscall

    jmp main_loop

exit_program:
    mov rax, 60
    xor rdi, rdi
    syscall
