return [[
/* signal.h */
typedef void (*sig_t) (int);
sig_t signal(int sig, sig_t func);

/* stdlib.h */
void exit(int status);

/* libc definitions */
void* malloc(size_t bytes);
void free(void *);

/* stdio.h */
size_t fwrite(const void *, size_t, size_t, void*);

/* readline.h */
typedef void rl_vcpfunc_t (char *);

void rl_initialize();
char *readline (const char *prompt);

/* basic history handling */
void add_history(const char *line);
int write_history (const char *filename);
int append_history (int nelements, const char *filename);
int read_history (const char *filename);

/* completion */
typedef char **rl_completion_func_t (const char *, int, int);
typedef char *rl_compentry_func_t (const char *, int);
typedef char **rl_hook_func_t (const char *, int);
typedef char *rl_hook_func_t (const char *, int);

char **rl_completion_matches (const char *, rl_compentry_func_t *);

const char *rl_basic_word_break_characters;
rl_completion_func_t *rl_attempted_completion_function;
char *rl_line_buffer;
int rl_completion_append_character;
int rl_completion_suppress_append;
int rl_attempted_completion_over;

void rl_callback_handler_install (const char *prompt, rl_vcpfunc_t *lhandler);
void rl_callback_read_char (void);
void rl_callback_handler_remove (void);

void rl_refresh_line(int, int);
struct timeval { long tv_sec; long tv_nsec; };
int select(int nfds, int *readfds, struct fd_set * writefds, struct fd_set * errorfds, struct timeval * timeout);

int rl_on_new_line (void);
void rl_replace_line (const char *text, int clear_undo);

void* rl_outstream;

int rl_set_prompt (const char *prompt);
int rl_clear_message (void);
int rl_message (const char *);
int rl_delete_text (int start, int end);
int rl_insert_text (const char *);
int rl_forced_update_display (void);
void rl_redisplay (void);
int rl_point;
int rl_end;
int rl_catch_signals;

rl_hook_func_t *rl_startup_hook;
int rl_readline_state;
]]
