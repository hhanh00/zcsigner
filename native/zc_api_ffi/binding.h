#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct CKeys {
  char *phrase;
  char *derivation_path;
  char *spending_key;
  char *viewing_key;
  char *address;
} CKeys;

typedef struct CResult______c_char {
  const char *ok;
  const char *err;
} CResult______c_char;

bool initialize(char *database_path);

struct CKeys init_account(char *database_path);

uint64_t sync(char *database_path, uint32_t max_blocks);

uint64_t get_balance(char *database_path);

void send_tx(char *database_path,
             char *address,
             uint64_t amount,
             char *spending_key,
             const char *spend_params,
             uintptr_t len_spend_params,
             const char *output_params,
             uintptr_t len_output_params);

bool check_address(char *address);

const char *get_address(char *viewing_key);

const char *get_key_type(char *key);

void init_account_with_viewing_key(char *database_path, char *viewing_key, uint32_t height);

struct CResult______c_char prepare_tx(char *database_path, char *address, uint64_t amount);

struct CResult______c_char sign_tx(char *secret_key,
                                   char *tx,
                                   const char *spend_params,
                                   uintptr_t len_spend_params,
                                   const char *output_params,
                                   uintptr_t len_output_params);

struct CResult______c_char broadcast(char *raw_tx);

uint32_t get_height(char *database_path);
