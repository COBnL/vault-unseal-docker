#!/bin/bash

VAULT_KEYS="$VAULT_UNSEAL_KEY_1 $VAULT_UNSEAL_KEY_2 $VAULT_UNSEAL_KEY_3 $VAULT_UNSEAL_KEY_4 $VAULT_UNSEAL_KEY_5 $VAULT_UNSEAL_KEY_6 $VAULT_UNSEAL_KEY_7 $VAULT_UNSEAL_KEY_8 $VAULT_UNSEAL_KEY_9 $VAULT_UNSEAL_KEY_10 $VAULT_UNSEAL_KEY_11 $VAULT_UNSEAL_KEY_12 $VAULT_UNSEAL_KEY_13 $VAULT_UNSEAL_KEY_14 $VAULT_UNSEAL_KEY_15"
INDEX=0

for KEY in $VAULT_KEYS; do
  # https://github.com/hashicorp/vault/blob/c44f1c9817955d4c7cd5822a19fb492e1c2d0c54/command/status.go#L107
  # code reflects the seal status (0 unsealed, 2 sealed, 1 error).
  INDEX=$((INDEX+1))
  vault status;
  STATUS=$?

  if [ $STATUS -eq 0 ]; then
    echo "Vault is unsealed"
    exit 0
  elif [ $STATUS -eq 1 ]; then
    echo "vault returned an error"
    exit 1
  elif [ $STATUS -eq 2 ]; then
    echo "Vault is sealed"
    echo "Unsealing with key $INDEX"

    if [ -z "$KEY" ]; then
        echo "ran out of Vault unseal keys at $INDEX (VAULT_UNSEAL_KEY_$INDEX is missing). terminating..."
        exit 1
    fi

    vault operator unseal "$KEY" > /dev/null
    CODE=$?
    if [ $CODE -ne 0 ]; then
      echo "'vault perator unseal' returned exit code ($CODE). Terminating..."
      exit $CODE
    fi
  fi
done

